from PIL import Image

# -------- CONFIG --------
HEX_FILE = "../RTL/image.hex"    # input hex file
OUT_IMG  = "in.png"    # output image
WIDTH    = 64        # image width  (W_out)
HEIGHT   = 64           # image height (H_out)
# -----------------------

pixels = []

with open(HEX_FILE, "r") as f:
    for line in f:
        line = line.strip()

        # Skip comments and empty lines
        if not line or line.startswith("//"):
            continue

        # Handle uninitialized values (xx)
        if "x" in line.lower():
            pixels.append(0)
        else:
            pixels.append(int(line, 16))

# Ensure enough pixels
assert len(pixels) >= WIDTH * HEIGHT, "Not enough pixel data in hex file"

# Trim to exact size
pixels = pixels[:WIDTH * HEIGHT]

# Create grayscale image
img = Image.new("L", (WIDTH, HEIGHT))
img.putdata(pixels)

img.save(OUT_IMG)
print(f"Saved image to {OUT_IMG}")
