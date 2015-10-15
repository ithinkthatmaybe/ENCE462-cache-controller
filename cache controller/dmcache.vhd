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


-- TODOS:
--  -synchronisation, halfcpuAddr clock cycle is needed to loadcpuAddr memory address
--  -Main memory - look aside or look through
--  -UART interface
--  
--
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.math_real.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dmcache is
    generic (
        size           : integer := 8;  -- number of memory words         
        addr_width     : integer := 8;  -- number of address bits
        data_width     : integer := 8;    -- number of data bits
        block_width    : integer := 4;    -- cache line width (data_widths)

        tag_width      :   integer := 4;
        index_width    :   integer := 2;
        offset_width   :   integer := 2);
    Port ( 
        clock       : in    STD_LOGIC;
        reset       : in    STD_LOGIC;
        WnR         : in    STD_LOGIC;
        oE          : in    STD_LOGIC;
        busy        : out   STD_LOGIC;
        cpuAddr     : in    STD_LOGIC_VECTOR (addr_width-1 downto 0);
        cpuData     : inout STD_LOGIC_VECTOR (data_width-1 downto 0);
        hit         : out   STD_LOGIC;   
        memAddr     : out   STD_LOGIC_VECTOR (addr_width-1 downto 0);
        memData     : inout STD_LOGIC_VECTOR (data_width-1 downto 0);
        memOE       : out   STD_LOGIC;
        memnWE      : out   STD_LOGIC;
        state_out   : out   std_logic_vector(2 downto 0)
        );
end dmcache;



architecture Behavioral of dmcache is

    component cache_mem is
      generic (
        AddressWidth    : integer;
        WordLength      : integer;
        Size            : integer
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

    subtype state_type is std_logic_vector(2 downto 0);
    constant STATE_IDLE     : state_type := "000";
    constant STATE_READ : state_type := "001";
    constant STATE_FETCH   : state_type := "010";
    constant STATE_WRITE : state_type := "011";
    --constant STATE_WAITING  : state_type := "11";
    constant STATE_WRITEBACK : state_type := "100";

   --signal state_reg        : state_type;
    signal state            : state_type := STATE_IDLE;
    signal state_next       : state_type;

    signal stored_tag   : std_logic_vector(tag_width-1 downto 0);

    signal stored_word  : std_logic_vector(data_width-1 downto 0);
    signal word_in      : std_logic_vector(data_width-1 downto 0);

    signal fetch_addr   : std_logic_vector (addr_width-1 downto 0);
    signal fetch_finished : std_logic;

    signal writeback_addr   : std_logic_vector (addr_width-1 downto 0);
    signal writeback_finished : std_logic;

    signal DataInEnable : std_logic := '0';
    signal tagDataInEnable : std_logic := '0';

    signal cache_addr_in : std_logic_vector (addr_width-1 downto 0);

    alias tag_address   is cache_addr_in(addr_width-1 downto offset_width + index_width);
    alias line_index    is cache_addr_in(offset_width + index_width-1 downto offset_width);
    alias line_offset   is cache_addr_in(offset_width-1 downto 0);
    
    
begin
    state_out <= state;

    cache_control : process(WnR, oE, clock, state)
    begin
        -- state transition logic
        if state = STATE_IDLE then
            tagDataInEnable <= DataInEnable;
            DataInEnable <= '0';
            if WnR = '0' and oE = '1' then 
                state_next <= STATE_READ;
            elsif WnR = '1' and oE = '0' then
                writeback_addr <= cpuAddr;
                state_next <= STATE_WRITE;
                DataInEnable <= '1';        
            else
                state_next <= STATE_IDLE;
            end if;

        elsif state = STATE_READ then
            DataInEnable <= '0';
            if oE = '0' then
                state_next <= STATE_IDLE; --read location is cached              
            elsif stored_tag /= tag_address then
                fetch_addr(addr_width-1 downto offset_width) <= cpuAddr;
                tagDataInEnable <= '0';
                DataInEnable <= '1';
                --state_next <= STATE_FETCH;
                state_next <= STATE_IDLE;
                tagDataInEnable <= '1';
            else
                state_next <= STATE_READ;
            end if;

        elsif state = STATE_FETCH then
  -- dont write the tag until the fetch is finished
            DataInEnable <= '1';
            if fetch_finished = '1' then 
                --DataInEnable <= '0';          -- REMOVED, check for bugs
                tagDataInEnable <= DataInEnable;
                state_next <= STATE_READ;
            else
                state_next <= STATE_FETCH;
            end if;

        elsif state = STATE_WRITE then
            --state_next <= STATE_WRITEBACK;
            state_next <= STATE_IDLE;
            --if WnR = '0' then
            --    DataInEnable <= '0';
            --    state_next <= STATE_IDLE;
            --else
            --    state_next <= STATE_WRITE;
            --end if;

        elsif state = STATE_WRITEBACK then
            if writeback_finished = '1' then
                --fetch_addr(addr_width-1 downto offset_width) <= cpuAddr;
                --state_next <= STATE_FETCH;
                state_next <= STATE_IDLE;

            else
                state_next <= STATE_WRITEBACK;
            end if;

        else
            state_next <= STATE_IDLE;
        end if;

        -- moore outputs
        if state = STATE_IDLE then
            busy <= '0';
            cpuData <= (others => 'Z');
            cache_addr_in <= cpuAddr;
            word_in <= cpuData;
            memAddr <= (others => 'Z');
            memData <= (others => 'Z');
            memOE <= '0';
            memnWE <= '1';          
        elsif state = STATE_READ then
            memAddr <= (others => 'Z');
            memData <= (others => 'Z');
            memOE <= '0';
            memnWE <= '1'; 
            busy <= '1';
            cpuData <= stored_word;
            cache_addr_in <= cpuAddr;
        elsif state = STATE_WRITE then
            busy <= '1';
            cache_addr_in <= cpuAddr;
        --elsif state = STATE_FETCH then -- missed read
        --    busy <= '1';
        --    word_in <= memData;
        --    cpuData <= (others => 'Z');
        --    memData <= (others => 'Z');
        --    memAddr <= fetch_addr;
        --    cache_addr_in <= fetch_addr;
        --    memOE <= '1';
        --    memnWE <= '1';
        --elsif state = STATE_WRITEBACK then
        --    cache_addr_in <= writeback_addr;
        --    cpuData <= (others => 'Z');
        --    memData <= stored_word;
        --    memAddr <= writeback_addr;
        --    memOE <= '0';
        --    memnWE <= '0';
        end if;

        -- state transition
        if rising_edge(clock) then
            state <= state_next;
        end if;
    end process;


    --WRITEBACK: process
    --    variable counter : integer;
    --begin
    --    writeback_finished <= '0';
    --    wait until state'event and state = STATE_WRITEBACK;
    --    for counter in 0 to 1 loop
    --        wait until rising_edge(clock);
    --    end loop;
    --    writeback_finished <= '1';
    --    wait until state'event and state = STATE_IDLE;
    --end process;


    --FETCHER: process
    --  variable counter  : integer;
    --begin
    --    fetch_finished <= '0';
    --    wait until state'event and state = STATE_FETCH;
    --    for counter in 0 TO 2**offset_width-1 loop
    --        fetch_addr(offset_width-1 downto 0) <= std_logic_vector(to_unsigned(counter, offset_width));
    --        wait until rising_edge(clock);
    --        wait until rising_edge(clock);
    --    end loop;
    --    fetch_finished <= '1';
    --    wait until state'event and state = STATE_READ;
    --end process;


    tag_comparator: process(tag_address, stored_tag)
    begin
        if (tag_address = stored_tag) then
            hit <= '1';
            --memAddr <= (others => 'Z');
        else
            hit <= '0';
        end if;
    end process;

    
    cache_memory : cache_mem
    generic map
    (
        addressWidth => index_width+offset_width,
        wordLength => data_width,
        Size => 2**(index_width+offset_width)
    )
    port map
    (
        DataInEnable => DataInEnable,
        DataIn => word_in,
        Address => cache_addr_in(index_width+offset_width-1 downto 0), -- line index and offset
        DataOut => stored_word, 
        clock => clock,
        reset => reset
    );
    
    cache_directory : cache_mem
    generic map
    (
        addressWidth => index_width,
        wordLength    => tag_width,
        Size      => 2**index_width     
    )
    port map
    (
        DataInEnable => tagDataInEnable,
        DataIn => tag_address,      
        Address => line_index,
        DataOut => stored_tag,
        clock => clock,
        reset => reset
    );
end Behavioral;