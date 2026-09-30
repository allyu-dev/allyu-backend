import { ErrorRequestHandler, NextFunction, Request, Response } from "express";

import { UserNotFoundError } from "../../domain/errors/UserNotFoundError.js";
import { PlacementValidationError } from "../../domain/errors/PlacementValidationError.js";
import { RoleNotFoundError } from "../../domain/errors/RoleNotFoundError.js";

export const notFoundHandler = (req: Request, res: Response): Response => {
  return res.status(404).json({
    error: {
      code: "ROUTE_NOT_FOUND",
      message: `La ruta ${req.method} ${req.originalUrl} no existe`,
    },
  });
};

export const errorHandler: ErrorRequestHandler = (
  error: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): Response => {
  if (error instanceof UserNotFoundError) {
    return res.status(404).json({
      error: {
        code: "USER_NOT_FOUND",
        message: error.message,
      },
    });
  }

  if (error instanceof RoleNotFoundError) {
    return res.status(404).json({
      error: {
        code: "ROLE_NOT_FOUND",
        message: error.message,
      },
    });
  }

  if (error instanceof PlacementValidationError) {
    return res.status(400).json({
      error: {
        code: "PLACEMENT_VALIDATION_ERROR",
        message: error.message,
      },
    });
  }

  console.error("Error no controlado:", error);

  return res.status(500).json({
    error: {
      code: "INTERNAL_ERROR",
      message: "Ocurrió un error interno en el servidor",
    },
  });
};
