from PIL import Image

# -------- CONFIG --------
IMAGE_PATH = "../RTL/input.png"   # input image
OUT_FILE   = "../RTL/image.hex"   # output hex file
WIDTH      = 200           # must match W_in
HEIGHT     = 200           # must match H_in
# ------------------------

# Load image
img = Image.open(IMAGE_PATH).convert("L")  # grayscale
img = img.resize((WIDTH, HEIGHT))

pixels = list(img.getdata())

# Write hex file
with open(OUT_FILE, "w") as f:
    for p in pixels:
        f.write(f"{p:02x}\n")

print(f"Written {WIDTH*HEIGHT} pixels to {OUT_FILE}")
