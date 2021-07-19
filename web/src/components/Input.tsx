import React, {DetailedHTMLProps, InputHTMLAttributes} from "react";

export type InputProps = DetailedHTMLProps<
  InputHTMLAttributes<HTMLInputElement>,
  HTMLInputElement
>;

const Input: React.FC<InputProps> = ({className, ...props}) => {
  return (
    <input
      type="text"
      {...props}
      className={`h-10 w-full border-2 border-indigo-400 text-indigo-400 px-2 ${className}`}
    ></input>
  );
};

export default Input;
