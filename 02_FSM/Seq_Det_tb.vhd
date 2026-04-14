----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2025 09:17:07 PM
-- Design Name: 
-- Module Name: Seq_Det_tb - Behavioral
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

entity Seq_Det_tb is
end Seq_Det_tb;

architecture Behavioral of Seq_Det_tb is

    component Seq_Det is
        Port ( Clock : in STD_LOGIC;
               Reset : in STD_LOGIC;
               Din : in STD_LOGIC;
               ERR : out STD_LOGIC);
    end component;
    
    signal Clock_tb : std_logic := '0';
    signal Reset_tb : std_logic := '1';
    signal Din_tb   : std_logic := 'X';
    signal ERR_tb   : std_logic;
    constant CLK_period : time := 10 ns;
begin

    uut: Seq_Det
    port map(        
        Clock => Clock_tb,
        Reset => Reset_tb,
        Din   => Din_tb,
        ERR   => ERR_tb
    );
    
    Clock_Process : process
    begin
        Clock_tb <= '0';
        wait for CLK_period/2;
        Clock_tb <= '1';
        wait for CLK_period/2;
    end process;
    
    test: process
    begin

        Reset_tb <= '1';
        wait for 100 ns;
        -- without this line does not work properly -- input changes in the rising edge
        wait until rising_edge(Clock_tb);
        Reset_tb <= '0';


        Din_tb <= '0'; wait for 1*CLK_period;
        Din_tb <= '0'; wait for 1*CLK_period;
        Din_tb <= '0'; wait for 1*CLK_period;
        
        Din_tb <= '0'; wait for 1*CLK_period;
        Din_tb <= '0'; wait for 1*CLK_period;
        Din_tb <= '1'; wait for 1*CLK_period;
        
        Din_tb <= '0'; wait for 1*CLK_period;
        Din_tb <= '1'; wait for 1*CLK_period;
        Din_tb <= '0'; wait for 1*CLK_period;
        
        Din_tb <= '0'; wait for 1*CLK_period;
        Din_tb <= '1'; wait for 1*CLK_period;
        Din_tb <= '1'; wait for 1*CLK_period;
        
        -- although there are 3 1's in row no exit
        Din_tb <= '1'; wait for 1*CLK_period;
        Din_tb <= '0'; wait for 1*CLK_period;
        Din_tb <= '0'; wait for 1*CLK_period;

        Din_tb <= '1'; wait for 1*CLK_period;
        Din_tb <= '0'; wait for 1*CLK_period;
        Din_tb <= '1'; wait for 1*CLK_period;
        
        Din_tb <= '1'; wait for 1*CLK_period;
        Din_tb <= '1'; wait for 1*CLK_period;
        Din_tb <= '0'; wait for 1*CLK_period;
        
        -- only here we expect to see ERR = 1
        Din_tb <= '1'; wait for 1*CLK_period;
        Din_tb <= '1'; wait for 1*CLK_period;
        Din_tb <= '1'; wait for 1*CLK_period;
        
        -- add this so as to see the exit (output is registered so we will see it on cycle after)
        Din_tb <= '0'; wait for 1*CLK_period;
    end process;
end Behavioral;
