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

USE ieee.math_real.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cache_mem is
  generic (
    WordLength      : integer := 8;
    FileSize        : integer := 32
  );
  port (
	 DataInEnable    : in std_logic;
     DataIn          : in std_logic_vector(WordLength-1 DOWNTO 0);
	 AddressIn       : in integer range FileSize-1 downto 0;
	 DataOut        : out std_logic_vector(WordLength-1 DOWNTO 0);
	 clock           : in std_logic;
	 reset           : in std_logic
  );
end cache_mem;

architecture Behavioral of cache_mem is

  type RegT is array(FileSize-1 downto 0) of std_logic_vector(WordLength-1 DOWNTO 0);
  signal reg        : RegT;
  signal i          : std_logic;
  signal enable     : std_logic_vector(0 TO FileSize-1);
  
begin
  RegisterBlock: process (clock, reset, AddressIn, DataIn, DataInEnable)
    variable counter  : integer;
  begin
	 if reset = '1' then
	   for counter in 0 TO FileSize-1 loop
		  reg(counter) <= (others => '0');
		end loop;
    elsif clock'event and clock = '1' then
	   if DataInEnable = '1' then
		  reg(AddressIn) <= DataIn;
		end if;
	 end if;
  end process;

  DataOut <= reg(AddressIn);
  
end Behavioral;

