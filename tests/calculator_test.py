import os
import subprocess
from typing import List

def check_application(app: str, args: List[str], expected: str):
    proc = subprocess.run(
        [app, *args],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    code = proc.returncode

    if code < 0:
        print("\033[31m=== Error ===")
        print(f"Return code: {code};")
        print(f"Error message: {proc.stderr};\033[0m")

    output = proc.stdout

    print(f"Input: {args};")
    print(f"Output: {output}; Expected: {expected};")

    if output == expected:
        print("\033[32m=== Passed ===\033[0m")
    else:
        print("\033[31m=== Failed ===\033[0m")

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    calculator_app = script_dir + "/../bin/calculator"

    print("=== Negate ===")

    app_args: List[str] = [
        "-",
        "420"
    ]
    app_expected = "-420"
    check_application(calculator_app, app_args, app_expected)

    print("\n=== Not ===")

    app_args: List[str] = [
        "~",
        "420"
    ]
    app_expected = "-421"
    check_application(calculator_app, app_args, app_expected)

    print("\n=== Zeroes ===")

    app_args: List[str] = [
        "0",
        "+",
        "0"
    ]
    app_expected = "0"
    check_application(calculator_app, app_args, app_expected)

    print("\n=== Addition ===")

    app_args: List[str] = [
        "1337",
        "+",
        "420"
    ]
    app_expected = "1757"
    check_application(calculator_app, app_args, app_expected)

    print("\n=== Substitution ===")

    app_args: List[str] = [
        "1337",
        "-",
        "420"
    ]
    app_expected = "917"
    check_application(calculator_app, app_args, app_expected)

    print("\n=== Multiplication ===")

    app_args: List[str] = [
        "60",
        "*",
        "7"
    ]
    app_expected = "420"
    check_application(calculator_app, app_args, app_expected)

    print("\n=== Division Full ===")

    app_args: List[str] = [
        "500",
        "/",
        "9"
    ]
    app_expected = "55.55556"
    check_application(calculator_app, app_args, app_expected)

    print("\n=== Division Full 2 ===")

    app_args: List[str] = [
        "500",
        "/",
        "7"
    ]
    app_expected = "71.42857"
    check_application(calculator_app, app_args, app_expected)

    print("\n=== Division Partial ===")

    app_args: List[str] = [
        "500",
        "/",
        "2"
    ]
    app_expected = "250"
    check_application(calculator_app, app_args, app_expected)

    print("\n=== And ===")

    app_args: List[str] = [
        "12",
        "&",
        "10"
    ]
    app_expected = "8"
    check_application(calculator_app, app_args, app_expected)

    print("\n=== Or ===")

    app_args: List[str] = [
        "12",
        "|",
        "10"
    ]
    app_expected = "14"
    check_application(calculator_app, app_args, app_expected)

    print("\n=== Xor ===")

    app_args: List[str] = [
        "12",
        "^",
        "10"
    ]
    app_expected = "6"
    check_application(calculator_app, app_args, app_expected)

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
