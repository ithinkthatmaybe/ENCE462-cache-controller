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
  --      -- General
  --      CLOCK                  		  : in      std_logic;
        RESET                  		  : in      std_logic;    
  --      RX                     		  : in      std_logic;
  --      TX                     		  : out     std_logic;

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

    -- SIMULATOIN SIGNALS
    signal CLOCK : std_logic;



    type REGT is array(2**4-1 downto 0) of std_logic_vector(7 DOWNTO 0);
    signal write_regs  :   REGT;
    signal read_regs    : REGT;
    ----------------------------------------------------------------------------
    -- States
    ----------------------------------------------------------------------------

    type state_type is (IDLE, WRITE_GET_ADDR, WRITE_GET_DATA, WRITE_WAITING, WRITE_DO, READ_GET_ADDR, READ_WAITING, READ_DO, READ_SEND);  --type of state machine.
    signal current_state    :   state_type := IDLE;
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
    --signal byte_sent : std_logic;
    --signal byte_received : std_logic := '0';
    --signal byte_received_last : std_logic;
    --signal byte_written : std_logic;
    --signal write_mode : std_logic;

    --signal write_loc : std_logic_vector (3 downto 0);
    --signal read_loc : std_logic_vector (3 downto 0);

    ----------------------------------------------------------------------------
    -- UART Signals
    ----------------------------------------------------------------------------


    signal uart_data_in             : std_logic_vector(7 downto 0);
    signal uart_data_out            : std_logic_vector(7 downto 0);
    signal uart_data_in_stb         : std_logic;
    signal uart_data_in_ack         : std_logic;
    signal uart_data_out_stb        : std_logic;
    signal uart_data_out_ack        : std_logic;


    ----------------------------------------------------------------------------
    -- Controller Signals
    ----------------------------------------------------------------------------

    signal read_addr : std_logic_vector(7 downto 0);
    signal write_addr : std_logic_vector(7 downto 0);
    signal write_data : std_logic_vector(7 downto 0);

    ----------------------------------------------------------------------------
    -- Cache Signals
    ----------------------------------------------------------------------------


    --signal cpuCtl : std_logic_vector(7 downto 0);
    signal cpuAddr : std_logic_vector(7 downto 0);
    --signal cpuDataOut : std_logic_vector(7 downto 0);
    --signal cpuDataIn : std_logic_vector(7 downto 0);

    signal cpuData : std_logic_vector(7 downto 0);

    signal WnR  :  std_logic;
    signal oE   : std_logic;
    signal busy : std_logic;
    signal hit  : std_logic;

    signal state_out : std_logic_vector(2 downto 0);

    ----------------------------------------------------------------------------
    -- Mem Signals
    ----------------------------------------------------------------------------   

    --signal memCtl : std_logic_vector(7 downto 0);
    signal memAddr : std_logic_vector(7 downto 0);
    --signal memDataIn : std_logic_vector(7 downto 0);
    --signal memDataOut : std_logic_vector(7 downto 0);
    
    signal memData : std_logic_vector(7 downto 0);

    signal memOE  : std_logic;
    signal memnWE : std_logic; 

    ----------------------------------------------------------------------------
    -- Component declarations
    ----------------------------------------------------------------------------
    --component UART is
    --    generic (
    --            BAUD_RATE           : positive;
    --            CLOCK_FREQUENCY     : positive
    --        );
    --    port (  -- General
    --            CLOCK               :   in      std_logic;
    --            RESET               :   in      std_logic;    
    --            DATA_STREAM_IN      :   in      std_logic_vector(7 downto 0);  -- TO PC
    --            DATA_STREAM_IN_STB  :   in      std_logic;
    --            DATA_STREAM_IN_ACK  :   out     std_logic;
    --            DATA_STREAM_OUT     :   out     std_logic_vector(7 downto 0);  -- from PC
    --            DATA_STREAM_OUT_STB :   out     std_logic;
    --            DATA_STREAM_OUT_ACK :   in      std_logic;
    --            TX                  :   out     std_logic;
    --            RX                  :   in      std_logic
    --         );
    --end component UART;

  

    COMPONENT dmcache
    PORT(
        clock : IN  std_logic;
        reset : IN  std_logic;
        WnR : IN  std_logic;
        oE   : IN std_logic;
        busy : OUT std_logic;
        cpuAddr : IN  std_logic_vector(7 downto 0);
        cpuData : INOUT  std_logic_vector(7 downto 0);
        hit : OUT  std_logic;
        memAddr : OUT  std_logic_vector(7 downto 0);
        memData : INOUT  std_logic_vector(7 downto 0);
        memOE       : out   STD_LOGIC;
        memnWE      : out   STD_LOGIC;
        state_out   : Out   std_logic_vector(2 downto 0)
        );
    END COMPONENT;



    COMPONENT main_mem
    generic (
        AddressWidth  : integer := 8;
        WordLength      : integer := 8;
        Size      : integer := 8
    );
    port (
        nWE                : in std_logic;
        oE              : in std_logic;
        cs              : in std_logic;
        Data            : inout std_logic_vector(WordLength-1 DOWNTO 0);
        Address         : in std_logic_vector(AddressWidth-1 DOWNTO 0);   
        clock           : in std_logic;
        reset           : in std_logic
    );
    end COMPONENT;


begin

    cache : dmcache PORT MAP (
        clock     => clock,
        reset     => reset,
        WnR       => WnR,
        oE        => oE,
        busy      => busy,
        cpuAddr   => cpuAddr,
        cpuData   => cpuData,
        hit       => hit,
        memAddr   => memAddr,
        memData   => memData,
        memOE     => memOE,
        memnWE    => memnWE,
        state_out => state_out
    );

    main_memory : main_mem
    generic map (
        AddressWidth  => 8,
        WordLength    => 8,
        Size      => 2**8
    )
    port map (
        nWE     => memnWE,
        oE      => memOE,
        cs      => '1',
        Data    => memData,
        Address => memAddr,
        clock   => clock,
        reset   => reset
    );



    --UART_inst1 : UART
    --generic map (
    --        BAUD_RATE           => BAUD_RATE,
    --        CLOCK_FREQUENCY     => CLOCK_FREQUENCY
    --)
    --port map    (  
    --        -- General
    --        CLOCK               => CLOCK,
    --        RESET               => RESET,
    --        DATA_STREAM_IN      => uart_data_in,
    --        DATA_STREAM_IN_STB  => uart_data_in_stb,
    --        DATA_STREAM_IN_ACK  => uart_data_in_ack,
    --        DATA_STREAM_OUT     => uart_data_out,
    --        DATA_STREAM_OUT_STB => uart_data_out_stb,
    --        DATA_STREAM_OUT_ACK => uart_data_out_ack,
    --        TX                  => TX,
    --        RX                  => RX
    --);


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



    --read_regs(0) <= S;
    --L <= write_regs(0);




    CONTROL_IN : process (CLOCK, current_state, uart_data_out_stb, uart_data_in_ack, busy, hit)
    begin
        -- State transition logic
        if current_state = IDLE then
            WnR <= '0';
            oE <= '0';
            cpuAddr <= (others => 'Z');
            cpuData <= (others => 'Z');

            uart_data_in_stb <= '0';

            uart_data_out_ack <= '0';
            if uart_data_out_stb = '1' then
                uart_data_out_ack <= '1';
                if uart_data_out(6) = '0' then 
                    next_state <= WRITE_GET_ADDR;
                else
                    next_state <= READ_GET_ADDR;
                end if;
            else 
                uart_data_out_ack <= '0';
                next_state <= IDLE;
            end if;

        ----------------------------------------
        --          READ CYCLE
        elsif current_state = READ_GET_ADDR then
            if uart_data_out_stb = '1' then
                uart_data_out_acK <= '1';
                read_addr <= uart_data_out;
                next_state <= READ_WAITING;
            else
                uart_data_out_ack <= '0';
                next_state <= READ_GET_ADDR;
            end if;
        elsif current_state = READ_WAITING then
            uart_data_out_ack <= '0';
            if busy = '0' then
                next_state <= READ_DO;
            else
                uart_data_out_ack <= '0';
                next_state <= READ_WAITING;
            end if;

        elsif current_state = READ_DO then
            oE <= '1';
            WnR <= '0';
            cpuAddr <= read_addr;
            if hit = '1' then
                byte_out <= cpuData;
                next_state <= READ_SEND;
            else
                next_state <= READ_DO;
            end if;

        elsif current_state = READ_SEND then
            oE <= '0';
            uart_data_in <= byte_out;
            uart_data_in_stb <= '1';
            if uart_data_in_ack = '1' then
                uart_data_in_stb <= '0';

                next_state <= IDLE;
            else
                next_state <= READ_SEND;
            end if;

        ----------------------------------------
        --          WRITE CYCLE
        elsif current_state = WRITE_GET_ADDR then
            uart_data_out_ack <= '0';
            if uart_data_out_stb = '1' then
                uart_data_out_ack <= '1';
                write_addr <= uart_data_out;
                next_state <= WRITE_GET_DATA;
            else  
                next_state <= WRITE_GET_ADDR;
            end if;

        elsif current_state = WRITE_GET_DATA then
            uart_data_out_ack <= '0';
            if uart_data_out_stb = '1' then
                uart_data_out_ack <= '1';
                write_data <= uart_data_out;
                next_state <= WRITE_WAITING;
            else  
                next_state <= WRITE_GET_DATA;
            end if;

        elsif current_state = WRITE_WAITING then 
            if busy = '0' then
                next_state <= WRITE_DO;
            else 
                next_state <= WRITE_WAITING;
            end if;
        elsif current_state = WRITE_DO then
            WnR <= '1';
            oE <= '0';
            cpuData <= write_data;
            cpuAddr <= write_addr;
            if hit = '1' then
                next_state <= IDLE;
            else
                next_state <= WRITE_DO;
            end if;
        end if;

        if rising_edge(CLOCK) then
            current_state <= next_state;
        end if;
    end process;




    STIMULUS : process
    begin

    uart_data_out_stb <= '0';
    uart_data_in_ack <= '0';


    wait for 50 ns;

    -- do a read

    uart_data_out <= "01000000";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;


    uart_data_out <= "00000010";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;

    wait until uart_data_in_stb = '1';
    wait for 10 ns;
    uart_data_in_ack <= '1';

    wait for 100 ns;

    uart_data_in_ack <= '0';


    -- WRITE



    uart_data_out <= "00000000";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;


    uart_data_out <= "00000010";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;

    uart_data_out <= "11111111";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;



    -- WRITE

    wait for 100 ns;


    uart_data_out <= "00000000";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;


    uart_data_out <= "00000011";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;

    uart_data_out <= "10101010";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;


    -- WRITE

    wait for 100 ns;


    uart_data_out <= "00000000";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;


    uart_data_out <= "00000100";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;

    uart_data_out <= "11110000";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 250 ns;

    -- do a read

    uart_data_out <= "01000000";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;


    uart_data_out <= "00000011";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait until uart_data_in_stb = '1';
    wait for 10 ns;
    uart_data_in_ack <= '1';

    Wait for 100 ns;

    uart_data_in_ack <= '0';

    -- do a read

    uart_data_out <= "01000000";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;


    uart_data_out <= "00000100";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait until uart_data_in_stb = '1';
    wait for 10 ns;
    uart_data_in_ack <= '1';

    Wait for 100 ns;

    uart_data_in_ack <= '0';





        -- WRITE to A LOCATION

    wait for 100 ns;


    uart_data_out <= "00000000";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;


    uart_data_out <= "00000111";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;

    uart_data_out <= "10101010";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;


    -- WRITE OVER THAT LOCATION IN CACHE

    wait for 100 ns;


    uart_data_out <= "00000000";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;


    uart_data_out <= "11000111";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;

    uart_data_out <= "11110000";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 250 ns;


    -- READ THE ORIGIONAL LOCATION

    uart_data_out <= "01000000";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait for 50 ns;


    uart_data_out <= "00000111";
    uart_data_out_stb <= '1';
    wait for 20 ns;
    uart_data_out_stb <= '0';

    wait until uart_data_in_stb = '1';
    wait for 10 ns;
    uart_data_in_ack <= '1';

    Wait for 100 ns;

    uart_data_in_ack <= '0';



    wait;
    end process;

   clk_process :process
        constant clk_period : time := 20 ns;
   begin
        CLOCK <= '0';
        wait for clk_period/2;
        CLOCK <= '1';
        wait for clk_period/2;
   end process;



end Behavioral;