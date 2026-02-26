from PIL import Image

# -------- CONFIG --------
HEX_FILE = "../RTL/res.hex"   # input hex file
OUT_IMG  = "out.png"         # output image
WIDTH    = 512            # image width
HEIGHT   = 512         # image height
MODE     = "RGB"             # "RGB" or "GRAY"
# ------------------------

values = []

with open(HEX_FILE, "r") as f:
    for line in f:
        line = line.strip()

        # Skip comments and empty lines
        if not line or line.startswith("//"):
            continue

        # Handle uninitialized values (xx)
        if "x" in line.lower():
            values.append(0)
        else:
            values.append(int(line, 16))

# ----------------- MODE HANDLING -----------------

if MODE == "RGB":
    required = WIDTH * HEIGHT * 3
    assert len(values) >= required, "Not enough RGB data in hex file"

    values = values[:required]

    # Group into (R, G, B)
    pixels = []
    for i in range(0, len(values), 3):
        pixels.append((values[i], values[i + 1], values[i + 2]))

    img = Image.new("RGB", (WIDTH, HEIGHT))
    img.putdata(pixels)

elif MODE == "GRAY":
    required = WIDTH * HEIGHT
    assert len(values) >= required, "Not enough grayscale data in hex file"

    values = values[:required]

    img = Image.new("L", (WIDTH, HEIGHT))
    img.putdata(values)

else:
    raise ValueError("MODE must be 'RGB' or 'GRAY'")

# -------------------------------------------------

img.save(OUT_IMG)
print(f"Saved {MODE} image to {OUT_IMG}")
