import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { readFileSync } from "fs";
import { resolve } from "path";

if (!getApps().length) {
  try {
    const serviceAccountPath = resolve(process.cwd(), "serviceAccountKey.json");
    const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, "utf8"));

    initializeApp({
      credential: cert(serviceAccount),
    });
    console.log("🔥 Firebase Admin inicializado correctamente.");
  } catch (error) {
    console.error("Error al inicializar Firebase Admin:", error);
    throw error;
  }
}

export const db = getFirestore();
export const auth = getAuth();
