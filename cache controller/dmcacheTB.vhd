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

    --COMPONENT main_mem
    --generic (
    --    AddressWidth  : integer := 8;
    --    WordLength      : integer := 8;
    --    Size      : integer := 8
    --);
    --port (
    --    nWE                : in std_logic;
    --    oE              : in std_logic;
    --    cs              : in std_logic;
    --    Data            : inout std_logic_vector(WordLength-1 DOWNTO 0);
    --    Address         : in std_logic_vector(AddressWidth-1 DOWNTO 0);   
    --    clock           : in std_logic;
    --    reset           : in std_logic
    --);
    --end COMPONENT;


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

  --MM : main_mem 
  --port map (
  --  nWE     => memnWE,
  --  oE      => memOE,
  --  cs      => '1',
  --  Data    => memData,
  --  Address => memAddr,
  --  clock   => clock,
  --  reset   => reset
  --  );




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
      cpuAddr <= "10001000";
      cpuData <= "11111110";
      wait for clk_period*2;
      WnR <= '0';

      wait for clk_period*4;

      WnR <= '1';
      cpuAddr <= "01000001";
      cpuData <= "11111101";
      wait for clk_period*2;
      WnR <= '0';

      wait for clk_period*4;

      WnR <= '1';
      cpuAddr <= "10000110";
      cpuData <= "11111011";
      wait for clk_period*2;
      WnR <= '0';

      wait for clk_period*4;

      WnR <= '0';
      oE <= '1' ; 
      cpuData <= "ZZZZZZZZ";
      --cpuData <= "--------";
      wait for clk_period*6;

      -- look at some locations where nothing has been stored to check
      -- that the tag comparator works


      cpuAddr <= "11101111";
      wait for clk_period*6;

      cpuAddr <= "01001000";
      wait for clk_period*6; 

      cpuAddr <= "10000011";
      wait for clk_period*6;
      -- Now look at some locations where something has been stored

      cpuAddr <= "10001000";
      wait for clk_period*6;

      cpuAddr <= "01000001";
      wait for clk_period*6;

      cpuAddr <= "10000110";
      wait for clk_period*6;

      oE <= '0';
      cpuAddr <= "00000000";


      wait;
   end process;

END;
