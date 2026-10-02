library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.aes128_header.all;

entity aes128_block is

  port ( plaintext  : in  oword;
         cipherkey  : in  oword;
         ciphertext : out oword);

end entity aes128_block;

architecture behavioral of aes128_block is

  type state_array is array (10 downto 0) of byte_matrix;

  component key_generator is
    port ( cipherkey : in  oword;
           roundkeys : out oword_array);
  end component key_generator;

  component cipher_round is
    port ( state_in  : in  byte_matrix;
           roundkey  : in  oword;
           state_out : out byte_matrix);
  end component cipher_round;

  component sub_matrix is
    port ( mat_in  : in  byte_matrix;
           mat_out : out byte_matrix);
  end component sub_matrix;

  function cv_oword ( input : byte_matrix)
    return std_logic_vector is
  begin
    return input(0)(0) & input(0)(1) & input(0)(2) & input(0)(3) &
           input(1)(0) & input(1)(1) & input(1)(2) & input(1)(3) &
           input(2)(0) & input(2)(1) & input(2)(2) & input(2)(3) &
           input(3)(0) & input(3)(1) & input(3)(2) & input(3)(3) ;
  end function cv_oword;

  signal cipher_state  : state_array;
  signal roundkeys   : oword_array;

begin

  -- Generate roundkeys for all rounds.
  kg : key_generator
    port map (
      cipherkey => cipherkey,
      roundkeys => roundkeys);

  -- SubBytes for last round.
  lbm : sub_matrix
    port map (
      mat_in  => cipher_state(9),
      mat_out => cipher_state(10));

  -- Perform round 1 to round 9.
  gen_cr : for i in 1 to 9 generate
    cr: cipher_round
      port map (
        state_in  => cipher_state(i-1),
        roundkey  => roundkeys(i),
        state_out => cipher_state(i));
  end generate gen_cr;

  -- Perform round 0.
  cipher_state(0) <= cv_byte_matrix(roundkeys(0) xor plaintext);

  -- Perform round 10.
  ciphertext <= cv_oword(shift_rows(cipher_state(10)) xor roundkeys(10));

end architecture behavioral;
