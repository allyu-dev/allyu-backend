import { UserNotFoundError } from "../../../domain/errors/UserNotFoundError.js";
import { User } from "../../../domain/entities/User.js";
import { IUserRepository } from "../../../domain/repositories/IUserRepository.js";

export class GetMyProfileUseCase {
  constructor(private readonly userRepository: IUserRepository) {}

  async execute(id: string): Promise<User> {
    const user = await this.userRepository.findById(id);

    if (!user) {
      throw new UserNotFoundError();
    }

    return user;
  }
}
