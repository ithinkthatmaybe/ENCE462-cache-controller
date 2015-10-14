----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:31:07 10/14/2011 
-- Design Name: 
-- Module Name:    registerfile - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.math_real.ALL;
use ieee.std_logic_arith.all;

library unisim;
use unisim.vcomponents.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main_mem is
--  generic (
--  AddressWidth  : integer := 11;
--    WordLength      : integer := 8;
--  Size      : integer := 8
--  );
--  port (
--    nWE                : in std_logic;
--    oE              : in std_logic;
--    cs              : in std_logic;
--    Data            : inout std_logic_vector(WordLength-1 DOWNTO 0);
--    Address         : in std_logic_vector(AddressWidth-1 DOWNTO 0);   
--    clock           : in std_logic;
--    reset           : in std_logic
--  );
end main_mem;



architecture Behavioral of main_mem is 

signal clock,cs,ssr,nWe,reset,oE : std_logic:='0';
signal address : std_logic_vector(10 downto 0):=(others => '0');
signal Data : std_logic_vector(8 downto 0):="000000000";

signal Dout,Din : std_logic_vector(8 downto 0):="000000000";

begin

--RAMB16_S2 is 8k x 2 Single-Port RAM for Spartan-3E.We use this to create 8k x 4 Single-Port RAM.
--Initialize RAM which carries LSB 2 bits of the data.
RAM1  : RAMB16_S9 port map (
		DO => Dout(7 downto 0),      -- 8-bit Data Output
      DOP => Dout(8 downto 8),    -- 1-bit parity Output
      ADDR => Address,  -- 11-bit Address Input
      CLK => clock,    -- Clock
      DI => Din(7 downto 0),      -- 8-bit Data Input
      DIP => Din(8 downto 8),    -- 1-bit parity Input
      EN => cs,      -- RAM Enable Input
      SSR => '0',    -- Synchronous Set/Reset Input
      WE => not(nWE)       -- Write Enable Input
   );

	--control bidir data bus
	process (nWE,oE,Data, Dout)
	begin
		if (nWE = '1' and oE = '1') then
			Data <= Dout;     -- output stored word
		else
			Data <= (others => 'Z'); -- disable output
		end if;
		Din <= Data;
	end process;
 

   -- Clock process definitions
   clk_process :process
   begin
		clock <= '0';
		wait for 5 ns;
		clock <= '1';
		wait for 5 ns;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		nWE <= '1';
		oE <= '0';
      reset <= '1';
      wait for 100 ns;	
      reset <= '0';
		
		cs <= '1';

      wait for 5 ns;

      -- insert stimulus here 
		nWe <= '0';
		oE <= '0';
		
		for i in 0 to 30 loop
			address <= conv_std_logic_vector(i,11);
         data <= conv_std_logic_vector(i,9);
         wait for 10 ns;
        end loop;
        nWe<= '1';
		  oE <= '1';
		  data <= (others => 'Z' );
        --Read the RAM for addresses from 0 to 20.
		  
        for i in 0 to 30 loop
            address <= conv_std_logic_vector(i,11);
            wait for 10 ns;
        end loop;
		  
      wait;
   end process;
	
end Behavioral;




