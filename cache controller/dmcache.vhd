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
		 size			:		integer := 8;  -- number of memory words		 
		 adr_width	: 		integer := 8;  -- number of address bits
		 data_width	: 		integer := 8;	 -- number of data bits
		 witdth		:		integer := 2;	 -- cache line width (data_widths)
		 
		 tag_width		:	integer := 2;
		 index_width	: 	integer := 4;
		 offset_width	:	integer := 2
		);
		
   Port ( 
				clk: in STD_LOGIC;
				A 	: in  STD_LOGIC_VECTOR (adr_width-1 downto 0);
				D 	: inout  STD_LOGIC_VECTOR (data_width-1 downto 0);
				hit: out  STD_LOGIC);
			 
	
end dmcache;

architecture Behavioral of dmcache is
	alias tag_address 	is A(adr_width-1 downto offset_width + index_width);
	alias line_index 		is A(offset_width + index_width-1 downto offset_width);
	alias line_offset 	is A(offset_width-1 downto 0);
	
	signal stored_tag : std_logic_vector(tag_width-1 downto 0);
	
	component sram is
		generic
		(
			 clear_on_power_up: boolean;    -- if TRUE, RAM is initialized with zeroes at start of simulation
			 download_on_power_up: boolean;  -- if TRUE, RAM is downloaded at start of simulation 
			 trace_ram_load: boolean;        -- Echoes the data downloaded to the RAM on the screen
			 enable_nWE_only_control: boolean := TRUE;  -- Read-/write access controlled by nWE only
			 -- Configuring RAM size
			 size:      INTEGER;  -- number of memory words
			 adr_width: INTEGER;  -- number of address bits
			 width:     INTEGER;  -- number of bits per memory word
			 -- READ-cycle timing parameters
			 tAA_max:    TIME; -- Address Access Time
			 tOHA_min:   TIME; -- Output Hold Time
			 tACE_max:   TIME; -- nCE/CE2 Access Time
			 tDOE_max:   TIME; -- nOE Access Time
			 tLZOE_min:  TIME; -- nOE to Low-Z Output
			 tHZOE_max:  TIME; --  OE to High-Z Output
			 tLZCE_min:  TIME; -- nCE/CE2 to Low-Z Output
			 tHZCE_max:  TIME; --  CE/nCE2 to High Z Output 
			 -- WRITE-cycle timing parameters
			 tWC_min:    TIME; -- Write Cycle Time
			 tSCE_min:   TIME; -- nCE/CE2 to Write End
			 tAW_min:    TIME; -- tAW Address Set-up Time to Write End
			 tHA_min:    TIME; -- tHA Address Hold from Write End
			 tSA_min:    TIME; -- Address Set-up Time
			 tPWE_min:   TIME; -- nWE Pulse Width
			 tSD_min:    TIME; -- Data Set-up to Write End
			 tHD_min:    TIME; -- Data Hold from Write End
			 tHZWE_max:  TIME; -- nWE Low to High-Z Output
			 tLZWE_min:  TIME -- nWE High to Low-Z Output
		);	
	  port 
	  (      
		 nCE: IN std_logic;  -- low-active Chip-Enable of the SRAM device; defaults to '1' (inactive)
		 nOE: IN std_logic;  -- low-active Output-Enable of the SRAM device; defaults to '1' (inactive)
		 nWE: IN std_logic;  -- low-active Write-Enable of the SRAM device; defaults to '1' (inactive)

		 A:   IN std_logic_vector(adr_width-1 downto 0); -- address bus of the SRAM device
		 D:   INOUT std_logic_vector(width-1 downto 0);  -- bidirectional data bus to/from the SRAM device

		 CE2: IN std_logic  -- high-active Chip-Enable of the SRAM device; defaults to '1'  (active) 
		);
	end component;
			
	
begin

	stored_tag <= (0 => '0', 1 => '1');

	
	tag_comparator: process (tag_address)
	begin
		if (tag_address = stored_tag) then
			hit <= '1';
		else
			hit <= '0';
		end if;
	end process;
	
	
	
	



end Behavioral;

