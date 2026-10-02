library ieee;
use ieee.std_logic_1164.all;

entity tb_mm_bus_aes128 is
end tb_mm_bus_aes128;

architecture tb of tb_mm_bus_aes128 is

    component mm_bus_aes128
        port (csi_clockreset_clk     : in std_logic;
              csi_clockreset_reset_n : in std_logic;
              avs_s1_write           : in std_logic;
              avs_s1_read            : in std_logic;
              avs_s1_chipselect      : in std_logic;
              avs_s1_address         : in std_logic_vector (7 downto 0);
              avs_s1_writedata       : in std_logic_vector (31 downto 0);
              avs_s1_readdata        : out std_logic_vector (31 downto 0));
    end component;

    signal csi_clockreset_clk     : std_logic := '0';
    signal csi_clockreset_reset_n : std_logic := '0';
    signal avs_s1_write           : std_logic := '0';
    signal avs_s1_read            : std_logic := '0';
    signal avs_s1_chipselect      : std_logic := '0';
    signal avs_s1_address         : std_logic_vector (7 downto 0) := (others => 'Z');
    signal avs_s1_writedata       : std_logic_vector (31 downto 0) := (others => 'Z');
    signal avs_s1_readdata        : std_logic_vector (31 downto 0) := (others => 'Z');
    
    signal result : std_logic_vector(127 downto 0) := (others => '0');

begin

    dut : mm_bus_aes128
    port map (csi_clockreset_clk     => csi_clockreset_clk,
              csi_clockreset_reset_n => csi_clockreset_reset_n,
              avs_s1_write           => avs_s1_write,
              avs_s1_read            => avs_s1_read,
              avs_s1_chipselect      => avs_s1_chipselect,
              avs_s1_address         => avs_s1_address,
              avs_s1_writedata       => avs_s1_writedata,
              avs_s1_readdata        => avs_s1_readdata);

    stimuli : process
    begin
	csi_clockreset_reset_n <= '1';
        avs_s1_read <= '0';
        avs_s1_write <= '1';
        avs_s1_chipselect <= '1';
        
        csi_clockreset_clk <= '1';
        avs_s1_address <= x"00";      
        avs_s1_writedata <= x"54776F20";
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;
        
        csi_clockreset_clk <= '1';
        avs_s1_address <= x"01";      
        avs_s1_writedata <= x"4F6E6520";
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;
        
        csi_clockreset_clk <= '1';
        avs_s1_address <= x"02";      
        avs_s1_writedata <= x"4E696E65";
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;
        
        csi_clockreset_clk <= '1';
        avs_s1_address <= x"03";      
        avs_s1_writedata <= x"2054776F";
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;
        
        csi_clockreset_clk <= '1';
        avs_s1_address <= x"04";      
        avs_s1_writedata <= x"54686174";
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;                 
      
        csi_clockreset_clk <= '1';
        avs_s1_address <= x"05";      
        avs_s1_writedata <= x"73206D79";
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;
        
        csi_clockreset_clk <= '1';
        avs_s1_address <= x"06";      
        avs_s1_writedata <= x"204B756E";
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;
        
        csi_clockreset_clk <= '1';
        avs_s1_address <= x"07";      
        avs_s1_writedata <= x"67204675";
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;  
  
        csi_clockreset_clk <= '1';
        avs_s1_address <= x"08";      
        avs_s1_writedata <= x"00000001";
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;

        -- Idle
        avs_s1_write <= '0';
        csi_clockreset_clk <= '1';
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;

        -- Reading
        avs_s1_read <= '1';
        
        csi_clockreset_clk <= '1';
        avs_s1_address <= x"00";      
        result(127 downto 96) <= avs_s1_readdata;
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;

        csi_clockreset_clk <= '1';
        avs_s1_address <= x"01";         
        result(95 downto 64) <= avs_s1_readdata;
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;
        
        csi_clockreset_clk <= '1';
        avs_s1_address <= x"02";                       
        result(63 downto 32) <= avs_s1_readdata;
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;

        csi_clockreset_clk <= '1';
        avs_s1_address <= x"03";               
        result(31 downto 0) <= avs_s1_readdata;
        wait for 25 ns;
        csi_clockreset_clk <= '0';
        wait for 25 ns;      
        wait;
    end process;

end tb;