import math

# ------------ CONFIG ------------
WIDTH  = 64   # must match W_in
HEIGHT = 64    # must match H_in
OUT_FILE = "../RTL/image.hex"

SHAPE = "ring"   # choose: square, rectangle, diagonal, cross,
                   #         checker, circle, ring, gradient
# --------------------------------


def write_hex(data):
    with open(OUT_FILE, "w") as f:
        for v in data:
            f.write(f"{v:02x}\n")
    print(f"Wrote {WIDTH*HEIGHT} pixels to {OUT_FILE}")


# -------- SHAPE GENERATORS --------

def square():
    data = []
    for y in range(HEIGHT):
        for x in range(WIDTH):
            if WIDTH//4 <= x < 3*WIDTH//4 and HEIGHT//4 <= y < 3*HEIGHT//4:
                data.append(0xFF)
            else:
                data.append(0x00)
    return data


def rectangle():
    data = []
    for y in range(HEIGHT):
        for x in range(WIDTH):
            if WIDTH//8 <= x < 7*WIDTH//8 and HEIGHT//3 <= y < 2*HEIGHT//3:
                data.append(0xFF)
            else:
                data.append(0x00)
    return data


def diagonal():
    data = []
    for y in range(HEIGHT):
        for x in range(WIDTH):
            data.append(0xFF if x == y else 0x00)
    return data


def cross():
    data = []
    for y in range(HEIGHT):
        for x in range(WIDTH):
            if x == WIDTH//2 or y == HEIGHT//2:
                data.append(0xFF)
            else:
                data.append(0x00)
    return data


def checker():
    data = []
    for y in range(HEIGHT):
        for x in range(WIDTH):
            if ((x//8) + (y//8)) & 1:
                data.append(0xFF)
            else:
                data.append(0x00)
    return data


def circle():
    cx = WIDTH // 2
    cy = HEIGHT // 2
    r  = min(WIDTH, HEIGHT) // 4

    data = []
    for y in range(HEIGHT):
        for x in range(WIDTH):
            if (x-cx)**2 + (y-cy)**2 <= r*r:
                data.append(0xFF)
            else:
                data.append(0x00)
    return data


def ring():
    cx = WIDTH // 2
    cy = HEIGHT // 2
    r1 = min(WIDTH, HEIGHT) // 4
    r2 = r1 + 4

    data = []
    for y in range(HEIGHT):
        for x in range(WIDTH):
            d = (x-cx)**2 + (y-cy)**2
            if r1*r1 <= d <= r2*r2:
                data.append(0xFF)
            else:
                data.append(0x00)
    return data


def gradient():
    data = []
    for y in range(HEIGHT):
        for x in range(WIDTH):
            data.append((x * 255) // (WIDTH - 1))
    return data


# -------- MAIN --------

if SHAPE == "square":
    img = square()
elif SHAPE == "rectangle":
    img = rectangle()
elif SHAPE == "diagonal":
    img = diagonal()
elif SHAPE == "cross":
    img = cross()
elif SHAPE == "checker":
    img = checker()
elif SHAPE == "circle":
    img = circle()
elif SHAPE == "ring":
    img = ring()
elif SHAPE == "gradient":
    img = gradient()
else:
    raise ValueError("Unknown shape")

write_hex(img)
