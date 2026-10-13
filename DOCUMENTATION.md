# Allyu Backend - Documentación actual

## Descripción

Allyu es una API para una plataforma de aprendizaje de inglés técnico orientada a perfiles de TI. El backend usa Node.js, Express, TypeScript y Firestore, con Firebase Authentication como proveedor de identidad.

El estado actual cubre tres módulos:

- **Auth / User:** sincroniza el perfil con Firebase Auth, consulta el perfil propio y actualiza el nombre visible.
- **Role:** entrega el catálogo de roles técnicos activos almacenado en Firestore.
- **Placement:** entrega un test fijo de 12 preguntas y asigna un nivel de inglés entre `A1` y `B2` de forma determinista.

Las rutas privadas verifican un Firebase ID Token. El UID nunca se toma del body: se obtiene del token verificado.

## Arquitectura

El proyecto usa una Clean Architecture pragmática. Las capas externas dependen de las internas:

```text
Presentation (Express, rutas, controllers, middlewares)
        ↓
Application (casos de uso)
        ↓
Domain (entidades, contratos, reglas)
        ↑
Infrastructure (Firestore y Firebase Admin implementan contratos del dominio)
```

### Árbol relevante

```text
allyu-backend/
├── scripts/
│   └── seedRoles.ts                         # Carga el catálogo inicial de roles
├── src/
│   ├── app.ts                               # Configura Express, rutas y manejo global de errores
│   ├── server.ts                            # Inicia el servidor HTTP
│   ├── config/
│   │   └── container.ts                     # Compone repositorios Firestore y casos de uso
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── User.ts                      # Perfil, nivel, XP y racha
│   │   │   ├── Role.ts                      # Catálogo de perfiles técnicos
│   │   │   └── Placement.ts                 # Preguntas, respuestas y resultado de placement
│   │   ├── errors/
│   │   │   ├── UserNotFoundError.ts
│   │   │   ├── RoleNotFoundError.ts
│   │   │   └── PlacementValidationError.ts
│   │   ├── repositories/
│   │   │   ├── IUserRepository.ts
│   │   │   └── IRoleRepository.ts
│   │   └── services/
│   │       └── PlacementLevelCalculator.ts  # Convierte puntaje en A1, A2, B1 o B2
│   ├── application/
│   │   ├── data/
│   │   │   └── placementQuestions.ts        # Banco interno de 12 preguntas; conserva respuestas correctas
│   │   └── use-cases/
│   │       ├── auth/
│   │       │   ├── SyncUserUseCase.ts
│   │       │   ├── GetMyProfileUseCase.ts
│   │       │   └── UpdateMyProfileUseCase.ts
│   │       ├── catalog/
│   │       │   └── ListRolesUseCase.ts
│   │       └── placement/
│   │           ├── GetPlacementQuestionsUseCase.ts
│   │           └── EvaluatePlacementTestUseCase.ts
│   ├── infrastructure/
│   │   ├── firebase/
│   │   │   └── firebase-admin.config.ts     # Inicializa Firebase Admin, Auth y Firestore
│   │   └── database/firestore/
│   │       ├── FirestoreUserRepository.ts
│   │       └── FirestoreRoleRepository.ts
│   └── presentation/
│       ├── controllers/
│       │   ├── UserController.ts
│       │   ├── RoleController.ts
│       │   └── PlacementController.ts
│       ├── middlewares/
│       │   ├── AuthMiddleware.ts             # Verifica Firebase ID Token
│       │   ├── validateBody.ts               # Valida bodies con Zod
│       │   └── errorHandler.ts               # Respuestas uniformes de error y 404 de ruta
│       ├── routes/
│       │   ├── user.routes.ts
│       │   ├── role.routes.ts
│       │   └── placement.routes.ts
│       ├── types/
│       │   └── express.d.ts                  # Declara req.auth
│       └── validators/
│           ├── user.validator.ts
│           └── placement.validator.ts
├── package.json
└── tsconfig.json
```

### Composición de dependencias

`src/config/container.ts` es el único punto que conoce implementaciones concretas de Firestore. Construye `FirestoreUserRepository` y `FirestoreRoleRepository`, y los inyecta en los casos de uso. Los controllers usan el contenedor, no importan repositorios directamente.

### Persistencia actual

```text
users/{firebaseUid}
  email, displayName, roleId, englishLevel,
  xp, streak, lastActivityDate, createdAt, updatedAt

roles/{roleId}
  name, description, iconKey, isActive, order
```

Las preguntas del placement aún viven en código (`placementQuestions.ts`) y no en Firestore. Las entidades de lecciones, ejercicios, roadmap y progreso todavía no están implementadas funcionalmente.

## Convenciones comunes de la API

Base URL local:

```text
http://localhost:3000
```

Todas las rutas bajo `/api/v1` requieren:

```http
Authorization: Bearer <Firebase ID Token>
```

Los endpoints que reciben JSON requieren:

```http
Content-Type: application/json
```

Formato general de error:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Descripción del error"
  }
}
```

Los errores de validación Zod incluyen `details` con los campos inválidos.

## API Reference

### Health

#### `GET /health`

Verifica que Express esté disponible.

- **Headers:** no requiere.
- **Body:** no requiere.

**200 OK**

```json
{
  "status": "OK",
  "message": "Backend de Ayú funcionando 🚀"
}
```

---

### User / Auth

#### `POST /api/v1/users/sync`

Crea un perfil Firestore en el primer acceso del UID autenticado. En accesos posteriores devuelve el perfil existente y actualiza `lastActivityDate`.

- **Headers:** `Authorization: Bearer <Firebase ID Token>` y `Content-Type: application/json`.
- **Body:** debe ser un objeto vacío. La identidad se obtiene del token.

```json
{}
```

**201 Created** - primer acceso

```json
{
  "id": "firebase-uid",
  "email": "allyu.test@example.com",
  "displayName": null,
  "roleId": null,
  "englishLevel": null,
  "xp": 0,
  "streak": 0,
  "lastActivityDate": "2026-10-02",
  "createdAt": "2026-10-02T12:00:00.000Z",
  "updatedAt": "2026-10-02T12:00:00.000Z",
  "isNewUser": true
}
```

**200 OK** - usuario ya existente

```json
{
  "id": "firebase-uid",
  "email": "allyu.test@example.com",
  "displayName": "José Guevara",
  "roleId": "software-engineer",
  "englishLevel": "B1",
  "xp": 0,
  "streak": 0,
  "lastActivityDate": "2026-10-02",
  "createdAt": "2026-10-02T12:00:00.000Z",
  "updatedAt": "2026-10-02T12:30:00.000Z",
  "isNewUser": false
}
```

**400 Bad Request**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "El body de la solicitud no es válido"
  }
}
```

También responde `400 AUTH_EMAIL_REQUIRED` si el token es válido pero no tiene email.

**401 Unauthorized:** falta, está vacío o es inválido el Bearer token.

**500 Internal Server Error:** error no controlado, por ejemplo un fallo de Firestore.

#### `GET /api/v1/users/me`

Devuelve el perfil del usuario identificado por el token.

- **Headers:** `Authorization: Bearer <Firebase ID Token>`.
- **Body:** no requiere.

**200 OK**

```json
{
  "id": "firebase-uid",
  "email": "allyu.test@example.com",
  "displayName": "José Guevara",
  "roleId": "software-engineer",
  "englishLevel": "B1",
  "xp": 0,
  "streak": 0,
  "lastActivityDate": "2026-10-02",
  "createdAt": "2026-10-02T12:00:00.000Z",
  "updatedAt": "2026-10-02T12:30:00.000Z"
}
```

**401 Unauthorized:** token ausente o inválido.

**404 Not Found**

```json
{
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "Usuario no encontrado"
  }
}
```

**500 Internal Server Error:** error no controlado de servidor o Firestore.

#### `PATCH /api/v1/users/me`

Actualiza el campo editable `displayName` del usuario autenticado. No permite modificar UID, email, XP, racha, rol ni nivel.

- **Headers:** `Authorization: Bearer <Firebase ID Token>` y `Content-Type: application/json`.
- **Body:**

```json
{
  "displayName": "José Guevara"
}
```

Para eliminar el nombre:

```json
{
  "displayName": null
}
```

**200 OK:** devuelve el perfil actualizado.

**400 Bad Request:** `displayName` debe ser `null` o un texto de 2 a 60 caracteres. Campos adicionales, por ejemplo `xp`, también se rechazan.

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "El body de la solicitud no es válido",
    "details": [
      {
        "field": "displayName",
        "message": "displayName debe tener al menos 2 caracteres"
      }
    ]
  }
}
```

**401 Unauthorized, 404 USER_NOT_FOUND, 500 INTERNAL_ERROR:** aplican de igual manera que en `GET /users/me`.

---

### Roles

#### `GET /api/v1/roles`

Devuelve los roles activos, ordenados por el campo `order`.

- **Headers:** `Authorization: Bearer <Firebase ID Token>`.
- **Body:** no requiere.

**200 OK**

```json
[
  {
    "id": "software-engineer",
    "name": "Software Engineer",
    "description": "Desarrolla aplicaciones, escribe código y participa en revisiones técnicas.",
    "iconKey": "code",
    "isActive": true,
    "order": 1
  }
]
```

**401 Unauthorized:** token ausente o inválido.

**500 Internal Server Error:** error al consultar Firestore.

---

### Placement

#### `GET /api/v1/placement/questions`

Devuelve las 12 preguntas del placement test. Las respuestas correctas permanecen solo en el backend y no se incluyen en la respuesta.

- **Headers:** `Authorization: Bearer <Firebase ID Token>`.
- **Body:** no requiere.

**200 OK**

```json
[
  {
    "id": "q1",
    "prompt": "I ___ a software developer.",
    "options": [
      { "id": "a", "text": "is" },
      { "id": "b", "text": "am" },
      { "id": "c", "text": "are" }
    ]
  }
]
```

**401 Unauthorized:** token ausente o inválido.

**500 Internal Server Error:** error no controlado.

#### `POST /api/v1/placement/evaluate`

Valida el rol y las 12 respuestas, calcula el puntaje, asigna `A1`, `A2`, `B1` o `B2`, y actualiza `roleId` y `englishLevel` del usuario autenticado.

- **Headers:** `Authorization: Bearer <Firebase ID Token>` y `Content-Type: application/json`.
- **Body:**

```json
{
  "roleId": "software-engineer",
  "answers": [
    { "questionId": "q1", "optionId": "b" },
    { "questionId": "q2", "optionId": "c" },
    { "questionId": "q3", "optionId": "b" },
    { "questionId": "q4", "optionId": "c" },
    { "questionId": "q5", "optionId": "b" },
    { "questionId": "q6", "optionId": "c" },
    { "questionId": "q7", "optionId": "a" },
    { "questionId": "q8", "optionId": "b" },
    { "questionId": "q9", "optionId": "c" },
    { "questionId": "q10", "optionId": "b" },
    { "questionId": "q11", "optionId": "c" },
    { "questionId": "q12", "optionId": "b" }
  ]
}
```

Regla actual de nivel:

| Correctas | Nivel |
| --- | --- |
| 0-3 | A1 |
| 4-6 | A2 |
| 7-9 | B1 |
| 10-12 | B2 |

**200 OK**

```json
{
  "roleId": "software-engineer",
  "englishLevel": "B2",
  "correctAnswers": 12,
  "totalQuestions": 12
}
```

**400 Bad Request:** body con estructura inválida (`VALIDATION_ERROR`) o respuestas incompletas, duplicadas o con opciones inválidas (`PLACEMENT_VALIDATION_ERROR`).

```json
{
  "error": {
    "code": "PLACEMENT_VALIDATION_ERROR",
    "message": "Debes responder las 12 preguntas del placement test"
  }
}
```

**401 Unauthorized:** token ausente o inválido.

**404 Not Found:** el usuario no existe o el rol no existe/no está activo.

```json
{
  "error": {
    "code": "ROLE_NOT_FOUND",
    "message": "Rol no encontrado o no disponible"
  }
}
```

**500 Internal Server Error:** error no controlado, incluyendo un fallo de Firestore.

## Guía de pruebas con Postman

### Preparación

1. Ejecuta el backend:

   ```powershell
   npm run dev
   ```

2. Obtén un Firebase ID Token válido y guárdalo como `{{idToken}}` en el Environment de Postman.
3. Define `{{baseUrl}}` como `http://localhost:3000`.
4. Confirma que `serviceAccountKey.json` corresponde al mismo proyecto Firebase que emitió el token.

### Secuencia recomendada

1. **Health:** `GET {{baseUrl}}/health`. Debe responder `200`.
2. **Sincronizar usuario:** `POST {{baseUrl}}/api/v1/users/sync` con body `{}` y Bearer token. La primera vez debe responder `201`; las siguientes, `200`.
3. **Consultar perfil:** `GET {{baseUrl}}/api/v1/users/me`. Al inicio, `roleId` y `englishLevel` deben ser `null`.
4. **Actualizar nombre opcionalmente:** `PATCH {{baseUrl}}/api/v1/users/me` con `{ "displayName": "José Guevara" }`.
5. **Listar roles:** `GET {{baseUrl}}/api/v1/roles`. Debe devolver los roles seed activos.
6. **Obtener preguntas:** `GET {{baseUrl}}/api/v1/placement/questions`. Verifica que ninguna pregunta incluya `correctOptionId`.
7. **Evaluar placement:** `POST {{baseUrl}}/api/v1/placement/evaluate` con un `roleId` listado y las 12 respuestas.
8. **Verificar perfil:** repite `GET {{baseUrl}}/api/v1/users/me`. Ahora debe mostrar el `roleId` y `englishLevel` asignados.
9. **Pruebas negativas:** prueba una ruta sin token, un `displayName` de un carácter, un body de sync con `id`, y una evaluación con menos de 12 respuestas.

## Estado y siguientes módulos

Implementado:

- Autenticación de requests mediante Firebase ID Token.
- Perfil de usuario en Firestore.
- Catálogo seed de roles técnicos.
- Placement test determinista de 12 preguntas.

Pendiente:

- Roadmaps, lecciones y ejercicios.
- Intentos, progreso, XP y racha.
- Generación de lecciones con Gemini y caché.
- Pruebas automatizadas: el script `npm test` actual es un placeholder y aún falla intencionalmente.
- CI/CD, Docker, Kubernetes y configuración productiva mediante variables de entorno.
