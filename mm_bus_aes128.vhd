library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mm_bus_aes128 is
  
  port (
    -- Avalon Interface
    csi_clockreset_clk     : in  std_logic;                     -- Avalon Clk
    csi_clockreset_reset_n : in  std_logic;                     -- Avalon Reset
    avs_s1_write           : in  std_logic;                     -- Avalon wr
    avs_s1_read            : in  std_logic;                     -- Avalon rd
    avs_s1_chipselect      : in  std_logic;                     -- Avalon cs
    avs_s1_address         : in  std_logic_vector(7 downto 0);  -- Avalon address
    avs_s1_writedata       : in  std_logic_vector(31 downto 0); -- Avalon wr data
    avs_s1_readdata        : out std_logic_vector(31 downto 0)); -- Avalon rd data

end mm_bus_aes128;

architecture behavior of mm_bus_aes128 is

  component aes128_block is
  port ( plaintext : in  std_logic_vector(127 downto 0);
           cipherkey : in std_logic_vector(127 downto 0);
           ciphertext : out std_logic_vector(127 downto 0));
  end component aes128_block;
  
  signal start : std_logic := '0';
  signal plaintext_in : std_logic_vector(127 downto 0) := (others => 'Z');
  signal cipherkey_in : std_logic_vector(127 downto 0) := (others => 'Z');
  
  signal plaintext_out : std_logic_vector(127 downto 0) := (others => 'Z');
  signal cipherkey_out : std_logic_vector(127 downto 0) := (others => 'Z');
  signal ciphertext_out : std_logic_vector(127 downto 0) := (others => 'Z');
begin

  aes128 : entity work.aes128_block
    port map (
      plaintext => plaintext_out,
      cipherkey => cipherkey_out,
      ciphertext => ciphertext_out);


  accessMem : process (csi_clockreset_clk, csi_clockreset_reset_n)
  begin  -- process accessMem
    if csi_clockreset_reset_n = '0' then  -- asynchronous reset (active low)
      start <= '0';
      avs_s1_readdata <= (others => '0');
    elsif csi_clockreset_clk'event and csi_clockreset_clk = '1' then  -- rising clock edge
      if start = '1' then
        plaintext_out <= plaintext_in;
        cipherkey_out <= cipherkey_in;
        start <= '0';
      end if;
      avs_s1_readdata <= (others => 'Z');
      if avs_s1_chipselect = '1' then
        if avs_s1_read = '1' then
          case avs_s1_address is
            when X"00" => avs_s1_readdata <= ciphertext_out(127 downto 96);
            when X"01" =>  avs_s1_readdata <= ciphertext_out(95 downto 64);
            when X"02" => avs_s1_readdata <= ciphertext_out(63 downto 32);
            when X"03" => avs_s1_readdata <= ciphertext_out(31 downto 0);
            when others => avs_s1_readdata <= (others => '0');  -- Read from
-- unsupported address
          end case;
        elsif avs_s1_write = '1' then
          case avs_s1_address is
            when X"00" => plaintext_in(127 downto 96) <= avs_s1_writedata;
            when X"01" => plaintext_in(95 downto 64) <= avs_s1_writedata;
            when X"02" => plaintext_in(63 downto 32) <= avs_s1_writedata;
            when X"03" => plaintext_in(31 downto 0) <= avs_s1_writedata;
            when X"04" => cipherkey_in(127 downto 96) <= avs_s1_writedata;
            when X"05" => cipherkey_in(95 downto 64) <= avs_s1_writedata;
            when X"06" => cipherkey_in(63 downto 32) <= avs_s1_writedata;
            when X"07" => cipherkey_in(31 downto 0) <= avs_s1_writedata;
            when X"08" => start <= avs_s1_writedata(0);
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process accessMem;
end behavior;