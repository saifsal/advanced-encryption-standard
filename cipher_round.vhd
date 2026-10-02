library ieee;
use ieee.std_logic_1164.all;

library work;
use work.aes128_header.all;

entity cipher_round is
  port ( state_in  : in  byte_matrix;
         roundkey  : in  oword;
         state_out : out byte_matrix);
end entity cipher_round;

architecture behavioral of cipher_round is

  component sub_matrix is
    port ( mat_in  : in  byte_matrix;
           mat_out : out byte_matrix);
  end component sub_matrix;

  component mix_matrix is
    port ( mat_in  : in  byte_matrix;
           mat_out : out byte_matrix);
  end component mix_matrix;

  -- Intermediate states
  signal sub_matrix_out : byte_matrix;
  signal shift_rows_out : byte_matrix;
  signal mix_matrix_out : byte_matrix;

begin

  sm : sub_matrix
    port map (
      mat_in => state_in,
      mat_out => sub_matrix_out);

  mm : mix_matrix
    port map (
      mat_in => shift_rows_out,
      mat_out => mix_matrix_out);

  shift_rows_out <= shift_rows(sub_matrix_out);
  state_out <= mix_matrix_out xor roundkey;

end architecture behavioral;
