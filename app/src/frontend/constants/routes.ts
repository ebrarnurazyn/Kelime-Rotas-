export const APP_ROUTES = {
  pages: {
    home: "/",
    teacherHome: "/teacher",
    teacherClassDetail: (classId: string) => `/teacher/classes/${classId}`,
    studentHome: "/student",
  },
  api: {
    teacherRegister: "/api/teacher/register",
    classes: "/api/classes",
    classStudents: (classId: string) => `/api/classes/${classId}/students`,
    studentJoin: "/api/student/join",
    studentState: "/api/student/state",
  },
} as const;
