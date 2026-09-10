import { Router } from "express";
import { UserController } from "../controllers/UserController.js";
import { authenticate } from "../middlewares/AuthMiddleware.js";
import { validateBody } from "../middlewares/validateBody.js";
import {
  syncUserSchema,
  updateMyProfileSchema,
} from "../validators/user.validator.js";

const router = Router();

router.post(
  "/sync",
  authenticate,
  validateBody(syncUserSchema),
  UserController.syncUser,
);

router.get("/me", authenticate, UserController.getMyProfile);

router.patch(
  "/me",
  authenticate,
  validateBody(updateMyProfileSchema),
  UserController.updateMyProfile,
);

export default router;
