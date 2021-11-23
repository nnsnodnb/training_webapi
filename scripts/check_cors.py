import argparse
import re
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--url", required=True, type=str)
args = parser.parse_args()


def main() -> None:
    if re.search(r"^http(|s)://(localhost|127.0.0.1):\d+$", args.url) is None:
        print("Not Supported")
        sys.exit(1)
    else:
        print("Supported")


if __name__ == "__main__":
    main()
