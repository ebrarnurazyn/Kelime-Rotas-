import type { ButtonHTMLAttributes, ReactNode } from "react";
import styles from "./Button.module.css";

type ButtonVariant = "primary" | "secondary" | "danger";

type Props = Readonly<
  {
    children: ReactNode;
    variant?: ButtonVariant;
    isPending?: boolean;
  } & ButtonHTMLAttributes<HTMLButtonElement>
>;

export function Button({
  children,
  variant = "primary",
  isPending = false,
  disabled,
  type = "button",
  className,
  ...rest
}: Props) {
  const classNames = [styles.button, styles[variant], className].filter(Boolean).join(" ");

  return (
    <button
      type={type}
      className={classNames}
      disabled={disabled || isPending}
      aria-busy={isPending}
      {...rest}
    >
      {children}
    </button>
  );
}
