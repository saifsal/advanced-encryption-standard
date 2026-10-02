# advanced-encryption-standard

AES-128 encryption in VHDL, with an Avalon Memory-Mapped slave for the Terasic DE1-SoC.

The core takes a 128-bit plaintext and a 128-bit key and produces a 128-bit ciphertext. The slave lets an Avalon host write those two blocks as 32-bit registers and read the ciphertext back. The Quartus Prime project targets the DE1-SoC's Cyclone V (`5CSEMA5F31C6`).

## Features

- AES-128 encrypt datapath (`aes128_block`): key expansion to eleven round keys, AddRoundKey, nine full rounds, and a final round without MixColumns.
- Standard AES S-box, stored as a 256-byte lookup table in `sbox.vhd`.
- MixColumns over GF(2^8), with the usual doubling reduction by `0x1B`, in `mix_array.vhd`.
- ShiftRows and the state helper functions in package `aes128_header`.
- Avalon-MM slave (`mm_bus_aes128`) with an asynchronous active-low reset. This is the Quartus top level.
- Quartus Prime 18.1 project for the DE1-SoC (`aes128.qpf`, `aes128.qsf`).

The datapath is combinational. Only the Avalon slave is clocked. Decryption, cipher modes, and padding are outside this design.

## Example

`aes128_block_tb.vhd` and `mm_bus_aes128_tb.vhd` both load this block. The plaintext bytes are the ASCII string `Two One Nine Two`, and the key bytes are the ASCII string `Thats my Kung Fu`.

| | Value |
| --- | --- |
| Plaintext | `54776F204F6E65204E696E652054776F` |
| Key | `5468617473206D79204B756E67204675` |
| Ciphertext | `29C3505F571420F6402299B31A02D73A` |

The ciphertext above is the value GHDL 4.1.0 produced for that stimulus with `--syn-binding`, on both `aes128_block.ciphertext` and the Avalon read data. The benches do not check it themselves.

## Prerequisites

- GHDL 4.1 or another VHDL-93 simulator, to run the testbenches. The commands below were run with GHDL 4.1.0 (Ubuntu package `ghdl`, mcode backend).
- Intel Quartus Prime 18.1 Standard Edition, to synthesize the DE1-SoC project. That version is the one recorded in `aes128.qpf`.

## Install

```bash
sudo apt-get install ghdl
ghdl --version
```

Install Quartus Prime from Intel if you are building for the FPGA. No other package install is required. There is no dependency lockfile.

## Usage

### Encrypt core

`aes128_block` has three 128-bit ports and no clock:

| Port | Direction | Meaning |
| --- | --- | --- |
| `plaintext` | in | Block to encrypt |
| `cipherkey` | in | 128-bit AES key |
| `ciphertext` | out | Encrypted block |

`plaintext` and `cipherkey` are `oword`, a subtype of `std_logic_vector(127 downto 0)` from `aes128_header`. The ciphertext updates combinationally when either input changes.

### Avalon-MM slave

`mm_bus_aes128` is a clocked slave. The host clock is `csi_clockreset_clk`. `csi_clockreset_reset_n` is an asynchronous active-low reset. Accesses use `avs_s1_chipselect`, `avs_s1_read`, `avs_s1_write`, an 8-bit `avs_s1_address`, and 32-bit write and read data.

| Address | Write | Read |
| --- | --- | --- |
| `0x00` | `plaintext(127 downto 96)` | `ciphertext(127 downto 96)` |
| `0x01` | `plaintext(95 downto 64)` | `ciphertext(95 downto 64)` |
| `0x02` | `plaintext(63 downto 32)` | `ciphertext(63 downto 32)` |
| `0x03` | `plaintext(31 downto 0)` | `ciphertext(31 downto 0)` |
| `0x04` | `cipherkey(127 downto 96)` | `0` |
| `0x05` | `cipherkey(95 downto 64)` | `0` |
| `0x06` | `cipherkey(63 downto 32)` | `0` |
| `0x07` | `cipherkey(31 downto 0)` | `0` |
| `0x08` | bit 0 starts encryption | `0` |
| any other | ignored | `0` |

Write the four plaintext words and the four key words, then write `1` to address `0x08`. On the next rising clock the slave copies those registers onto the core and clears the start bit. The core has no pipeline register, so the ciphertext can be read on later clocks. `mm_bus_aes128_tb.vhd` does exactly that sequence for the example above, with 25 ns high and 25 ns low on the clock.

## Configuration

The RTL has no generics and no configuration file.

The FPGA configuration lives in `aes128.qsf`:

- Family `Cyclone V`, device `5CSEMA5F31C6`, board `DE1-SoC Board`.
- Top-level entity `mm_bus_aes128`.
- Project output directory `output_files` (not committed).
- VHDL file list for the synthesizable sources. The testbenches are not in that list.

`aes128.qsf` also names `aes128_clk.vhd`. That file is not in the repository.

## Development and testing

From the repository root:

```bash
mkdir -p /tmp/aes128-work
ghdl -a --std=93 --workdir=/tmp/aes128-work \
  aes128_header.vhd \
  sbox.vhd \
  sub_array.vhd \
  sub_matrix.vhd \
  mix_array.vhd \
  mix_matrix.vhd \
  cipher_round.vhd \
  key_generator.vhd \
  aes128_block.vhd \
  mm_bus_aes128.vhd \
  aes128_block_tb.vhd \
  cipher_round_tb.vhd \
  key_generator_tb.vhd \
  mm_bus_aes128_tb.vhd

ghdl -r --std=93 --workdir=/tmp/aes128-work --syn-binding aes128_block_tb
ghdl -r --std=93 --workdir=/tmp/aes128-work --syn-binding cipher_round_tb
ghdl -r --std=93 --workdir=/tmp/aes128-work --syn-binding key_generator_tb
ghdl -r --std=93 --workdir=/tmp/aes128-work --syn-binding tb_mm_bus_aes128
```

`--syn-binding` is required. Without it, GHDL 4.1.0 does not bind the component instances and the ciphertext stays unknown. The work library is `/tmp/aes128-work` so GHDL's `work-obj93.cf` stays out of the tree.

All four runs exit 0. They also print `NUMERIC_STD.TO_INTEGER: metavalue detected` at time 0, while the S-box still sees uninitialized inputs. There is no assertion, so a zero exit code means the bench ran. To inspect the datapath result:

```bash
ghdl -r --std=93 --workdir=/tmp/aes128-work --syn-binding aes128_block_tb --vcd=/tmp/aes128-work/aes128_block_tb.vcd
```

`sbox_tb.vhd` and `mix_array_tb.vhd` are commented out. `ghdl -a` rejects each of them with `design file is empty`. The bus bench's entity is `tb_mm_bus_aes128`.

Open `aes128.qpf` in Quartus Prime 18.1 to synthesize. That compile was not run in the environment used to check this README.

Source layout, coding conventions, and simulator quirks are written up in `AGENTS.md`.

## Project status

The repository contains a working AES-128 encrypt core and its Avalon-MM wrapper, plus waveform testbenches for the core, one cipher round, key expansion, and the slave. The Quartus project was created on 20 June 2019 with Quartus Prime 18.1.0.

Still open in the tree itself: the two commented-out unit benches, the missing `aes128_clk.vhd` named by `aes128.qsf`, and the lack of self-checking assertions. The repository does not include a roadmap.

## Licence

MIT License. Copyright (c) 2026 saifsal. See [LICENSE](LICENSE).
