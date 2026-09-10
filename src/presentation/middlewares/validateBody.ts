import { NextFunction, Request, Response } from "express";
import { z } from "zod";

/**
 * Middleware genérico para validar el body de una solicitud
 * utilizando un esquema de Zod.
 */
export function validateBody(schema: z.ZodType) {
    
  return (req: Request, res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req.body);

    if (!result.success) {
      res.status(400).json({
        error: {
          code: "VALIDATION_ERROR",
          message: "El body de la solicitud no es válido",
          details: result.error.issues.map((issue) => ({
            field: issue.path.join(".") || "body",
            message: issue.message,
          })),
        },
      });

      return;
    }

    req.body = result.data;

    next();
  };
}
