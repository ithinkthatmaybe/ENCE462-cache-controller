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
-- that these types always be used for the top-level I/O of a design in order
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
         clk : IN  std_logic;
         reset : IN  std_logic;
         WnR : IN  std_logic;
         A : IN  std_logic_vector(7 downto 0);
         D : INOUT  std_logic_vector(7 downto 0);
         hit : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal WnR : std_logic := '0';
   signal A : std_logic_vector(7 downto 0) := (others => '0');

	--BiDirs
   signal D : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal hit : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dmcache PORT MAP (
          clk => clk,
          reset => reset,
          WnR => WnR,
          A => A,
          D => D,
          hit => hit
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
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
      A <= "10000000";
      D <= "11111110";
      wait for clk_period*3;


      A <= "01000001";
      D <= "11111101";
      wait for clk_period*3;


      A <= "10000010";
      D <= "11111011";
      wait for clk_period*3;

      WnR <= '0';    
      D <= "ZZZZZZZZ";
      --D <= "--------";
      wait for clk_period*3;

      -- look at some locations where nothing has been stored to check
      -- that the tag comparator works


      A <= "11101111";
      wait for clk_period*3;

      A <= "01001000";
      wait for clk_period*3; 

      A <= "10000011";
      wait for clk_period*3;
      -- Now look at some locations where something has been stored

      A <= "10000000";
      wait for clk_period*3;

      A <= "01000001";
      wait for clk_period*3;

      A <= "10000010";
      wait for clk_period*3;

      A <= "00000000";


      wait;
   end process;

END;
