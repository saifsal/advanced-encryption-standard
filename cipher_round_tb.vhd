library ieee;
use ieee.std_logic_1164.all;

library work;
use work.aes128_header.all;

entity cipher_round_tb is
end ;

architecture waveform of cipher_round_tb is

  signal state_in : byte_matrix;
  signal roundkey  : oword;
  signal state_out : byte_matrix;

begin
  aes: entity work.cipher_round
    port map ( state_in  => state_in,
         roundkey  => roundkey,
         state_out => state_out);

  StimuliProcess : process
  begin
    -- Round 1 of the Kung Fu vector: state after AddRoundKey, with round key 1.
    state_in <= cv_byte_matrix( x"001F0E543C4E08596E221B0B4774311A");
    roundkey <= x"E232FCF191129188B159E4E6D679A293";
    wait for 10 ns;
    assert state_out = cv_byte_matrix(x"5847088B15B61CBA59D4E2E8CD39DFCE")
      report "cipher_round: Kung Fu round 1 mismatch"
      severity failure;
    wait;
  end process StimuliProcess;
end waveform;