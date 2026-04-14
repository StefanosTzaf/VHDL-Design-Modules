----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2025 08:00:36 PM
-- Design Name: 
-- Module Name: Seq_Det - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Seq_Det is
    Port ( Clock : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Din : in STD_LOGIC;
           ERR : out STD_LOGIC);
end Seq_Det;

architecture Behavioral of Seq_Det is

    type States is
    (Start, D0_is_1, D0_not_1, D1_is_1, D1_not_1);
    
    signal current_state, next_state: States;
    -- output is registered because i had some glitches in Post Synthesis timing simulation
    -- more details in Report.
    signal ERR_next : std_logic;

begin
    -- registers for current state and output, asynchronous reset
    SYNC: process(Clock, Reset)
    begin 
        if (Reset = '1') then
            current_state <= Start;
            ERR <= '0';
        elsif (rising_edge(Clock)) then
            current_state <= next_state;
            ERR <= ERR_next;
        end if;
    end process;
    
    
    ASYNC: process(Din, current_state)
    begin
        -- initialization (avoiding latches)
        next_state <= Start; 
        ERR_next   <= '0';
        
        case current_state is
            when Start => 
                if(Din = '1') then
                    next_state <= D0_is_1;
                else
                    next_state <= D0_not_1;
                end if;
             when D0_is_1 =>
                if(Din = '1') then
                    next_state <= D1_is_1;
                else
                    next_state <= D1_not_1;
                end if;
             when D0_not_1 =>
                next_state <= D1_not_1;
             when D1_not_1 =>
                next_state <= Start;
             when D1_is_1 =>
                if(Din = '1') then
                    ERR_next <= '1';
                    next_state <= Start;
                else
                    next_state <= Start;
                end if;
            when others => next_state <= Start;
         end case;
                
    end process;
    
end Behavioral;