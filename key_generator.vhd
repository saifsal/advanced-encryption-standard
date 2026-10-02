library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.aes128_header.all;

entity key_generator is
  port ( cipherkey : in  oword;
         roundkeys : out oword_array);
end entity key_generator;

architecture behavioral of key_generator is

  type table_array is array (0  to 9) of byte;

  type sub_array_type is array (9  downto 0) of byte_array;
  type rcon_array_type is array (9  downto 0) of byte_array;
  type key_array_type is array (43 downto 0) of byte_array;

  constant rcon_table : table_array
    := (x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"80", x"1B", x"36");

  function "xor" ( left  : byte_array;
                   right : byte_array)
    return byte_array is variable output : byte_array;
  begin
    output(0) := left(0) xor right(0);
    output(1) := left(1) xor right(1);
    output(2) := left(2) xor right(2);
    output(3) := left(3) xor right(3);
    return output;
  end function "xor";

  function cv_std_logic_vector ( input : byte_array)
    return std_logic_vector is
  begin
    return input(0) & input(1) & input(2) & input(3);
  end function cv_std_logic_vector;

  function cv_std_logic_vector (
    input0 : byte_array;
    input1 : byte_array;
    input2 : byte_array;
    input3 : byte_array)
    return std_logic_vector is
  begin
    return
      input0(0) & input0(1) & input0(2) & input0(3) &
      input1(0) & input1(1) & input1(2) & input1(3) &
      input2(0) & input2(1) & input2(2) & input2(3) &
      input3(0) & input3(1) & input3(2) & input3(3) ;
  end function cv_std_logic_vector;

  component sub_array
      port ( arr_in  : in  byte_array;
             arr_out : out byte_array);
  end component sub_array;

  -- Array of 32-bit wide signals connected to sbox.
  signal subarray_in  : sub_array_type;
  signal subarray_out : sub_array_type;

  -- Array of 32-bit wide signals holding generated keys.
  signal key_buf : key_array_type;

  -- Array holding current result after XOR with RCON.
  signal rcon_buf : rcon_array_type;

begin

  gen_sa: for i in 0 to 9 generate
    sa : sub_array
      port map ( arr_in  => subarray_in(i), arr_out => subarray_out(i));
  end generate gen_sa;

  -- Connecting columns of generated keys to roundkey outputs.
  gen_keys : for i in 0 to 10 generate
    roundkeys(i) <= cv_std_logic_vector(key_buf(4*i), key_buf(4*i+1),
    key_buf(4*i+2), key_buf(4*i+3));
  end generate gen_keys;

  -- Connect cipherkey to first four words of generated key.
  key_buf(0) <= cv_byte_array(cipherkey(127 downto 96));
  key_buf(1) <= cv_byte_array(cipherkey(95  downto 64));
  key_buf(2) <= cv_byte_array(cipherkey(63  downto 32));
  key_buf(3) <= cv_byte_array(cipherkey(31  downto 0));

  -- Perform "RotWord" to generate round keys.
  gen_rk: for i in 0 to 9 generate
    subarray_in(i) <= key_buf(4*i+3);

    -- Rot word by shifting once left, thereafter add rcon_table entry to first byte.
    rcon_buf(i)(0) <= subarray_out(i)(1) xor rcon_table(i);
    rcon_buf(i)(1) <= subarray_out(i)(2);
    rcon_buf(i)(2) <= subarray_out(i)(3);
    rcon_buf(i)(3) <= subarray_out(i)(0);

    key_buf(4*(i+1)+0) <= rcon_buf(i) xor key_buf(4*i);
    key_buf(4*(i+1)+1) <= rcon_buf(i) xor key_buf(4*i) xor key_buf(4*i+1);
    key_buf(4*(i+1)+2) <= rcon_buf(i) xor key_buf(4*i) xor key_buf(4*i+1)
                          xor key_buf(4*i+2);
    key_buf(4*(i+1)+3) <= rcon_buf(i) xor key_buf(4*i) xor key_buf(4*i+1)
                          xor key_buf(4*i+2) xor key_buf(4*i+3);
  end generate gen_rk;
end architecture behavioral;
