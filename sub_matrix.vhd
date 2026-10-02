library ieee;
use ieee.std_logic_1164.all;

library work;
use work.aes128_header.all;

entity sub_matrix is
  port ( mat_in  : in  byte_matrix;
         mat_out : out byte_matrix);
end entity sub_matrix;

architecture structural of sub_matrix is

  component sub_array is
    port ( arr_in  : in  byte_array;
           arr_out : out byte_array);
  end component sub_array;

begin

  gsa : for i in 0 to 3 generate
    sa : sub_array
      port map ( arr_in  => mat_in( i),
                 arr_out => mat_out(i));
  end generate gsa;

end architecture structural;
