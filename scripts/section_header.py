import sys

if len(sys.argv) < 2:
    print("Usage: python section_header.py <header_text>")
    sys.exit(1)
else:
    print("//" * 32)
    print("//" + " ".join(sys.argv[1:]).center(60) + "//")
    print("//" * 32)
