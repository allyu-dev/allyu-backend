import { GetMyProfileUseCase } from "../application/use-cases/auth/GetMyProfileUseCase.js";
import { SyncUserUseCase } from "../application/use-cases/auth/SyncUserUseCase.js";
import { UpdateMyProfileUseCase } from "../application/use-cases/auth/UpdateMyProfileUseCase.js";
import { FirestoreUserRepository } from "../infrastructure/database/firestore/FirestoreUserRepository.js";
import { ListRolesUseCase } from "../application/use-cases/catalog/ListRolesUseCase.js";
import { FirestoreRoleRepository } from "../infrastructure/database/firestore/FirestoreRoleRepository.js";

const userRepository = new FirestoreUserRepository();
const roleRepository = new FirestoreRoleRepository();

export const container = {
  syncUserUseCase: new SyncUserUseCase(userRepository),
  getMyProfileUseCase: new GetMyProfileUseCase(userRepository),
  updateMyProfileUseCase: new UpdateMyProfileUseCase(userRepository),
  listRolesUseCase: new ListRolesUseCase(roleRepository),
};
