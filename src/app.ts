import express from "express";
import userRoutes from "./presentation/routes/user.routes.js";
import roleRoutes from "./presentation/routes/role.routes.js";

import {
  errorHandler,
  notFoundHandler,
} from "./presentation/middlewares/errorHandler.js";

const app = express();

// Middleware para entender JSON en el body
app.use(express.json());

// Endpoint de prueba
app.get("/health", (req, res) => {
  res
    .status(200)
    .json({ status: "OK", message: "Backend de Ayú funcionando 🚀" });
});

// Rutas de la API
app.use("/api/v1/users", userRoutes);
app.use("/api/v1/roles", roleRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

export default app;
