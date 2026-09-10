import Link from "next/link";
import { HOME_TEXTS } from "./constants";
import { APP_ROUTES } from "./src/frontend/constants/routes";
import styles from "./page.module.css";

export default function HomePage() {
  return (
    <main className={styles.shell}>
      <div className={styles.brandmark} aria-hidden="true">
        <svg
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth={2}
          strokeLinecap="round"
          strokeLinejoin="round"
          width={30}
          height={30}
        >
          <circle cx={12} cy={12} r={9} />
          <polygon points="12 7 15 12 12 17 9 12" />
        </svg>
      </div>
      <h1 className={styles.title}>{HOME_TEXTS.appName}</h1>
      <p className={styles.tagline}>{HOME_TEXTS.tagline}</p>
      <div className={styles.choices}>
        <Link className={styles.choice} href={APP_ROUTES.pages.teacherHome}>
          <div className={styles.choiceTitle}>{HOME_TEXTS.teacherChoiceTitle}</div>
          <div className={styles.choiceDescription}>{HOME_TEXTS.teacherChoiceDescription}</div>
        </Link>
        <Link className={styles.choice} href={APP_ROUTES.pages.studentHome}>
          <div className={styles.choiceTitle}>{HOME_TEXTS.studentChoiceTitle}</div>
          <div className={styles.choiceDescription}>{HOME_TEXTS.studentChoiceDescription}</div>
        </Link>
      </div>
    </main>
  );
}
