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

    if code != 0:
        print("\033[31m=== Error ===")
        print(f"Return code: {code};")
        print(f"Error message: {proc.stderr};\033[0m")

    output = proc.stdout
    print(f"Input: {args};")
    print(f"Output: \"{output}\"; Expected: \"{expected}\";".translate({
        ord("\\"): "\\",
        ord("\n"): "\\n",
        ord("\r"): "\\r",
        ord("\t"): "\\t",
        ord("\v"): "\\v",
    }))

    if output == expected:
        print("\033[32m=== Passed ===\033[0m")
    else:
        print("\033[31m=== Failed ===\033[0m")

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    app = script_dir + "/../bin/print"

    print("\033[36m=== Literal ===\033[0m")

    app_args: List[str] = [
        "Test str"
    ]
    app_expected = "Test str"
    check_application(app, app_args, app_expected)

    print("\n\033[36m=== Line Feed ===\033[0m")

    app_args: List[str] = [
        "Hello\\nWorld"
    ]
    app_expected = "Hello\nWorld"
    check_application(app, app_args, app_expected)

    print("\n\033[36m=== Horizontal Tab ===\033[0m")

    app_args: List[str] = [
        "Hello\\tWorld"
    ]
    app_expected = "Hello\tWorld"
    check_application(app, app_args, app_expected)

    print("\n\033[36m=== Vertical Tab ===\033[0m")

    app_args: List[str] = [
        "Hello\\vWorld"
    ]
    app_expected = "Hello\vWorld"
    check_application(app, app_args, app_expected)

    print("\n\033[36m=== Empty Format ===\033[0m")

    app_args: List[str] = [
        "Progress 100%%"
    ]
    app_expected = "Progress 100%"
    check_application(app, app_args, app_expected)

    print("\n\033[36m=== Single Digit ===\033[0m")

    app_args: List[str] = [
        "Progress %d%%",
        "100"
    ]
    app_expected = "Progress 100%"
    check_application(app, app_args, app_expected)

    print("\n\033[36m=== Two Digits ===\033[0m")

    app_args: List[str] = [
        "Width: %d; Height: %d;",
        "800", "600"
    ]
    app_expected = "Width: 800; Height: 600;"
    check_application(app, app_args, app_expected)

    print("\n\033[36m=== String Arg ===\033[0m")

    app_args: List[str] = [
        "%s has %d flags",
        "Hacker", "3"
    ]
    app_expected = "Hacker has 3 flags"
    check_application(app, app_args, app_expected)

    print("\n\033[36m=== String with slashes ===\033[0m")

    app_args: List[str] = [
        "Text with slashes: %s",
        "LITERAL\\WITH\\SLASHES"
    ]
    app_expected = "Text with slashes: LITERAL\\WITH\\SLASHES"
    check_application(app, app_args, app_expected)

    print("\n\033[36m=== Hex literal ===\033[0m")

    app_args: List[str] = [
        "Symbol 1: \\x4c; Symbol 2: \\x6E; Symbol 3: \\x55;"
    ]
    app_expected = "Symbol 1: L; Symbol 2: n; Symbol 3: U;"
    check_application(app, app_args, app_expected)

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
