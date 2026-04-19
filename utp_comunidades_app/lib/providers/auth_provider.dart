import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _loading = false;
  String? _error;
  
  // Firebase user
  firebase.User? _firebaseUser;

  User? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  String? get error => _error;
  String? get loginError => _error; // Alias para el UI del login
  firebase.User? get firebaseUser => _firebaseUser;

  /// Restaurar sesión guardada al iniciar la app
  Future<void> restoreSession() async {
    _loading = true;
    notifyListeners();
    
    try {
      // Intentar recuperar el token guardado
      final savedToken = await ApiService.getToken();
      
      if (savedToken != null) {
        _token = savedToken;
        
        // Intentar obtener datos del usuario con el token guardado
        final res = await ApiService.get('/auth/me', auth: true);
        
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          _user = User.fromJson(data);
        } else {
          // Token inválido o expirado
          _token = null;
          _user = null;
          await ApiService.deleteToken();
        }
      }
    } catch (e) {
      // Error al restaurar sesión, es normal si no hay sesión guardada
      _token = null;
      _user = null;
    }
    
    _loading = false;
    notifyListeners();
  }

  /// Login con Firebase Auth + Backend Neon
  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 1. Login con Firebase
      final credential = await firebase.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      
      _firebaseUser = credential.user;
      
      if (_firebaseUser == null) {
        _error = 'Error al iniciar sesión con Firebase';
        _loading = false;
        notifyListeners();
        return false;
      }
      
      // 2. Verificar si el email está verificado
      if (!_firebaseUser!.emailVerified) {
        _error = 'Por favor verifica tu correo electrónico antes de iniciar sesión';
        _loading = false;
        notifyListeners();
        return false;
      }
      
      // 3. Login en backend Neon
      final res = await ApiService.post('/auth/login', {
        'uid': _firebaseUser!.uid,
        'email': email,
      });
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['token'];
        await ApiService.saveToken(_token!);
        
        if (data['usuario'] != null) {
          _user = User.fromJson(data['usuario']);
        }
        
        _loading = false;
        notifyListeners();
        return true;
      } else if (res.statusCode == 404) {
        // Usuario existe en Firebase pero no en Neon - necesita completar registro
        _error = 'Completa tu registro para continuar';
        _loading = false;
        notifyListeners();
        return false;
      } else {
        _error = 'Error al iniciar sesión';
        _loading = false;
        notifyListeners();
        return false;
      }
    } on firebase.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e.code);
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registrar usuario en Firebase (envía email de verificación)
  Future<Map<String, dynamic>> registerWithFirebase({
    required String email,
    required String password,
    required String nombre,
    String? apellido,
    String? carrera,
    int? ciclo,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 1. Crear usuario en Firebase
      final credential = await firebase.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      
      _firebaseUser = credential.user;
      
      if (_firebaseUser == null) {
        _loading = false;
        notifyListeners();
        return {'success': false, 'error': 'Error al crear usuario'};
      }
      
      // 2. Actualizar display name
      await _firebaseUser!.updateDisplayName('$nombre ${apellido ?? ''}'.trim());
      
      // 3. Enviar email de verificación
      await _firebaseUser!.sendEmailVerification();
      
      _loading = false;
      notifyListeners();
      
      return {
        'success': true,
        'uid': _firebaseUser!.uid,
        'message': 'Revisa tu correo para verificar tu cuenta',
      };
    } on firebase.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e.code);
      _loading = false;
      notifyListeners();
      return {'success': false, 'error': _error};
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return {'success': false, 'error': _error};
    }
  }

  /// Completar registro en Neon (después de verificar email)
  Future<bool> completeRegistration({
    required String uid,
    required String email,
    required String nombre,
    String? apellido,
    String? carrera,
    int? ciclo,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final res = await ApiService.post('/auth/register', {
        'uid': uid,
        'email': email,
        'nombre': nombre,
        'apellido': apellido,
        'carrera': carrera,
        'ciclo': ciclo,
      });
      
      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body);
        
        if (data['usuario'] != null) {
          _user = User.fromJson(data['usuario']);
        }
        
        _loading = false;
        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(res.body);
        _error = error['error'] ?? 'Error al completar registro';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verificar si el email está verificado
  Future<bool> checkEmailVerified() async {
    final user = firebase.FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      _firebaseUser = firebase.FirebaseAuth.instance.currentUser;
      return _firebaseUser?.emailVerified ?? false;
    }
    return false;
  }

  /// Reenviar email de verificación
  Future<void> resendVerificationEmail() async {
    final user = firebase.FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await firebase.FirebaseAuth.instance.signOut();
    _user = null;
    _token = null;
    _firebaseUser = null;
    await ApiService.deleteToken();
    notifyListeners();
  }

  /// Recuperar contraseña - enviar email de reset
  Future<bool> resetPassword(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await firebase.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _loading = false;
      notifyListeners();
      return true;
    } on firebase.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e.code);
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al enviar email: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login como admin para pruebas (sin Firebase)
  Future<bool> loginAsAdmin() async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _user = User(
      id: 1,
      email: 'admin@utp.edu.pe',
      nombre: 'Administrador UTP',
      esAdmin: true,
      esPremium: true,
      puedeCrearComunidad: true,
      role: 'admin',
      fotoPerfil: null,
    );
    _token = 'admin-token-test';
    
    _loading = false;
    notifyListeners();
    return true;
  }

  /// Mapear errores de Firebase a mensajes en español
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres)';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      default:
        return 'Error de autenticación: $code';
    }
  }

  /// Actualizar perfil del usuario
  Future<bool> updateProfile({
    required String nombre,
    String? biografia,
    String? carrera,
    List<String>? intereses,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await ApiService.post('/users/edit', {
        'nombre': nombre,
        'biografia': biografia,
        'carrera': carrera,
        'intereses': intereses,
      }, auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['usuario'] != null) {
          _user = User.fromJson(data['usuario']);
        }
        _loading = false;
        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(res.body);
        _error = error['error'] ?? 'Error al actualizar perfil';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}

