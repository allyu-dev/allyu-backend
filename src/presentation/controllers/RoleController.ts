import { Request, Response } from "express";
import { container } from "../../config/container.js";

export class RoleController {
  static async listRoles(_req: Request, res: Response) {
    const roles = await container.listRolesUseCase.execute();

    return res.status(200).json(roles);
  }
}
