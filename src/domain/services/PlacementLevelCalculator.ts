import type { EnglishLevel } from "../entities/User.js";

const TOTAL_QUESTIONS = 12;

export function calculateEnglishLevel(correctAnswers: number): EnglishLevel {
  if (
    !Number.isInteger(correctAnswers) ||
    correctAnswers < 0 ||
    correctAnswers > TOTAL_QUESTIONS
  ) {
    throw new Error("El puntaje de placement no es válido");
  }

  if (correctAnswers <= 3) {
    return "A1";
  }

  if (correctAnswers <= 6) {
    return "A2";
  }

  if (correctAnswers <= 9) {
    return "B1";
  }

  return "B2";
}
