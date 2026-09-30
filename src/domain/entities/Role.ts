export interface Role {
  id: string;
  name: string;
  description: string;

  // Clave que flutter transforma en un icono visual.
  // Ejemplo: "Code", "Cloud", "bug" .
  iconKey: String;

  // Permite ocultar roles sin borrar historial de usuarios.
  isActive: boolean;

  // Posición en la lista que verá el usuario.
  order: number;
}
