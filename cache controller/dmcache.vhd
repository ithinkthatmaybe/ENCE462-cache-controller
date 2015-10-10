----------------------------------------------------------------------------------
-- Company: 
-- Enginoob: Sam Stephenson 
-- 
-- Create Date:    08:45:32 10/10/2015 
-- Design Name: 
-- Module Name:    dmcache - Behavioral 
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

entity dmcache is
	generic (
		 size			:	integer := 8;  -- number of memory words		 
		 adr_width	: 		integer := 8;  -- number of address bits
		 data_width	: 		integer := 8;	 -- number of data bits
		 witdth		:		integer := 1;	 -- cache line width (data_widths) (currently unused)
		 
		 tag_width		:	integer := 2;
		 index_width	: 	integer := 6;
		 offset_width	:	integer := 0
		);
		
   Port ( 
		clk: in STD_LOGIC;
		reset: in STD_LOGIC;
		WnR: in STD_LOGIC;
		A 	: in  STD_LOGIC_VECTOR (adr_width-1 downto 0);
		D 	: inout  STD_LOGIC_VECTOR (data_width-1 downto 0);
		hit: out  STD_LOGIC);		 
	
end dmcache;

architecture Behavioral of dmcache is
	alias tag_address 	is A(adr_width-1 downto offset_width + index_width);
	alias line_index    is A(offset_width + index_width-1 downto offset_width);
	alias line_offset 	is A(offset_width-1 downto 0);
	
	signal stored_tag : std_logic_vector(tag_width-1 downto 0);
	signal stored_word : std_logic_vector(data_width-1 downto 0);
	signal word_in		: std_logic_vector(data_width-1 downto 0);
	
	component cache_mem is
	  generic (
		AddressWidth 	: integer;
		WordLength      : integer;
		Size			: integer
	  );
	  port (
		 DataInEnable    : in std_logic;
		 DataIn          : in std_logic_vector(WordLength-1 DOWNTO 0);
		 Address         : in std_logic_vector(AddressWidth-1 DOWNTO 0);
		 DataOut         : out std_logic_vector(WordLength-1 DOWNTO 0);
		 clock           : in std_logic;
		 reset           : in std_logic
	  );
	end component;
	
begin
	-- Make comparitor act on clock edges?
			-- pretty much does as the stored tag isn't updated
			-- until then anyway
	tag_comparator: process(tag_address, stored_tag)
	begin
		if (tag_address = stored_tag) then
			hit <= '1';
		else
			hit <= '0';
		end if;
	end process;

	
	cache_memory : cache_mem
	generic map
	(
		addressWidth => index_width,
		wordLength => data_width,
		Size => 2**index_width
	)
	port map
	(
		DataInEnable => WnR,
		DataIn => word_in,
		Address => line_index,
		DataOut => stored_word, 
		clock => clk,
		reset => reset
	);
	
	cache_directory : cache_mem
	generic map
	(
		addressWidth => index_width,
		wordLength 	  => tag_width,
		Size	  => 2**index_width		
	)
	port map
	(
		DataInEnable => WnR,
		DataIn => tag_address,		
		Address => line_index,
		DataOut => stored_tag,
		clock => clk,
		reset => reset
	);	

	--control bidir data buss
	process (WnR, D, A, clk)
	begin
		if (WnR = '1') then
			D <= (others => 'Z'); -- disable output
		else
			D <= stored_word;     -- output stored word
		end if;
		word_in <= D;
	end process;



end Behavioral;

