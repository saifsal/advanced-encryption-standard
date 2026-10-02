library ieee;
use ieee.std_logic_1164.all;

library work;
use work.aes128_header.all;

entity key_generator_tb is
end ;

architecture waveform of key_generator_tb is

  signal cipherkey : oword;
  signal roundkeys : oword_array;

begin
  aes: entity work.key_generator
   port map ( cipherkey => cipherkey,
         roundkeys => roundkeys);

  StimuliProcess : process
  begin
    cipherkey <= x"5468617473206D79204B756E67204675";
    wait for 10 ns;
    wait;
  end process StimuliProcess;
end waveform;
