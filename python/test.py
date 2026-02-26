from PIL import Image
import numpy as np
from skimage.metrics import peak_signal_noise_ratio, structural_similarity

# -------- CONFIG --------
REF_IMG   = "in.jpg"     # reference (ground truth)
TEST_IMG  = "out.png"    # RTL output
TARGET_W  = 512
TARGET_H  = 512
MODE      = "RGB"       # "RGB" or "GRAY"
# ------------------------

# ---------- Load reference ----------
if MODE == "RGB":
    ref = Image.open(REF_IMG).convert("RGB")
    ref = ref.resize((TARGET_W, TARGET_H), Image.BILINEAR)
    ref = np.array(ref, dtype=np.uint8)

elif MODE == "GRAY":
    ref = Image.open(REF_IMG).convert("L")
    ref = ref.resize((TARGET_W, TARGET_H), Image.BILINEAR)
    ref = np.array(ref, dtype=np.uint8)

else:
    raise ValueError("MODE must be 'RGB' or 'GRAY'")

# ---------- Load test image ----------
if MODE == "RGB":
    test = Image.open(TEST_IMG).convert("RGB")
    test = np.array(test, dtype=np.uint8)

else:  # GRAY
    test = Image.open(TEST_IMG).convert("L")
    test = np.array(test, dtype=np.uint8)

# ---------- Sanity check ----------
assert ref.shape == test.shape, \
    f"Shape mismatch: ref={ref.shape}, test={test.shape}"

# ---------- Metrics ----------
if MODE == "RGB":
    psnr = peak_signal_noise_ratio(ref, test, data_range=255)
    ssim = structural_similarity(
        ref, test, data_range=255, channel_axis=2
    )
else:
    psnr = peak_signal_noise_ratio(ref, test, data_range=255)
    ssim = structural_similarity(ref, test, data_range=255)

print(f"MODE : {MODE}")
print(f"PSNR : {psnr:.2f} dB")
print(f"SSIM : {ssim:.4f}")
