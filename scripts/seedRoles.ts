import { Role } from "../src/domain/entities/Role.js";
import { db } from "../src/infrastructure/firebase/firebase-admin.config.js";

const roles: Role[] = [
  {
    id: "software-engineer",
    name: "Software Engineer",
    description:
      "Desarrolla aplicaciones, escribe código y participa en revisiones técnicas.",
    iconKey: "code",
    isActive: true,
    order: 1,
  },
  {
    id: "devops-engineer",
    name: "DevOps Engineer",
    description:
      "Automatiza despliegues, infraestructura, observabilidad y operaciones.",
    iconKey: "cloud",
    isActive: true,
    order: 2,
  },
  {
    id: "qa-analyst",
    name: "QA Analyst",
    description:
      "Diseña pruebas, reporta defectos y asegura la calidad del software.",
    iconKey: "bug",
    isActive: true,
    order: 3,
  },
  {
    id: "data-ml-engineer",
    name: "Data / ML Engineer",
    description:
      "Construye pipelines de datos, modelos y soluciones de aprendizaje automático.",
    iconKey: "chart",
    isActive: true,
    order: 4,
  },
  {
    id: "systems-network-engineer",
    name: "Systems / Network Engineer",
    description:
      "Administra sistemas, redes, conectividad y servicios de infraestructura.",
    iconKey: "network",
    isActive: true,
    order: 5,
  },
  {
    id: "cybersecurity-analyst",
    name: "Cybersecurity Analyst",
    description:
      "Analiza riesgos, incidentes y controles de seguridad informática.",
    iconKey: "shield",
    isActive: true,
    order: 6,
  },
];

async function seedRoles(): Promise<void> {
  const batch = db.batch();

  for (const role of roles) {
    const roleReference = db.collection("roles").doc(role.id);

    batch.set(roleReference, role, { merge: true });
  }

  await batch.commit();

  console.log(`${roles.length} roles cargados correctamente.`);
}

seedRoles().catch((error) => {
  console.error("Error al cargar roles:", error);
  process.exit(1);
});