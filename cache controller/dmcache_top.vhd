----------------------------------------------------------------------------------
-- Company: 
-- Enginoob: Sam Stephenson 
-- 
-- Create Date:    09:19:38 10/10/2015 
-- Design Name: 
-- Module Name:    dmcache_top - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dmcache_top is
    port 
    (  
        -- General
        clock                	  :   in      std_logic;
        --USER_RESET              :   in      std_logic;    
        --USB_RS232_RXD           :   in      std_logic;
        --USB_RS232_TXD           :   out     std_logic;

		BT0 							: in std_logic;
		BT1 							: in std_logic;
		BT2 							: in std_logic;        
		BT3 							: in std_logic;


		LD0							  : 	out 	  std_logic;
		LD1							  : 	out 	  std_logic;
		LD2							  : 	out 	  std_logic;
		LD3							  : 	out 	  std_logic;
		LD4							  : 	out 	  std_logic;
		LD5							  : 	out 	  std_logic;
		LD6							  : 	out 	  std_logic;
		LD7							  : 	out 	  std_logic;

		SW0							  :	in		  std_logic;
		SW1							  :	in		  std_logic;
		SW2							  :	in		  std_logic;
		SW3							  :	in		  std_logic;
		SW4							  :	in		  std_logic;
		SW5							  :	in		  std_logic;
		SW6							  :	in		  std_logic;
  		SW7							  :	in		  std_logic	  
    );
end dmcache_top;

architecture Behavioral of dmcache_top is
	signal S : std_logic_vector(7 downto 0);
	signal L : std_logic_vector(7 downto 0);
	
	--signal WnR : std_logic;
	
	component dmcache is
		port
		(
			clk: in STD_LOGIC;
			reset: in STD_LOGIC;
			WnR: in STD_LOGIC;
			A 	: in  STD_LOGIC_VECTOR(7 downto 0);
			D 	: inout  STD_LOGIC_VECTOR(7 downto 0);
			hit: out  STD_LOGIC
		);
	end component dmcache;
	
	signal address_bus, data_bus, data_out : std_logic_vector(7 downto 0);
	signal cache_hit: std_logic;
begin

	dm_cache : dmcache	
	port map (
		--clk => CLOCK,
		--reset => USER_RESET,
		--WnR => WnR,
		clk => clock,
		reset => BT1,
		WnR => BT3,
		A => address_bus,
		D => data_bus,
		hit => cache_hit
	);
		


	S <= (	7 => SW7,
			6 => SW6,
			5 => SW5,
			4 => SW4,
			3 => SW3,
			2 => SW2,
			1 => SW1,
			0 => SW0
			);
			

	LD0 <= L(0);
	LD1 <= L(1);
	LD2 <= L(2);
	LD3 <= L(3);
	LD4 <= L(4);
	LD5 <= L(5);
	LD6 <= L(6);
	--LD7 <= L(7);

	LD7 <= cache_hit; -- start stealing leds for debug


	process (BT2)
	begin
		if (BT2 = '1') then
			address_bus <= "10000001";
		else
			address_bus <= "01000000";
		end if;
	end process;

	--address_bus <= (others => '0');

	--L <= S;


	--control bidir data bus
	process (BT3, data_bus, BT0)
	begin
		if (BT3 = '1') then
			data_bus <= S;     -- output data
		else
			data_bus <= (others => 'Z'); -- disable output
		end if;
		L <= data_bus;
	end process;






	--address_bus <= S; -- switches control address



end Behavioral;

