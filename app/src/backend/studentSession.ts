import { SignJWT, jwtVerify } from "jose";
import { cookies } from "next/headers";
import { STUDENT_SESSION_COOKIE_NAME, STUDENT_SESSION_MAX_AGE_SECONDS } from "./constants";

function getSecretKey() {
  const secret = process.env.STUDENT_SESSION_SECRET;
  if (!secret) {
    throw new Error("STUDENT_SESSION_SECRET tanımlı değil.");
  }
  return new TextEncoder().encode(secret);
}

export async function createStudentSessionCookie(studentId: string): Promise<void> {
  const token = await new SignJWT({ studentId })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(`${STUDENT_SESSION_MAX_AGE_SECONDS}s`)
    .sign(getSecretKey());

  const cookieStore = await cookies();
  cookieStore.set(STUDENT_SESSION_COOKIE_NAME, token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    maxAge: STUDENT_SESSION_MAX_AGE_SECONDS,
    path: "/",
  });
}

export async function getStudentIdFromSession(): Promise<string | null> {
  const cookieStore = await cookies();
  const token = cookieStore.get(STUDENT_SESSION_COOKIE_NAME)?.value;
  if (!token) {
    return null;
  }

  try {
    const { payload } = await jwtVerify(token, getSecretKey());
    return typeof payload.studentId === "string" ? payload.studentId : null;
  } catch {
    return null;
  }
}

export async function clearStudentSessionCookie(): Promise<void> {
  const cookieStore = await cookies();
  cookieStore.delete(STUDENT_SESSION_COOKIE_NAME);
}
