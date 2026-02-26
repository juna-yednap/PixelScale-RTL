# 🖼️ PixelScale-RTL
### Hardware Image Upscaler & Downscaler using Bi-Linear Interpolation (Verilog)

PixelScale-RTL is a high-performance hardware image rescaling engine implemented in **Verilog**. It supports both upscaling and downscaling using **bi-linear interpolation**, optimized for FPGA and ASIC synthesis.

The design focuses on architectural efficiency by implementing a **4-stage pipeline** exclusively for the weight calculation logic, paired with an **accumulator** to keep resource usage low while maintaining high throughput.

---

## 📌 Features

- ✅ **Bidirectional Scaling:** Full support for image upscaling and downscaling.
- ✅ **Bilinear Interpolation:** High-quality smoothing compared to nearest-neighbor.
- ✅ **Targeted 4-Stage Pipeline:** Optimized specifically for the four interpolation weights.
- ✅ **Accumulator Efficiency:** Uses an accumulation register to sum pixel products, reducing DSP/LUT overhead.
- ✅ **Parallel RGB Processing:** R, G, and B channels are processed in parallel for 1-pixel-per-cycle output.

---

## 🧠 Algorithm & Optimization

### 1. Scaling Ratio Computation
The system uses parallel multicycle dividers to determine the input-to-output mapping ratio:
- $W_{ratio} = W_{in} / W_{out}$
- $H_{ratio} = H_{in} / H_{out}$

### 2. Pipelined Weight Generation
To maintain a high clock frequency, the logic for calculating the four interpolation weights is broken into a **4-stage pipeline**:
- $W_{00} = (1-a)(1-b)$
- $W_{10} = a(1-b)$
- $W_{01} = (1-a)b$
- $W_{11} = ab$



### 3. Accumulator-Based Datapath
Instead of using a massive combinational multiplier tree, this design uses an **accumulator**. The four weighted pixel values are summed into a single register, allowing for:
- Reduced logic depth (higher $F_{max}$).
- Strategic multiplier reuse.
- Clean bit-width management before the final rounding/truncation.
