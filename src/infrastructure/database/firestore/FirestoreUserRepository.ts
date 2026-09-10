import {
  EnglishLevel,
  UpdateUserProfileData,
  User,
} from "../../../domain/entities/User.js";
import { IUserRepository } from "../../../domain/repositories/IUserRepository.js";
import { db } from "../../firebase/firebase-admin.config.js";

export class FirestoreUserRepository implements IUserRepository {
  private readonly collection = db.collection("users");

  async findById(id: string): Promise<User | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    const data = doc.data()!;

    return {
      id: doc.id,
      email: data.email,
      displayName: data.displayName ?? null,
      roleId: data.roleId ?? null,
      englishLevel: data.englishLevel ?? null,
      xp: data.xp ?? 0,
      streak: data.streak ?? 0,
      lastActivityDate: data.lastActivityDate ?? null,
      createdAt: data.createdAt?.toDate() ?? new Date(),
      updatedAt: data.updatedAt?.toDate() ?? new Date(),
    };
  }

  async create(user: User): Promise<void> {
    await this.collection.doc(user.id).create({
      email: user.email,
      displayName: user.displayName,
      roleId: user.roleId,
      englishLevel: user.englishLevel,
      xp: user.xp,
      streak: user.streak,
      lastActivityDate: user.lastActivityDate,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    });
  }

  async updateProfile(
    id: string,
    data: UpdateUserProfileData,
    updatedAt: Date,
  ): Promise<User> {
    await this.collection.doc(id).update({
      displayName: data.displayName,
      updatedAt,
    });

    const updatedUser = await this.findById(id);

    if (!updatedUser) {
      throw new Error("Usuario no encontrado después de actualizarlo");
    }

    return updatedUser;
  }

  async updateRoleAndLevel(
    id: string,
    roleId: string,
    englishLevel: EnglishLevel,
    updatedAt: Date,
  ): Promise<void> {
    await this.collection.doc(id).update({
      roleId,
      englishLevel,
      updatedAt,
    });
  }

  async touchLastActivity(
    id: string,
    lastActivityDate: string,
    updatedAt: Date,
  ): Promise<void> {
    await this.collection.doc(id).update({
      lastActivityDate,
      updatedAt,
    });
  }
}
