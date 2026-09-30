import type { Role } from "../../../domain/entities/Role.js";
import type { IRoleRepository } from "../../../domain/repositories/IRoleRepository.js";

export class ListRolesUseCase {
  constructor(private readonly roleRepository: IRoleRepository) {}

  async execute(): Promise<Role[]> {
    return this.roleRepository.findActive();
  }
}
