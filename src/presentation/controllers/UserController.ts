import { Request, Response } from "express";
import { container } from "../../config/container.js";

export class UserController {
  static async syncUser(req: Request, res: Response) {
    if (!req.auth) {
      return res.status(401).json({
        error: {
          code: "UNAUTHORIZED",
          message: "Usuario no autenticado",
        },
      });
    }

    if (!req.auth.email) {
      return res.status(400).json({
        error: {
          code: "AUTH_EMAIL_REQUIRED",
          message: "La cuenta autenticada debe tener un email",
        },
      });
    }

    const result = await container.syncUserUseCase.execute({
      id: req.auth.uid,
      email: req.auth.email,
      displayName: req.auth.displayName,
    });

    return res.status(result.isNewUser ? 201 : 200).json({
      ...result.user,
      isNewUser: result.isNewUser,
    });
  }

  static async getMyProfile(req: Request, res: Response) {
    if (!req.auth) {
      return res.status(401).json({
        error: {
          code: "UNAUTHORIZED",
          message: "Usuario no autenticado",
        },
      });
    }

    const user = await container.getMyProfileUseCase.execute(req.auth.uid);

    return res.status(200).json(user);
  }

  static async updateMyProfile(req: Request, res: Response) {
    if (!req.auth) {
      return res.status(401).json({
        error: {
          code: "UNAUTHORIZED",
          message: "Usuario no autenticado",
        },
      });
    }

    const { displayName } = req.body;

    const user = await container.updateMyProfileUseCase.execute({
      id: req.auth.uid,
      profile: {
        displayName: displayName === null ? null : displayName.trim(),
      },
    });

    return res.status(200).json(user);
  }
}
