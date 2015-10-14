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
    -- States
    ----------------------------------------------------------------------------

    type state_type is (UART_IDLE, UART_READ, UART_WRITE, UART_WRITE_WAITING);  --type of state machine.
    signal current_state    :   state_type := UART_IDLE;
    signal next_state       :   state_type;  --current and next state declaration.

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
    signal byte_in : std_logic_vector(7 downto 0);
    signal byte_out: std_logic_vector(7 downto 0);
    signal byte_sent : std_logic;
    signal byte_received : std_logic := '0';
    signal byte_received_last : std_logic;
    signal byte_written : std_logic;

    signal write_mode : std_logic;

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
                DATA_STREAM_IN      :   in      std_logic_vector(7 downto 0);  -- TO PC
                DATA_STREAM_IN_STB  :   in      std_logic;
                DATA_STREAM_IN_ACK  :   out     std_logic;
                DATA_STREAM_OUT     :   out     std_logic_vector(7 downto 0);  -- from PC
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




    CONTROL_IN : process (CLOCK, current_state, byte_received, byte_in, byte_sent, byte_written)
    begin
        -- State transition logic
        if current_state = UART_IDLE then
            uart_data_out_ack <= '0';
            if uart_data_out_stb = '1' then
                uart_data_out_ack <= '1';
                byte_in <= uart_data_out;
                if byte_in(6) = '0' then 
                    next_state <= UART_WRITE_WAITING;
                else
                    next_state <= UART_READ;
                end if;
            else 
                next_state <= UART_IDLE;
            end if;

        elsif current_state = UART_READ then
            uart_data_in <= S;
            uart_data_in_stb <= '1';
            if uart_data_in_ack = '1' then
                uart_data_in_stb <= '0';
                next_state <= UART_IDLE;
            else 
                next_state <= UART_READ;
            end if;
        elsif current_state = UART_WRITE_WAITING then
            uart_data_out_ack <= '0';
            if uart_data_out_stb = '1' then
                uart_data_out_ack <= '1';
                byte_in <= uart_data_out;
                L <= byte_in;
                next_state <= UART_IDLE;
            else  
                next_state <= UART_WRITE_WAITING;
            end if;
        elsif current_state = UART_WRITE then

        end if;

        if rising_edge(CLOCK) then
            current_state <= next_state;
        end if;
    end process;


    --REG_WRITER : process
    --begin 
    --    byte_written <= '0';
    --    if write_mode = '1' then
    --    --wait until current_state = UART_WRITE;
    --    --wait until write_mode = '1';
    --        L <= byte_in;
    --    else 
    --        byte_written <= '1';
    --    --wait until current_state = UART_IDLE;
    --    --wait until write_mode = '0';
    --    end if;
    --end process;

    --uart_data_in <= byte_out;
    --REG_READER : process
    --begin
    --    byte_sent <= '0';
    --    wait until current_state = UART_READ;
    --    byte_out <= S;
    --    -- set uart write strobe and wait for ack
    --    uart_data_in_stb <= '1';
    --    wait until uart_data_in_ack = '1';
    --    uart_data_in_stb <= '0';
    --    byte_sent <= '1';
    --    wait until current_state = UART_IDLE;
    --end process;




   -- STIMULUS : process
   -- begin

   -- wait for 110 ns;

   -- uart_data_out <= "00000000";
   -- uart_data_out_stb <= '1';
   -- wait until uart_data_out_ack = '1';
   -- uart_data_out_stb <= '0';

   -- wait for 50 ns;

   -- uart_data_out <= "00000010";
   -- uart_data_out_stb <= '1';
   -- wait until uart_data_out_ack = '1';
   -- uart_data_out_stb <= '0';

   -- wait for 50 ns;

   -- uart_data_out <= "11111111";
   -- uart_data_out_stb <= '1';
   -- wait until uart_data_out_ack = '1';
   -- uart_data_out_stb <= '0';
   -- wait;
   -- end process;

   --clk_process :process
   --     constant clk_period : time := 20 ns;
   --begin
   --     CLOCK <= '0';
   --     wait for clk_period/2;
   --     CLOCK <= '1';
   --     wait for clk_period/2;
   --end process;



end Behavioral;


























 --   UART_SEN : process (BT3, uart_data_in_ack)
 --   begin
 --       uart_data_in <= S;

 --       if uart_data_in_ack = '1' then
 --           uart_data_in_stb <= '0';

 --       elsif rising_edge(BT3) then
 --           uart_data_in_stb <= '1';
 --       end if;

 --   end process;
