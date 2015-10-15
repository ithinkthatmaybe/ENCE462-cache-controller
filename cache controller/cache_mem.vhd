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


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cache_mem is
  generic (
	AddressWidth 	 : integer := 8;
    WordLength       : integer := 8;
	Size			 : integer := 8
  );
  port (
	 DataInEnable    : in std_logic;
     DataIn          : in std_logic_vector(WordLength-1 DOWNTO 0);
	 Address         : in std_logic_vector(AddressWidth-1 DOWNTO 0);	 
	 DataOut         : out std_logic_vector(WordLength-1 DOWNTO 0);
	 clock           : in std_logic;
	 reset           : in std_logic
  );
end cache_mem;

architecture Behavioral of cache_mem is 
	-- use synthesized storage - for now
  type RAMT is array(Size-1 downto 0) of std_logic_vector(WordLength-1 DOWNTO 0);
  signal mem        : RAMT;
  signal i          : std_logic;
  
begin
  MemBlock: process (clock, reset, Address, DataIn, DataInEnable)
    variable counter  : integer;
  begin
	if reset = '1' then
	    for counter in 0 TO Size-1 loop
		  mem(counter) <= (others => '0');
		end loop;
    elsif clock'event and clock = '1' then
	   if DataInEnable = '1' then
		  mem(to_integer(unsigned(Address))) <= DataIn;
		end if;
	 end if;
  end process;
  
  DataOut <= mem(to_integer(unsigned(Address)));
  
end Behavioral;

