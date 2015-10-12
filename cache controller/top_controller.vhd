----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:39:36 10/12/2015 
-- Design Name: 
-- Module Name:    top_controller - Behavioral 
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_controller is
    port 
    (  
        -- General
        CLOCK                  		  : in      std_logic;
        RESET                  		  : in      std_logic;    
        RX                     		  : in      std_logic;
        TX                     		  : out     std_logic;

        --BT0 						  : in std_logic;
		--BT1 						  : in std_logic;
		--BT2 						  : in std_logic;        
		BT3 						  : in std_logic;


		LD0							  : out 	  std_logic;
		LD1							  : out 	  std_logic;
		LD2							  : out 	  std_logic;
		LD3							  : out 	  std_logic;
		LD4							  : out 	  std_logic;
		LD5							  : out 	  std_logic;
		LD6							  : out 	  std_logic;
		LD7							  : out 	  std_logic;

		SW0							  :	in		  std_logic;
		SW1							  :	in		  std_logic;
		SW2							  :	in		  std_logic;
		SW3							  :	in		  std_logic;
		SW4							  :	in		  std_logic;
		SW5							  :	in		  std_logic;
		SW6							  :	in		  std_logic;
  		SW7							  :	in		  std_logic	  
    );
end top_controller;

architecture Behavioral of top_controller is
    ----------------------------------------------------------------------------
    -- UART constants
    ----------------------------------------------------------------------------
    
    constant BAUD_RATE              : positive := 9600;
    constant CLOCK_FREQUENCY        : positive := 50000000;

    ----------------------------------------------------------------------------
    -- Signals
    ----------------------------------------------------------------------------


	signal S : std_logic_vector(7 downto 0);
	signal L : std_logic_vector(7 downto 0);
    
    ----------------------------------------------------------------------------
    -- Component declarations
    ----------------------------------------------------------------------------
    component UART is
        generic (
                BAUD_RATE           : positive;
                CLOCK_FREQUENCY     : positive
            );
        port (  -- General
                CLOCK               :   in      std_logic;
                RESET               :   in      std_logic;    
                DATA_STREAM_IN      :   in      std_logic_vector(7 downto 0);
                DATA_STREAM_IN_STB  :   in      std_logic;
                DATA_STREAM_IN_ACK  :   out     std_logic;
                DATA_STREAM_OUT     :   out     std_logic_vector(7 downto 0);
                DATA_STREAM_OUT_STB :   out     std_logic;
                DATA_STREAM_OUT_ACK :   in      std_logic;
                TX                  :   out     std_logic;
                RX                  :   in      std_logic
             );
    end component UART;

    signal uart_data_in             : std_logic_vector(7 downto 0);
    signal uart_data_out            : std_logic_vector(7 downto 0);
    signal uart_data_in_stb         : std_logic;
    signal uart_data_in_ack         : std_logic;
    signal uart_data_out_stb        : std_logic;
    signal uart_data_out_ack        : std_logic;
  
begin

    ----------------------------------------------------------------------------
    -- UART instantiation
    ----------------------------------------------------------------------------

    UART_inst1 : UART
    generic map (
            BAUD_RATE           => BAUD_RATE,
            CLOCK_FREQUENCY     => CLOCK_FREQUENCY
    )
    port map    (  
            -- General
            CLOCK               => CLOCK,
            RESET               => RESET,
            DATA_STREAM_IN      => uart_data_in,
            DATA_STREAM_IN_STB  => uart_data_in_stb,
            DATA_STREAM_IN_ACK  => uart_data_in_ack,
            DATA_STREAM_OUT     => uart_data_out,
            DATA_STREAM_OUT_STB => uart_data_out_stb,
            DATA_STREAM_OUT_ACK => uart_data_out_ack,
            TX                  => TX,
            RX                  => RX
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
	LD7 <= L(7);

	UART_REC : process (CLOCK)
    begin
        if rising_edge(CLOCK) then
            if RESET = '1' then 
                    uart_data_out_ack       <= '0';
            else
                -- Acknowledge data receive strobes and set up a transmission
                -- request
                uart_data_out_ack       <= '0';
                if uart_data_out_stb = '1' then
                    uart_data_out_ack   <= '1';
                    L <= uart_data_out;
                end if;          
            end if;
        end if;
    end process;

    UART_SEN : process (BT3, uart_data_in_ack)
    begin
        uart_data_in <= S;

        if uart_data_in_ack = '1' then
            uart_data_in_stb <= '0';

        elsif rising_edge(BT3) then
            uart_data_in_stb <= '1';
        end if;

    end process;




end Behavioral;

