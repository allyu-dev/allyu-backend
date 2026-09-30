export class RoleNotFoundError extends Error {
  constructor() {
    super("Rol no encontrado o no disponible");
    this.name = "RoleNotFoundError";
  }
}
