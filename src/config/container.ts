import { GetMyProfileUseCase } from "../application/use-cases/auth/GetMyProfileUseCase.js";
import { SyncUserUseCase } from "../application/use-cases/auth/SyncUserUseCase.js";
import { UpdateMyProfileUseCase } from "../application/use-cases/auth/UpdateMyProfileUseCase.js";
import { FirestoreUserRepository } from "../infrastructure/database/firestore/FirestoreUserRepository.js";

const userRepository = new FirestoreUserRepository();

export const container = {
  syncUserUseCase: new SyncUserUseCase(userRepository),
  getMyProfileUseCase: new GetMyProfileUseCase(userRepository),
  updateMyProfileUseCase: new UpdateMyProfileUseCase(userRepository),
};
