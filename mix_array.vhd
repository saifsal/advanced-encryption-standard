library ieee;
use ieee.std_logic_1164.all;

library work;
use work.aes128_header.all;

entity mix_array is
  port ( arr_in  : in  byte_array;
         arr_out : out byte_array);
end entity mix_array;

architecture behavioral of mix_array is

  signal bytes : byte_array;
  signal bytes_doubled : byte_array;
  signal bytes_tripled : byte_array;

begin

  bytes(0)  <= arr_in(0);
  bytes(1)  <= arr_in(1);
  bytes(2)  <= arr_in(2);
  bytes(3)  <= arr_in(3);

  bytes_doubled(0) <= ((arr_in(0)(6 downto 0) & '0') xor x"1B") when arr_in(0)(7) = '1'
                      else (arr_in(0)(6 downto 0) & '0');
  bytes_doubled(1) <= ((arr_in(1)(6 downto 0) & '0') xor x"1B") when arr_in(1)(7) = '1'
                      else (arr_in(1)(6 downto 0) & '0');
  bytes_doubled(2) <= ((arr_in(2)(6 downto 0) & '0') xor x"1B") when arr_in(2)(7) = '1'
                      else (arr_in(2)(6 downto 0) & '0');
  bytes_doubled(3) <= ((arr_in(3)(6 downto 0) & '0') xor x"1B") when arr_in(3)(7) = '1'
                      else (arr_in(3)(6 downto 0) & '0');

  bytes_tripled(0) <= bytes_doubled(0) xor bytes(0);
  bytes_tripled(1) <= bytes_doubled(1) xor bytes(1);
  bytes_tripled(2) <= bytes_doubled(2) xor bytes(2);
  bytes_tripled(3) <= bytes_doubled(3) xor bytes(3);


  arr_out(0) <= bytes_doubled(0) xor bytes_tripled(1) xor bytes(2) xor bytes(3);
  arr_out(1) <= bytes(0) xor bytes_doubled(1) xor bytes_tripled(2) xor bytes(3);
  arr_out(2) <= bytes(0) xor bytes(1) xor bytes_doubled(2) xor bytes_tripled(3);
  arr_out(3) <= bytes_tripled(0) xor bytes(1) xor bytes(2) xor bytes_doubled(3);

end architecture behavioral;
