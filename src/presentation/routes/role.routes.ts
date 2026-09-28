import { Router } from "express";
import { RoleController } from "../controllers/RoleController.js";
import { authenticate } from "../middlewares/AuthMiddleware.js";

const router = Router();

router.get("/", authenticate, RoleController.listRoles);

export default router;