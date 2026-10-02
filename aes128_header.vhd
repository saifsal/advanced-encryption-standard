library ieee;
use ieee.std_logic_1164.all;

package aes128_header is
  subtype byte  is std_logic_vector(7   downto 0);
  subtype dword is std_logic_vector(31  downto 0);
  subtype oword is std_logic_vector(127 downto 0);

  type byte_array  is array (3  downto 0) of byte;
  type byte_matrix is array (3  downto 0) of byte_array;

  type oword_array is array (10 downto 0) of oword;

  constant zero_byte  : byte  := (others => '0');
  constant zero_dword : dword := (others => '0');
  constant zero_oword : oword := (others => '0');
 
  constant zero_byte_array  : byte_array  := (others => zero_byte);
  constant zero_byte_matrix : byte_matrix := (others => zero_byte_array);

  function shift_rows ( input : byte_matrix)
    return byte_matrix;

  function "xor" ( left  : byte_matrix;
                   right : std_logic_vector)
    return byte_matrix;

  function cv_byte_array ( input : dword)
    return byte_array;

  function cv_byte_matrix( input : oword)
    return byte_matrix;

end package aes128_header;

package body aes128_header is

  function shift_rows ( input : byte_matrix)
    return byte_matrix is variable output : byte_matrix;
  begin
    -- First Row
    output(0)(0) := input(0)(0);
    output(1)(0) := input(1)(0);
    output(2)(0) := input(2)(0);
    output(3)(0) := input(3)(0);
    -- Second Row
    output(0)(1) := input(1)(1);
    output(1)(1) := input(2)(1);
    output(2)(1) := input(3)(1);
    output(3)(1) := input(0)(1);
    -- Third Row
    output(0)(2) := input(2)(2);
    output(1)(2) := input(3)(2);
    output(2)(2) := input(0)(2);
    output(3)(2) := input(1)(2);
    -- Fourth Row
    output(0)(3) := input(3)(3);
    output(1)(3) := input(0)(3);
    output(2)(3) := input(1)(3);
    output(3)(3) := input(2)(3);

    return output;
  end function shift_rows;

  function "xor" ( left  : byte_matrix;
                   right : std_logic_vector)
    return byte_matrix is variable output : byte_matrix;
  begin
    -- First Column
    output(0)(0) := left(0)(0) xor right(127 downto 120);
    output(0)(1) := left(0)(1) xor right(119 downto 112);
    output(0)(2) := left(0)(2) xor right(111 downto 104);
    output(0)(3) := left(0)(3) xor right(103 downto 96 );
    -- Second Column
    output(1)(0) := left(1)(0) xor right(95 downto 88);
    output(1)(1) := left(1)(1) xor right(87 downto 80);
    output(1)(2) := left(1)(2) xor right(79 downto 72);
    output(1)(3) := left(1)(3) xor right(71 downto 64);
    -- Third Column
    output(2)(0) := left(2)(0) xor right(63 downto 56);
    output(2)(1) := left(2)(1) xor right(55 downto 48);
    output(2)(2) := left(2)(2) xor right(47 downto 40);
    output(2)(3) := left(2)(3) xor right(39 downto 32);
    -- Fourth Column
    output(3)(0) := left(3)(0) xor right(31 downto 24);
    output(3)(1) := left(3)(1) xor right(23 downto 16);
    output(3)(2) := left(3)(2) xor right(15 downto 8 );
    output(3)(3) := left(3)(3) xor right(7  downto 0 );

    return output;
  end function "xor";

  function cv_byte_array ( input : dword)
    return byte_array is variable output : byte_array;
  begin
    output(0) := input(31 downto 24);
    output(1) := input(23 downto 16);
    output(2) := input(15 downto 8 );
    output(3) := input(7  downto 0 );
    return output;
  end function cv_byte_array;

  function cv_byte_matrix ( input : oword)
    return byte_matrix is variable output : byte_matrix;
  begin
    output(0) := cv_byte_array(input(127 downto 96));
    output(1) := cv_byte_array(input(95  downto 64));
    output(2) := cv_byte_array(input(63  downto 32));
    output(3) := cv_byte_array(input(31  downto 0 ));
    return output;
  end function cv_byte_matrix;

end package body aes128_header;
