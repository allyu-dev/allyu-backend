export type EnglishLevel = "A1" | "A2" | "B1" | "B2";

export interface User {
  // Es el UID emitido por Firebase Authentication.
  id: string;

  // Viene del token verificado por Firebase.
  email: string;

  // El usuario puede editarlo después desde su perfil.
  displayName: string | null;

  // Se asignarán en el módulo de Placement.
  roleId: string | null;
  englishLevel: EnglishLevel | null;

  // Solo los actualiza el backend mediante el módulo de progreso.
  xp: number;
  streak: number;

  // Fecha de actividad en formato YYYY-MM-DD.
  // Ejemplo: "2026-09-02".
  lastActivityDate: string | null;

  createdAt: Date;
  updatedAt: Date;
}

export interface UpdateUserProfileData {
  displayName: string | null;
}
