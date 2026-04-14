    ----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/31/2025 02:46:17 PM
-- Design Name: 
-- Module Name: Bubble_sort_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Bubble_sort_tb is
--  Port ( );
end Bubble_sort_tb;

architecture Behavioral of Bubble_sort_tb is
    constant AWIDTH    : natural := 10;
    constant DWIDTH    : natural := 32;
    constant N_ITEMS   : natural := 8;
    constant CLK_PERIOD : time := 10 ns;
    
    signal clk_tb      : std_logic := '0';
    signal reset_tb    : std_logic := '1';
    signal data_out_tb : std_logic_vector(DWIDTH-1 downto 0);
    signal done_tb     : std_logic;
    
    type std_logic_vector_array is array (0 to N_ITEMS - 1) of std_logic_vector(31 downto 0);
    constant input_data : std_logic_vector_array :=
    (X"00000001", X"000000A1", X"000000B2", X"00000003", X"00000004", X"000000F4", X"00000000", X"FFFFFFFF");
    
    component Bubble_sort
        Port ( 
            clk      : in STD_LOGIC;
            reset    : in STD_LOGIC;
            Data_Out : out std_logic_vector(DWIDTH-1 downto 0);
            done     : out std_logic
        );
    end component;

begin
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    uut : Bubble_sort
        port map (
            clk      => clk_tb,
            reset    => reset_tb,
            Data_Out => data_out_tb,
            done     => done_tb
        );
    
    test : process 
        variable read_index  : integer :=0;
        variable test_passed : boolean := true;
        
        variable expected_results : std_logic_vector_array := input_data;
        variable temp             : std_logic_vector(31 downto 0);
        variable swapped          : boolean;
    begin
    
        for i in 0 to N_ITEMS-2 loop
            swapped := false;
            for j in 0 to N_ITEMS-i-2 loop
                if unsigned(expected_results(j)) > unsigned(expected_results(j+1)) then
                    temp := expected_results(j);
                    expected_results(j) := expected_results(j+1);
                    expected_results(j+1) := temp;
                    swapped := true;
                end if;
            end loop;
            if not swapped then
                exit;
            end if;
        end loop;
        
        report "Testbench: Expected Results calculated." severity note;
    
        reset_tb <= '1';
        wait for 100 ns;
        wait until rising_edge(clk_tb);
        reset_tb <= '0';
        
        -- Wait till the sorting finishes (Synchronous check to avoid glitches)
        wait until done_tb = '1';  
        

        -- Add 1ns to simulation time by 1 ns to step out of the current delta cycle.
        -- Without this in behavioral simulation we have problems of race because of zero-delay updates.
        -- This ensures all signals are stable before waiting for the next falling edge.
        wait for 1 ns;
        -- Wait for the first valid data to appear wait for the falling edge to be 
        -- sure we have no problems with setup time.
        wait until falling_edge(clk_tb);
        
        report "Sorting finished. Starting RAM readback..." severity note;
       
        for i in 0 to N_ITEMS-1 loop
             
            if data_out_tb /= expected_results(i) then
                report "ERROR at index " &
                    integer'image(i) &
                    " Expected=" & integer'image(to_integer(unsigned(expected_results(i)))) &
                    " Got=" & integer'image(to_integer(unsigned(data_out_tb)))
                severity error;
                test_passed := false;
            end if;

            if i < N_ITEMS-1 then
                wait until falling_edge(clk_tb);
            end if;
        end loop;

        if test_passed then
            report "SORT VERIFICATION FINISHED SUCCESSFULLY" severity note;
        else
            report "SORT VERIFICATION FINISHED NOT SUCCESSFULLY" severity failure;
        end if;
        wait for 100 sec;
     end process;
end Behavioral;
