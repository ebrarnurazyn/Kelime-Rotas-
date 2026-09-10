import {
  CLASS_CODE_ALPHABET,
  CLASS_CODE_LENGTH,
  CLASS_CODE_MAX_GENERATION_ATTEMPTS,
} from "./constants";
import { db } from "./db";

function randomClassCode(): string {
  let code = "";
  for (let i = 0; i < CLASS_CODE_LENGTH; i += 1) {
    const index = Math.floor(Math.random() * CLASS_CODE_ALPHABET.length);
    code += CLASS_CODE_ALPHABET[index];
  }
  return code;
}

export async function generateUniqueClassCode(): Promise<string> {
  for (let attempt = 0; attempt < CLASS_CODE_MAX_GENERATION_ATTEMPTS; attempt += 1) {
    const candidate = randomClassCode();
    const existing = await db.class.findUnique({ where: { code: candidate } });
    if (!existing) {
      return candidate;
    }
  }
  throw new Error("Sınıf kodu üretilemedi, tekrar deneyin.");
}
