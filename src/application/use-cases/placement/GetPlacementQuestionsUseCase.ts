import type { PlacementQuestionForClient } from "../../../domain/entities/Placement.js";
import { getPlacementQuestions } from "../../data/placementQuestions.js";

export class GetPlacementQuestionsUseCase {
  async execute(): Promise<PlacementQuestionForClient[]> {
    return getPlacementQuestions();
  }
}
