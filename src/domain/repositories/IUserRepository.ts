import { EnglishLevel, UpdateUserProfileData, User } from "../entities/User.js";

export interface IUserRepository {
  findById(id: string): Promise<User | null>;

  create(user: User): Promise<void>;

  updateProfile(
    id: string,
    data: UpdateUserProfileData,
    updatedAt: Date,
  ): Promise<User>;

  updateRoleAndLevel(
    id: string,
    roleId: string,
    englishLevel: EnglishLevel,
    updatedAt: Date,
  ): Promise<void>;

  touchLastActivity(
    id: string,
    lastActivityDate: string,
    updatedAt: Date,
  ): Promise<void>;
}
