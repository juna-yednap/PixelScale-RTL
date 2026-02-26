from PIL import Image
import numpy as np

# ---------- CONFIG ----------
INPUT_PNG  = "in.jpg"
OUTPUT_HEX = "../RTL/image.hex"
WIDTH      = 256     # set to None to keep original
HEIGHT     = 256
MODE       = "RGB"  # "RGB" or "GRAY"
# ----------------------------

# Load image
img = Image.open(INPUT_PNG)

# Convert image based on mode
if MODE == "RGB":
    img = img.convert("RGB")
elif MODE == "GRAY":
    img = img.convert("L")
else:
    raise ValueError("MODE must be 'RGB' or 'GRAY'")

# Optional resize
if WIDTH is not None and HEIGHT is not None:
    img = img.resize((WIDTH, HEIGHT), Image.BILINEAR)

# Convert to numpy
pixels = np.array(img, dtype=np.uint8)

# Write hex file
with open(OUTPUT_HEX, "w") as f:

    if MODE == "RGB":
        # pixels shape: (H, W, 3)
        H, W, _ = pixels.shape
        print(f"RGB Image size: {W} x {H}")

        for y in range(H):
            for x in range(W):
                r, g, b = pixels[y, x]
                f.write(f"{r:02x}\n")
                f.write(f"{g:02x}\n")
                f.write(f"{b:02x}\n")

    else:  # GRAY
        # pixels shape: (H, W)
        H, W = pixels.shape
        print(f"Grayscale Image size: {W} x {H}")

        for y in range(H):
            for x in range(W):
                f.write(f"{pixels[y, x]:02x}\n")

print(f"Hex file written: {OUTPUT_HEX}")
