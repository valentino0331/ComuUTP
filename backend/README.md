# UTP Comunidades Backend

## Estructura del proyecto

```
backend/
│
├── src/
│   ├── config/
│   │      db.js
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── middlewares/
│   ├── services/
│   └── utils/
│
├── app.js
├── server.js
├── package.json
└── .env
```

## Instalación

```
cd backend
npm install
```

## Scripts

- `npm run dev` para desarrollo (con nodemon)
- `npm start` para producción

## Endpoints principales

- POST   /auth/register
- POST   /auth/login
- GET    /auth/me
- GET    /users/profile
- POST   /communities
- GET    /communities
- POST   /communities/join
- POST   /posts
- GET    /posts/community/:id
- POST   /comments
- POST   /likes
- POST   /reports
- POST   /ban
- GET    /notifications

## Notas
- Usar Node.js 18+
- La base de datos debe estar creada y accesible en PostgreSQL
- El archivo `.env` debe tener las credenciales correctas
