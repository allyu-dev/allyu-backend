import { User } from "../../../domain/entities/User.js";
import { IUserRepository } from "../../../domain/repositories/IUserRepository.js";

interface SyncUserData {
  id: string;
  email: string;
  displayName?: string | null;
}

interface SyncUserResult {
  user: User;
  isNewUser: boolean;
}

export class SyncUserUseCase {
  constructor(private readonly userRepository: IUserRepository) {}

  async execute(userData: SyncUserData): Promise<SyncUserResult> {
    const now = new Date();
    const lastActivityDate = now.toISOString().slice(0, 10);

    const existingUser = await this.userRepository.findById(userData.id);

    if (existingUser) {
      await this.userRepository.touchLastActivity(
        existingUser.id,
        lastActivityDate,
        now,
      );

      return {
        user: {
          ...existingUser,
          lastActivityDate,
          updatedAt: now,
        },
        isNewUser: false,
      };
    }

    const newUser: User = {
      id: userData.id,
      email: userData.email,
      displayName: userData.displayName?.trim() || null,
      roleId: null,
      englishLevel: null,
      xp: 0,
      streak: 0,
      lastActivityDate,
      createdAt: now,
      updatedAt: now,
    };

    await this.userRepository.create(newUser);

    return {
      user: newUser,
      isNewUser: true,
    };
  }
}
