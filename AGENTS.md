# advanced-encryption-standard

## Overview

VHDL implementation of AES-128 encryption. `aes128_block` is a combinational datapath: it expands a 128-bit key into the eleven round keys, runs the ten AES rounds, and drives a 128-bit ciphertext. `mm_bus_aes128` wraps that datapath in an Avalon Memory-Mapped slave so a host on the Terasic DE1-SoC can write the plaintext and key and read the ciphertext back.

The cipher is encryption only. Decryption, block-cipher modes, and padding are not in this repository. The Quartus Prime 18.1 project targets a Cyclone V `5CSEMA5F31C6` on the DE1-SoC, with top-level entity `mm_bus_aes128`.

The four live testbenches are stimulus benches. They do not check expected values. Under GHDL 4.1.0 with `--syn-binding`, the datapath and the Avalon slave both produce ciphertext `29C3505F571420F6402299B31A02D73A` for the vector those benches apply. There is no continuous-integration workflow, and the FPGA project has not been compiled in the environment used to check these docs (Quartus Prime is not installed there). `aes128.qsf` still lists `aes128_clk.vhd`, and that file is not in the tree.

## Repository layout

Sources sit in the repository root. There is no source subdirectory, Makefile, or CI configuration.

| File | Role |
| --- | --- |
| `aes128_header.vhd` | Package `aes128_header`: `byte`, `dword`, `oword`, `byte_array`, `byte_matrix`, `oword_array`, `shift_rows`, the state/`std_logic_vector` `"xor"`, and the word/state conversions |
| `sbox.vhd` | AES S-box as a 256-byte lookup table (architecture `look_up_table`) |
| `sub_array.vhd` | SubBytes for one 4-byte column |
| `sub_matrix.vhd` | SubBytes for a 4×4 state |
| `mix_array.vhd` | MixColumns for one column, including the GF(2^8) doubling |
| `mix_matrix.vhd` | MixColumns for a state |
| `cipher_round.vhd` | One middle round: SubBytes, ShiftRows, MixColumns, AddRoundKey |
| `key_generator.vhd` | AES-128 key expansion. Output `roundkeys` is an `oword_array` of eleven 128-bit keys, index 0 through 10 |
| `aes128_block.vhd` | Full encrypt datapath. Round 0 is AddRoundKey, rounds 1–9 are `cipher_round`, round 10 is SubBytes, ShiftRows, and AddRoundKey |
| `mm_bus_aes128.vhd` | Clocked Avalon-MM slave around `aes128_block`. This is the Quartus top level |
| `aes128_block_tb.vhd` | Stimulus bench, entity `aes128_block_tb` |
| `cipher_round_tb.vhd` | Stimulus bench, entity `cipher_round_tb` |
| `key_generator_tb.vhd` | Stimulus bench, entity `key_generator_tb` |
| `mm_bus_aes128_tb.vhd` | Stimulus bench, entity `tb_mm_bus_aes128` |
| `sbox_tb.vhd` | Commented out. Not a design unit |
| `mix_array_tb.vhd` | Commented out. Not a design unit |
| `aes128.qpf` | Quartus Prime project file, revision `aes128` |
| `aes128.qsf` | Quartus assignments: family, device, board, top level, and VHDL file list |
| `LICENSE` | MIT License |

`aes128_block` has no clock. The only clocked process is `accessMem` in `mm_bus_aes128`.

## Setup

Simulation was checked with GHDL 4.1.0, Ubuntu package `ghdl` (mcode backend):

```bash
sudo apt-get install ghdl
ghdl --version
```

An FPGA build needs Intel Quartus Prime 18.1 Standard Edition, the version recorded in `aes128.qpf` (`18.1.0 Build 625`). Quartus is not required to run the testbenches.

## Build, run and test

There is no build script. From the repository root, analyze the design and the four live benches, then run each bench. `--std=93` matches the sources. `--syn-binding` is required on the run: without it, GHDL 4.1.0 leaves the component instances unbound, warns `instance ... is not bound`, and the ciphertext stays `U`.

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

Checked with GHDL 4.1.0. Each `ghdl -r` command exits 0. The benches do not print a pass/fail line. They end on a bare `wait`, and GHDL stops once nothing else is scheduled. Each run also prints `NUMERIC_STD.TO_INTEGER: metavalue detected` warnings at time 0, because `sbox` indexes the lookup table while inputs are still uninitialized. The settled values are still valid.

`aes128_block_tb` applies plaintext `54776F204F6E65204E696E652054776F` and key `5468617473206D79204B756E67204675`. A VCD dump of that run shows ciphertext `29C3505F571420F6402299B31A02D73A`. Dump it with:

```bash
ghdl -r --std=93 --workdir=/tmp/aes128-work --syn-binding aes128_block_tb --vcd=/tmp/aes128-work/aes128_block_tb.vcd
```

The same ciphertext is what `tb_mm_bus_aes128` drives on `avs_s1_readdata` after the bus stimulus: `29C3505F`, `571420F6`, `402299B3`, `1A02D73A` at addresses `0x00` through `0x03`. The bench signal `result` does not collect those words; see Gotchas.

`ghdl -a` on `sbox_tb.vhd` or `mix_array_tb.vhd` exits 1 with `design file is empty (no design unit found)`. Leave them out of the analyze list.

Quartus Prime is how this project is meant to be synthesized: open `aes128.qpf`. That flow was not run here. The assignment file's top level is `mm_bus_aes128`, the device is `5CSEMA5F31C6`, the board is `DE1-SoC Board`, and the output directory is `output_files`. The file list includes `aes128_clk.vhd`, which is absent, so a compile of the project as checked in will not see that file.

## Code style and conventions

- VHDL-93. Use `ieee.std_logic_1164` and `ieee.numeric_std`. The tree does not use `std_logic_arith` or `std_logic_unsigned`.
- Shared types and the ShiftRows / AddRoundKey helpers belong in package `aes128_header`. Design units already do `library work; use work.aes128_header.all;`.
- A state is a `byte_matrix`: four columns, index `3 downto 0`, each a `byte_array` of four rows. Column 0 is bits `127 downto 96`. Inside a column, index 0 is the most significant byte. `shift_rows` leaves row 0 in place and rotates rows 1, 2, and 3 left by one, two, and three bytes.
- Entity, signal, and port names are lowercase. Architectures already used are `behavioral`, `structural`, `look_up_table`, `behavior`, `waveform`, and `tb`. Match the file you are editing.
- Hierarchy is mostly component declarations plus component instantiation. `mix_matrix` and `mm_bus_aes128` instantiate with `entity work...`. Follow the file you are in.
- The encrypt core has no generics and no clock. Add a clock only on the Avalon wrapper, or in a new wrapper, rather than inside `aes128_block`.
- Design files are indented by two spaces. Several testbenches use tabs. Do not reformat a file you are not otherwise changing.
- `aes128.qsf` is generated by Quartus Prime, and its header says the tool overwrites the file. Testbenches are not in that file list. A new synthesizable source is compiled by GHDL only when the analyze command lists it, and by Quartus only when the project file list contains it.

## CI and tooling

There is no CI. The repository has no GitHub Actions workflow, Makefile, linter, or formatter.

The project tooling that is checked in is the Quartus Prime 18.1 project:

- Project file `aes128.qpf`, revision `aes128`, created 10:07:59 20 June 2019.
- Assignments in `aes128.qsf`: family `Cyclone V`, device `5CSEMA5F31C6`, board `DE1-SoC Board`, `TOP_LEVEL_ENTITY mm_bus_aes128`, `PROJECT_OUTPUT_DIRECTORY output_files`, `ORIGINAL_QUARTUS_VERSION 18.1.0`.
- No `output_files` directory is committed.

Local simulation tooling is GHDL, as run in Build, run and test.

## Working rules for agents

- Keep changes small and focused.
- Run the tests before committing. Use the GHDL commands in Build, run and test. A clean run exits 0 and still prints the `NUMERIC_STD` metavalue warnings.
- Never commit secrets. Do not commit `work-obj93.cf`, VCD dumps, or Quartus `output_files`.
- Update the docs when behaviour changes. Update `README.md` and this file together when ports, the register map, the simulate commands, or the project file list change.
- Use conventional commit messages.
- Keep `AGENTS.md`, `CLAUDE.md`, and `.github/copilot-instructions.md` in sync. `AGENTS.md` is canonical. The other two must be this file's text plus at most a one-line header noting that `AGENTS.md` is canonical. Do not replace those files with symlinks.

## Gotchas

- GHDL's default elaboration does not bind the component instances in this design. `ghdl -r` needs `--syn-binding`, or the hierarchy is empty and the ciphertext stays `U`. Quartus-style default binding is what the RTL was written for.
- `sbox_tb.vhd` and `mix_array_tb.vhd` are entirely comments. Analyzing either file fails.
- Nothing in the benches asserts the ciphertext. Exit code 0 means the bench elaborated and ran, not that a vector was checked. `cipher_round_tb` and `key_generator_tb` only drive inputs.
- In `mm_bus_aes128_tb.vhd` the entity name is `tb_mm_bus_aes128`. Pass that name to `ghdl -r`, not the filename.
- That same bench samples `avs_s1_readdata` into `result` in the stimulus process on the same delta cycle that raises the clock. `result` therefore stays at `Z` / the previous value. The slave port `avs_s1_readdata` itself does return the ciphertext words on the following delta. Read the port in a waveform if you need the bus result.
- `aes128.qsf` lists `aes128_clk.vhd`. That file is not in the repository.
- Writing address `0x08` sets `start` from bit 0 of the write data. `plaintext_out` and `cipherkey_out` update on the next rising edge of `csi_clockreset_clk`, and that edge clears `start`. The bus bench inserts one idle clock between the start write and the reads. The core is combinational, so the ciphertext is ready once those inputs update.
- Reset is asynchronous and active low (`csi_clockreset_reset_n`). It clears `start` and drives `avs_s1_readdata` to zero. The data registers in `mm_bus_aes128` are initialized to `'Z'`.
- `sbox` maps `byte_in` with `to_integer(unsigned(byte_in))`. Any `U`, `X`, or `Z` on that input produces a `NUMERIC_STD.TO_INTEGER` metavalue warning and index 0. Those warnings at time 0 are expected with the current benches.
- The S-box table in `sbox.vhd` is the standard AES S-box (256 bytes, `63` through `16`). Key expansion uses Rcon `01, 02, 04, 08, 10, 20, 40, 80, 1B, 36`. Changing either table, the column/row indexing, or the round-10 path (no MixColumns) changes the ciphertext.
