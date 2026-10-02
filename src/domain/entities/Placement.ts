import type { EnglishLevel } from "./User.js";

export interface PlacementOption {
  id: string;
  text: string;
}

export interface PlacementQuestion {
  id: string;
  prompt: string;
  options: PlacementOption[];

  // Este campo nunca se envía a Flutter ni Postman.
  // Solo lo usa el backend al evaluar el test.
  correctOptionId: string;
}

export interface PlacementQuestionForClient {
  id: string;
  prompt: string;
  options: PlacementOption[];
}

export interface PlacementAnswer {
  questionId: string;
  optionId: string;
}

export interface PlacementResult {
  roleId: string;
  englishLevel: EnglishLevel;
  correctAnswers: number;
  totalQuestions: number;
}
