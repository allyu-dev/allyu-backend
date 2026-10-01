import { Router } from "express";
import { PlacementController } from "../controllers/PlacementController.js";
import { authenticate } from "../middlewares/AuthMiddleware.js";
import { validateBody } from "../middlewares/validateBody.js";
import { evaluatePlacementSchema } from "../validators/placement.validator.js";

const router = Router();

router.get("/questions", authenticate, PlacementController.getQuestions);

router.post(
  "/evaluate",
  authenticate,
  validateBody(evaluatePlacementSchema),
  PlacementController.evaluate,
);

export default router;
