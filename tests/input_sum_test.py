import os
import subprocess

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    input_sum_app = script_dir + "/../bin/input_sum"

    input_sum_args: List[str] = [
        "1337",
        "420",
        "-69",
        "4l",
        "-92f4"
        "d",
        "0",
        "-0"
    ]

    input_sum_output = "1600"

    input_sum_proc = subprocess.run(
        [input_sum_app, *input_sum_args],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    print("Input: " + str(input_sum_args))
    print("Output: " + input_sum_proc.stdout)
    print("Expected: " + input_sum_output)

    is_equal = input_sum_output == input_sum_proc.stdout
    print("Is equal: " + str(is_equal))

    return is_equal


if __name__ == "__main__":
    raise SystemExit(main())