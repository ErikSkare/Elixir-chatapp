import React, {ButtonHTMLAttributes, DetailedHTMLProps} from "react";

export type ButtonProps = DetailedHTMLProps<
  ButtonHTMLAttributes<HTMLButtonElement>,
  HTMLButtonElement
>;

const Button: React.FC<ButtonProps> = ({children, className, ...props}) => {
  return (
    <button
      type="submit"
      {...props}
      className={`w-full h-10 bg-pink-800 text-gray-50 text-md font-semibold cursor-pointer ${className}`}
    >
      {children}
    </button>
  );
};

export default Button;
