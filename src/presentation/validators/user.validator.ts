import { z } from "zod";

/**
 * Validador para la sincronización de usuario.
 * El endpoint no requiere datos en el body, ya que la
 * información se obtiene de la autenticación.
 */
export const syncUserSchema = z.object({}).strict();

export const updateMyProfileSchema = z
  .object({
    displayName: z
      .string()
      .trim()
      .min(2, "displayName debe tener al menos 2 caracteres")
      .max(60, "displayName no puede superar 60 caracteres")
      .nullable(),
  })
  .strict();
