from PIL import Image

# ==========================
# SETTINGS
# ==========================
hex_file =  "abc.hex"      # your hex file
output_image = "output.png" # output image name
width = 128
height = 128

# ==========================
# READ HEX FILE
# ==========================
with open(hex_file, "r") as f:
    lines = [line.strip() for line in f if line.strip()]

# Detect format
sample = lines[0]

# ==========================
# RGB MODE
# ==========================
if len(sample) == 6:
    mode = "RGB"
    pixels = []

    for line in lines:
        r = int(line[0:2], 16)
        g = int(line[2:4], 16)
        b = int(line[4:6], 16)
        pixels.append((r, g, b))

# ==========================
# GRAYSCALE MODE
# ==========================
elif len(sample) == 2:
    mode = "L"
    pixels = [int(line, 16) for line in lines]

else:
    raise ValueError("HEX format not recognized")

# ==========================
# CREATE IMAGE
# ==========================
img = Image.new(mode, (width, height))
img.putdata(pixels)
img.save(output_image)

print("Image saved as:", output_image)