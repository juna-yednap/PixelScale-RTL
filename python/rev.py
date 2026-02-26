def read_hex_to_matrix(filename, width, height):
    with open(filename, "r") as f:
        lines = f.readlines()

    data = []
    for line in lines:
        line = line.strip()
        if not line or line.startswith("//"):
            continue
        if "x" in line.lower():   # skip xx
            data.append(None)
        else:
            data.append(int(line, 16))

    assert len(data) >= width * height, "Not enough data in hex file"

    matrix = []
    idx = 0
    for y in range(height):
        row = []
        for x in range(width):
            row.append(data[idx])
            idx += 1
        matrix.append(row)

    return matrix


# ------------------------
# Example usage
# ------------------------
if __name__ == "__main__":
    W = 8
    H = 8

    mat = read_hex_to_matrix("../RTL/res.hex", W, H)

    for row in mat:
        print(row)
