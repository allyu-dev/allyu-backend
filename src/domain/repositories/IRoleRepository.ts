import { Role } from "../entities/Role.js";

export interface IRoleRepository {
  findActive(): Promise<Role[]>;
  //
  findById(id: string): Promise<Role | null>;
}
