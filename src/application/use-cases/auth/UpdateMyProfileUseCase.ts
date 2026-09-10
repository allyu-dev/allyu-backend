import { UserNotFoundError } from "../../../domain/errors/UserNotFoundError.js";
import { UpdateUserProfileData, User } from "../../../domain/entities/User.js";
import { IUserRepository } from "../../../domain/repositories/IUserRepository.js";

interface UpdateMyProfileInput {
  id: string;
  profile: UpdateUserProfileData;
}

export class UpdateMyProfileUseCase {
  constructor(private readonly userRepository: IUserRepository) {}

  async execute(input: UpdateMyProfileInput): Promise<User> {
    const user = await this.userRepository.findById(input.id);

    if (!user) {
      throw new UserNotFoundError();
    }

    return this.userRepository.updateProfile(
      input.id,
      input.profile,
      new Date(),
    );
  }
}
