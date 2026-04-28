// backend/src/controllers/study.controller.js
// Study controller - Modo Estudio + IA

const studyService = require('../services/study.service');

exports.getUserCourses = async (req, res) => {
  try {
    const userId = req.user.id;
    const courses = await studyService.getUserCourses(userId);
    
    res.status(200).json({
      success: true,
      data: courses,
      count: courses.length
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.createCourse = async (req, res) => {
  try {
    const userId = req.user.id;
    const course = await studyService.createCourse(userId, req.body);
    
    res.status(201).json({
      success: true,
      data: course,
      message: 'Curso creado exitosamente'
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(400).json({ error: err.message });
  }
};

exports.getCourseDetail = async (req, res) => {
  try {
    const userId = req.user.id;
    const { courseId } = req.params;
    
    const detail = await studyService.getCourseDetail(courseId, userId);
    
    res.status(200).json({
      success: true,
      data: detail
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(404).json({ error: err.message });
  }
};

exports.updateCourse = async (req, res) => {
  try {
    const userId = req.user.id;
    const { courseId } = req.params;
    
    const course = await studyService.updateCourse(courseId, userId, req.body);
    
    res.status(200).json({
      success: true,
      data: course
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(400).json({ error: err.message });
  }
};

exports.archiveCourse = async (req, res) => {
  try {
    const userId = req.user.id;
    const { courseId } = req.params;
    
    await studyService.archiveCourse(courseId, userId);
    
    res.status(200).json({
      success: true,
      message: 'Curso archivado'
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(400).json({ error: err.message });
  }
};

exports.uploadMaterial = async (req, res) => {
  try {
    const userId = req.user.id;
    const { courseId } = req.params;
    const { name, fileUrl, fileSizeBytes, fileType, pageCount, category } = req.body;
    
    const material = await studyService.uploadMaterial(userId, courseId, {
      name,
      fileUrl,
      fileSizeBytes,
      fileType,
      pageCount,
      category
    });
    
    res.status(201).json({
      success: true,
      data: material,
      message: 'Material subido exitosamente'
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(400).json({ error: err.message });
  }
};

exports.deleteMaterial = async (req, res) => {
  try {
    const userId = req.user.id;
    const { materialId } = req.params;
    
    await studyService.deleteMaterial(materialId, userId);
    
    res.status(200).json({
      success: true,
      message: 'Material eliminado'
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(400).json({ error: err.message });
  }
};

exports.summarizeMaterial = async (req, res) => {
  try {
    const userId = req.user.id;
    const { materialId } = req.body;
    
    const summary = await studyService.summarizeMaterial(userId, materialId);
    
    res.status(200).json({
      success: true,
      data: summary
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(400).json({ error: err.message });
  }
};

exports.generateQuiz = async (req, res) => {
  try {
    const userId = req.user.id;
    const { courseId, count, difficulty } = req.body;
    
    const quiz = await studyService.generateQuiz(userId, courseId, count || 5, difficulty || 'medium');
    
    res.status(200).json({
      success: true,
      data: quiz
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(400).json({ error: err.message });
  }
};

exports.askQuestion = async (req, res) => {
  try {
    const userId = req.user.id;
    const { courseId, question } = req.body;
    
    const answer = await studyService.askQuestion(userId, courseId, question);
    
    res.status(200).json({
      success: true,
      data: answer
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(400).json({ error: err.message });
  }
};

exports.getQuestions = async (req, res) => {
  try {
    const { courseId } = req.params;
    
    const questions = await studyService.getQuestions(courseId);
    
    res.status(200).json({
      success: true,
      data: questions
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(400).json({ error: err.message });
  }
};

exports.submitQuizAttempt = async (req, res) => {
  try {
    const userId = req.user.id;
    const { courseId, answers, timeSpent } = req.body;
    
    const result = await studyService.submitQuizAttempt(userId, courseId, answers, timeSpent);
    
    res.status(200).json({
      success: true,
      data: result
    });
  } catch (err) {
    console.error('Error:', err);
    res.status(400).json({ error: err.message });
  }
};
