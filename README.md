# Verilog LDPC Decoder for 802.11ay

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A fully synthesizable Verilog implementation of an LDPC decoder compliant with the IEEE 802.11ay standard. This repository provides the decoder for rate 1/2 with a codeword length of 672.

The core is implemented in SystemVerilog/Verilog and verified using a Python-based `cocotb` testbench.

## Key Features

* **Standard Compliant:** Implements the LDPC code specified in IEEE 802.11ay (which reuses the 802.11ad code).
* **Algorithm:** Uses the Layered Belief Propagation (LBP) algorithm for fast convergence.
* **Configurable:** Easily adaptable for different numbers of iterations.

### Decoding Performance
TODO: add BER and hardware utilisation


## Getting Started

### Prerequisites

* [Icarus Verilog](https://github.com/steveicarus/iverilog) (for simulation)
* [Python 3.8+](https://www.python.org/) with `cocotb` and `numpy`
* [Vivado](https://www.xilinx.com/products/design-tools/vivado.html) (for synthesis)

### Installation

1.  Clone the repository:
    ```sh
    git clone [https://github.com/your-username/LDPC-decoder-802.11ay.git](https://github.com/your-username/LDPC-decoder-802.11ay.git)
    cd LDPC-decoder-802.11ay
    ```

2.  Install Python dependencies:
    ```sh
    pip install cocotb numpy
    ```

### Running the Simulation

To run the basic `cocotb` verification test:

```sh
make sim
```
*(You will need to create a `Makefile` for this to work, which is standard for cocotb projects).*

## License

This project is licensed under the MIT License.

## Contact
For inquiries about other coding rates or commercial licensing, please contact me at mehdimoore@hotmail.com.
