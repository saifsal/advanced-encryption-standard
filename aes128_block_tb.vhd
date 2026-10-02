library ieee;
use ieee.std_logic_1164.all;

library work;
use work.aes128_header.all;

entity aes128_block_tb is
end ;

architecture waveform of aes128_block_tb is

  signal plaintext : oword;
  signal cipherkey : oword;
  signal ciphertext  : oword;

begin
  aes: entity work.aes128_block
   port map ( plaintext  => plaintext,
         cipherkey => cipherkey,
         ciphertext => ciphertext);

  StimuliProcess : process
  begin
    plaintext <= x"54776F204F6E65204E696E652054776F";
    cipherkey <= x"5468617473206D79204B756E67204675";
    wait for 10 ns;
    wait;
  end process StimuliProcess;
end waveform;
