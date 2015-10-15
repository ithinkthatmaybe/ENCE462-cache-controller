--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:32:06 10/11/2015
-- Design Name:   
-- Module Name:   P:/ENEL462/cache controller/dmcacheTB.vhd
-- Project Name:  cache_controller
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dmcache
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of cpuAddr design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY dmcacheTB IS
END dmcacheTB;
 
ARCHITECTURE behavior OF dmcacheTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dmcache
    PORT(
         clock : IN  std_logic;
         reset : IN  std_logic;
         WnR : IN  std_logic;
         oE   : IN std_logic;
         busy : OUT std_logic;
         cpuAddr : IN  std_logic_vector(7 downto 0);
         cpuData : INOUT  std_logic_vector(7 downto 0);
         hit : OUT  std_logic;
         memAddr : OUT  std_logic_vector(7 downto 0);
         memData : INOUT  std_logic_vector(7 downto 0);
         memOE       : out   STD_LOGIC;
         memnWE      : out   STD_LOGIC;
         state_out   : Out   std_logic_vector(2 downto 0)
        );
    END COMPONENT;

    COMPONENT main_mem
    generic (
        AddressWidth  : integer := 8;
        WordLength      : integer := 8;
        Size      : integer := 8
    );
    port (
        nWE                : in std_logic;
        oE              : in std_logic;
        cs              : in std_logic;
        Data            : inout std_logic_vector(WordLength-1 DOWNTO 0);
        Address         : in std_logic_vector(AddressWidth-1 DOWNTO 0);   
        clock           : in std_logic;
        reset           : in std_logic
    );
    end COMPONENT;


   --Inputs
   signal clock     : std_logic := '0';
   signal reset     : std_logic := '0';
   signal WnR     : std_logic := '0';
   signal oE    : std_logic := '0';
   signal cpuAddr : std_logic_vector(7 downto 0) := (others => '0');   
   signal memAddr : std_logic_vector(7 downto 0) := (others => '0');

	--BiDirs
   signal cpuData : std_logic_vector(7 downto 0) := (others => '0');
   signal memData : std_logic_vector(7 downto 0) := (others => '0');
   

 	--Outputs
  signal hit  : std_logic;
  signal busy : std_logic;
  signal memOE  : std_logic;
  signal memnWE : std_logic;
  signal state_out : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN

	-- Instantiate the Unit Under Test (UUT)
  uut: dmcache PORT MAP (
          clock => clock,
          reset => reset,
          WnR => WnR,
          oE => oE,
          busy => busy,
          cpuAddr => cpuAddr,
          cpuData => cpuData,
          hit => hit,
          memAddr => memAddr,
          memData => memData,
          memOE => memOE,
          memnWE => memnWE,
          state_out => state_out
    );

  MM : main_mem
  generic map (
        AddressWidth  => 8,
        WordLength    => 8,
        Size      => 2**8
    )
  port map (
    nWE     => memnWE,
    oE      => memOE,
    cs      => '1',
    Data    => memData,
    Address => memAddr,
    clock   => clock,
    reset   => reset
    );




   -- Clock process definitions
   clk_process : process
   begin
		clock <= '1';
		wait for clk_period/2;
		clock <= '0';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      reset <= '1';
      wait for 100 ns;	
      reset <= '0';

      wait for clk_period*3;

      -- insert stimulus here 

      WnR <= '1';
      --cpuAddr <= "11111111";
      --cpuAddr <= "00000001";
      cpuAddr <= "10001000";
      cpuData <= "11111110";
      wait until hit = '1';
      WnR <= '0';
      cpuData <= "ZZZZZZZZ";

      wait until busy = '0';
      WnR <= '1';
      --cpuAddr <= "00000010";
      cpuAddr <= "01000001";
      cpuData <= "11111101";
      wait until hit = '1';
      WnR <= '0';
      cpuData <= "ZZZZZZZZ";

      wait until busy = '0';
      WnR <= '1';
      --cpuAddr <= "00000011";
      cpuAddr <= "10000110";
      cpuData <= "11111011";
      wait until hit = '1';
      WnR <= '0';
      cpuData <= "ZZZZZZZZ";
      --cpuData <= "--------";
      wait until busy = '0';


      -- go back and look at the cached locations
      oE <= '1' ; 
      --cpuAddr <= "00000001";
      cpuAddr <= "10001000";


    wait for clk_period*3;	  

	  oE <= '0';
	  wait for clk_period;
	  oE <= '1';

      --cpuAddr <= "00000010";
      cpuAddr <= "01000001";

    wait for clk_period*3;    
	  oE <= '0';
	  wait for clk_period;
	  oE <= '1';


      --cpuAddr <= "00000011";
    cpuAddr <= "10000110";


    wait for clk_period*3;    
 	oE <= '0';
  	wait for clk_period;
  	oE <= '1';


    -- look at some uncached locations


    wait for clk_period*3;


    oE <= '0';
    wait for clk_period;
    oE <= '1';

    cpuAddr <= "01001000";


    wait for clk_period*3;
    wait until hit = '1';    
	oE <= '0';
	wait for clk_period;
	oE <= '1';

    cpuAddr <= "10000011";


    wait for clk_period*3;
    wait until hit = '1'; 

    -- done   

    oE <= '0';
    cpuAddr <= "00000000";

    wait for 100 ns;

    reset <= '1';
    wait for 100 ns;
    reset <= '0';


      -- --write to a memory location, write over it in cache, read origional location (do a fetch)
      --WnR <= '1';
      --cpuAddr <= "10000000";
      --cpuData <= "10101010";
      --wait for 20 ns;
      --WnR <= '0';

      --wait for 50 ns;

      --WnR <= '1';
      --cpuAddr <= "01000000";
      --cpuData <= "11110000";
      --wait for 20 ns;
      --WnR <= '0';
      

      --wait for 50 ns;


      --oE <= '1';
      --cpuAddr <= "10000000";
      --cpuData <= (others => 'Z');

      --wait for clk_period*18;

      --oE <= '0';
      --cpuAddr <= "00000000";



      wait;
   end process;

END;
