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
    -- ASCII "Two One Nine Two" / "Thats my Kung Fu".
    plaintext <= x"54776F204F6E65204E696E652054776F";
    cipherkey <= x"5468617473206D79204B756E67204675";
    wait for 10 ns;
    assert ciphertext = x"29C3505F571420F6402299B31A02D73A"
      report "aes128_block: Kung Fu vector mismatch"
      severity failure;

    -- FIPS-197 Appendix C.1.
    plaintext <= x"3243F6A8885A308D313198A2E0370734";
    cipherkey <= x"2B7E151628AED2A6ABF7158809CF4F3C";
    wait for 10 ns;
    assert ciphertext = x"3925841D02DC09FBDC118597196A0B32"
      report "aes128_block: FIPS-197 C.1 mismatch"
      severity failure;
    wait;
  end process StimuliProcess;
end waveform;
