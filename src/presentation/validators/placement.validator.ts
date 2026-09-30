import { z } from "zod";

export const evaluatePlacementSchema = z
  .object({
    roleId: z
      .string()
      .trim()
      .min(1, "roleId es requerido")
      .max(80, "roleId no puede superar 80 caracteres")
      .regex(
        /^[a-z0-9-]+$/,
        "roleId solo puede contener letras minúsculas, números y guiones",
      ),

    answers: z
      .array(
        z.object({
          questionId: z
            .string()
            .trim()
            .min(1, "questionId es requerido")
            .max(50, "questionId no puede superar 50 caracteres"),

          optionId: z
            .string()
            .trim()
            .min(1, "optionId es requerido")
            .max(20, "optionId no puede superar 20 caracteres"),
        }),
      )
      .min(1, "Debes enviar al menos una respuesta")
      .max(20, "No puedes enviar más de 20 respuestas"),
  })
  .strict();
