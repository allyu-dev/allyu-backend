import { PlacementValidationError } from "../../../domain/errors/PlacementValidationError.js";
import { RoleNotFoundError } from "../../../domain/errors/RoleNotFoundError.js";
import { UserNotFoundError } from "../../../domain/errors/UserNotFoundError.js";
import type {
  PlacementAnswer,
  PlacementResult,
} from "../../../domain/entities/Placement.js";
import type { IRoleRepository } from "../../../domain/repositories/IRoleRepository.js";
import type { IUserRepository } from "../../../domain/repositories/IUserRepository.js";
import { calculateEnglishLevel } from "../../../domain/services/PlacementLevelCalculator.js";
import { getPlacementQuestionsForEvaluation } from "../../data/placementQuestions.js";

interface EvaluatePlacementTestInput {
  userId: string;
  roleId: string;
  answers: PlacementAnswer[];
}

export class EvaluatePlacementTestUseCase {
  constructor(
    private readonly userRepository: IUserRepository,
    private readonly roleRepository: IRoleRepository,
  ) {}

  async execute(input: EvaluatePlacementTestInput): Promise<PlacementResult> {
    const user = await this.userRepository.findById(input.userId);

    if (!user) {
      throw new UserNotFoundError();
    }

    const role = await this.roleRepository.findById(input.roleId);

    if (!role || !role.isActive) {
      throw new RoleNotFoundError();
    }

    const questions = getPlacementQuestionsForEvaluation();

    this.validateAnswers(input.answers, questions);

    const answersByQuestionId = new Map(
      input.answers.map((answer) => [answer.questionId, answer.optionId]),
    );

    const correctAnswers = questions.reduce(
      (total, question) =>
        answersByQuestionId.get(question.id) === question.correctOptionId
          ? total + 1
          : total,
      0,
    );

    const englishLevel = calculateEnglishLevel(correctAnswers);

    await this.userRepository.updateRoleAndLevel(
      user.id,
      role.id,
      englishLevel,
      new Date(),
    );

    return {
      roleId: role.id,
      englishLevel,
      correctAnswers,
      totalQuestions: questions.length,
    };
  }

  private validateAnswers(
    answers: PlacementAnswer[],
    questions: readonly {
      id: string;
      options: readonly { id: string }[];
    }[],
  ): void {
    if (answers.length !== questions.length) {
      throw new PlacementValidationError(
        `Debes responder las ${questions.length} preguntas del placement test`,
      );
    }

    const answersByQuestionId = new Map(
      answers.map((answer) => [answer.questionId, answer.optionId]),
    );

    if (answersByQuestionId.size !== answers.length) {
      throw new PlacementValidationError(
        "No puedes enviar respuestas duplicadas",
      );
    }

    for (const question of questions) {
      const selectedOptionId = answersByQuestionId.get(question.id);

      if (!selectedOptionId) {
        throw new PlacementValidationError(
          `Falta una respuesta para la pregunta ${question.id}`,
        );
      }

      const optionExists = question.options.some(
        (option) => option.id === selectedOptionId,
      );

      if (!optionExists) {
        throw new PlacementValidationError(
          `La opción seleccionada no es válida para la pregunta ${question.id}`,
        );
      }
    }
  }
}
