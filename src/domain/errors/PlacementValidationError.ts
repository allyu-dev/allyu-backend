export class PlacementValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "PlacementValidationError";
  }
}
