library ieee;
use ieee.std_logic_1164.all;

library work;
use work.aes128_header.all;

entity mix_matrix is
  port ( mat_in  : in  byte_matrix;
         mat_out : out byte_matrix);
end entity mix_matrix;


architecture structural of mix_matrix is

  component mix_array is
    port ( arr_in  : in  byte_array;
           arr_out : out byte_array);
  end component mix_array;

begin

  gen_ma : for i in 0 to 3 generate
    ma : entity work.mix_array
      port map ( arr_in  => mat_in( i),
                 arr_out => mat_out(i));
  end generate gen_ma;

end architecture structural;
