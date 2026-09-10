import { NextFunction, Request, Response } from "express";
import { auth } from "../../infrastructure/firebase/firebase-admin.config.js";

export async function authenticate(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  const authorizationHeader = req.headers.authorization;

  if (!authorizationHeader?.startsWith("Bearer ")) {
    res.status(401).json({
      error: {
        code: "UNAUTHORIZED",
        message: "Se requiere un token Bearer válido",
      },
    });

    return;
  }

  const token = authorizationHeader.substring("Bearer ".length);

  if (!token) {
    res.status(401).json({
      error: {
        code: "UNAUTHORIZED",
        message: "El token no puede estar vacío",
      },
    });

    return;
  }

  try {
    const decodedToken = await auth.verifyIdToken(token);

    req.auth = {
      uid: decodedToken.uid,
      email: decodedToken.email ?? null,
      displayName: decodedToken.name ?? null,
    };

    next();
  } catch (error) {
    console.error("Token de Firebase inválido:", error);

    res.status(401).json({
      error: {
        code: "UNAUTHORIZED",
        message: "El token es inválido o expiró",
      },
    });
  }
}
