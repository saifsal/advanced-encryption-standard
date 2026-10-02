library ieee;
use ieee.std_logic_1164.all;

library work;
use work.aes128_header.all;

entity sub_array is
  port ( arr_in  : in  byte_array;
         arr_out : out byte_array);
end entity sub_array;

architecture structural of sub_array is

  component sbox is
    port ( byte_in  : in  byte;
           byte_out : out byte);
  end component sbox;

begin

  sb0 : sbox port map( byte_in => arr_in(0), byte_out => arr_out(0));
  sb1 : sbox port map( byte_in => arr_in(1), byte_out => arr_out(1));
  sb2 : sbox port map( byte_in => arr_in(2), byte_out => arr_out(2));
  sb3 : sbox port map( byte_in => arr_in(3), byte_out => arr_out(3));

end architecture structural;
