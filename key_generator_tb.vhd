library ieee;
use ieee.std_logic_1164.all;

library work;
use work.aes128_header.all;

entity key_generator_tb is
end ;

architecture waveform of key_generator_tb is

  signal cipherkey : oword;
  signal roundkeys : oword_array;

  type roundkey_table is array (0 to 10) of oword;
  -- AES-128 schedule for "Thats my Kung Fu".
  constant expected : roundkey_table := (
    0  => x"5468617473206D79204B756E67204675",
    1  => x"E232FCF191129188B159E4E6D679A293",
    2  => x"56082007C71AB18F76435569A03AF7FA",
    3  => x"D2600DE7157ABC686339E901C3031EFB",
    4  => x"A11202C9B468BEA1D75157A01452495B",
    5  => x"B1293B3305418592D210D232C6429B69",
    6  => x"BD3DC287B87C47156A6C9527AC2E0E4E",
    7  => x"CC96ED1674EAAA031E863F24B2A8316A",
    8  => x"8E51EF21FABB4522E43D7A0656954B6C",
    9  => x"BFE2BF904559FAB2A16480B4F7F1CBD8",
    10 => x"28FDDEF86DA4244ACCC0A4FE3B316F26");

begin
  aes: entity work.key_generator
   port map ( cipherkey => cipherkey,
         roundkeys => roundkeys);

  StimuliProcess : process
  begin
    cipherkey <= x"5468617473206D79204B756E67204675";
    wait for 10 ns;
    for i in expected'range loop
      assert roundkeys(i) = expected(i)
        report "key_generator: round key mismatch"
        severity failure;
    end loop;
    wait;
  end process StimuliProcess;
end waveform;
