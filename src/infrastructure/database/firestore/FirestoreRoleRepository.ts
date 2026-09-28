import { DocumentData } from "firebase-admin/firestore";
import { Role } from "../../../domain/entities/Role.js";
import { IRoleRepository } from "../../../domain/repositories/IRoleRepository.js";
import { db } from "../../firebase/firebase-admin.config.js";

export class FirestoreRoleRepository implements IRoleRepository {
  private readonly collection = db.collection("roles");

  async findActive(): Promise<Role[]> {
    const snapshot = await this.collection.orderBy("order", "asc").get();

    return snapshot.docs
      .map((doc) => this.toRole(doc.id, doc.data()))
      .filter((role) => role.isActive);
  }

  async findById(id: string): Promise<Role | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return this.toRole(doc.id, doc.data()!);
  }

  private toRole(id: string, data: DocumentData): Role {
    return {
      id,
      name: data.name,
      description: data.description,
      iconKey: data.iconKey,
      isActive: data.isActive ?? false,
      order: data.order ?? 0,
    };
  }
}