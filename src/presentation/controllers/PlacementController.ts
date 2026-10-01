import { Request, Response } from "express";
import { container } from "../../config/container.js";

export class PlacementController {
  static async getQuestions(_req: Request, res: Response) {
    const questions = await container.getPlacementQuestionsUseCase.execute();

    return res.status(200).json(questions);
  }

  static async evaluate(req: Request, res: Response) {
    if (!req.auth) {
      return res.status(401).json({
        error: {
          code: "UNAUTHORIZED",
          message: "Usuario no autenticado",
        },
      });
    }

    const { roleId, answers } = req.body;

    const result = await container.evaluatePlacementTestUseCase.execute({
      userId: req.auth.uid,
      roleId,
      answers,
    });

    return res.status(200).json(result);
  }
}
