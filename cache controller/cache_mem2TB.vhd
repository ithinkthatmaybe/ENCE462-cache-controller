--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:22:32 10/10/2015
-- Design Name:   
-- Module Name:   P:/ENEL462/cache controller/cache_mem2TB.vhd
-- Project Name:  cache_controller
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cache_mem
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
 
ENTITY cache_mem2TB IS
END cache_mem2TB;
 
ARCHITECTURE behavior OF cache_mem2TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cache_mem
    PORT(
         DataInEnable : IN  std_logic;
         DataIn : IN  std_logic_vector(7 downto 0);
         AddressIn : IN  integer range 32-1 downto 0;
         DataOut : OUT  std_logic_vector(7 downto 0);
         clock : IN  std_logic;
         reset : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal DataInEnable : std_logic := '0';
   signal DataIn : std_logic_vector(7 downto 0) := (others => '0');
   signal AddressIn : integer range 32-1 downto 0;
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal DataOut : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cache_mem PORT MAP (
          DataInEnable => DataInEnable,
          DataIn => DataIn,
          AddressIn => AddressIn,
          DataOut => DataOut,
          clock => clock,
          reset => reset
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
	  reset <= '1';
      wait for 100 ns;	
	  reset <= '0';

      wait for clock_period*1;

	  AddressIn <= 1;
	  DataIn <= "11111111";
	  DataInEnable <= '1';
      -- insert stimulus here 
	  
	  wait for clock_period;
	  
	  DataInEnable <= '0';
      DataIn <= "01010101";
	  
	  wait for clock_period;
	  
	  DataInEnable <= '1';

      wait;
   end process;

END;
