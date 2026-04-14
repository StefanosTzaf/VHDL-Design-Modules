----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/01/2026 09:47:02 PM
-- Design Name: 
-- Module Name: Bubble_sort - Behavioral
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

entity Bubble_sort is
    generic (
        AWIDTH: natural := 10; 
        DWIDTH: natural := 32
    );
    Port ( 
        clk      : in STD_LOGIC;
        reset    : in STD_LOGIC;
        Data_Out : out std_logic_vector(DWIDTH-1 downto 0);
        done     : out std_logic  -- added for simulation reasons , check report
    );
end Bubble_sort;

architecture Behavioral of Bubble_sort is

    -- items in RAM
    constant N_ITEMS : integer := 8; 

    -- Components
    component ROM is
        generic ( N : positive := 11; M : positive := 32 );
        port ( ADDR: in STD_LOGIC_VECTOR (N-1 downto 0); ROM_OUT: out STD_LOGIC_VECTOR (M-1 downto 0) );
    end component;

    component RAM is
        generic ( N : positive := 11; M : positive := 32 );
        port ( CLK: in STD_LOGIC; MemWrite: in STD_LOGIC; ADDR: in STD_LOGIC_VECTOR (N-1 downto 0); DATA_IN: in STD_LOGIC_VECTOR (M-1 downto 0); RAM_OUT: out STD_LOGIC_VECTOR (M-1 downto 0) );
    end component;
    
    type states is (
        S_RESET,
        S_LOAD,
        S_READ_1,
        S_READ_2,
        S_COMPARE, 
        S_SWAP_1,
        S_SWAP_2,
        S_DONE
    );
    
    -- Register current states
    signal r_state      : states;
    signal r_i          : integer range 0 to N_ITEMS;
    signal r_j          : integer range 0 to N_ITEMS;
    -- store ram values to registers because we dont want to read
    -- from ram every time (we are able to read one value a time)
    signal r_temp_val   : std_logic_vector(DWIDTH-1 downto 0);
    signal r_temp_val_2 : std_logic_vector(DWIDTH-1 downto 0);
    
    -- Next state logic
    signal next_state      : states;
    signal next_i          : integer range 0 to N_ITEMS;
    signal next_j          : integer range 0 to N_ITEMS;
    signal next_temp_val   : std_logic_vector(DWIDTH-1 downto 0);
    signal next_temp_val_2 : std_logic_vector(DWIDTH-1 downto 0);
    
    -- Memory Signals (for port mapping)
    signal rom_addr : std_logic_vector(AWIDTH-1 downto 0);
    signal rom_data : std_logic_vector(DWIDTH-1 downto 0);
    
    signal ram_addr : std_logic_vector(AWIDTH-1 downto 0);
    signal ram_din  : std_logic_vector(DWIDTH-1 downto 0);
    signal ram_dout : std_logic_vector(DWIDTH-1 downto 0);
    signal ram_we   : std_logic;
    
begin
    -- Port Maps with components of memories
    U_ROM: ROM generic map (N => AWIDTH, M => DWIDTH) 
               port map    (ADDR => rom_addr, ROM_OUT => rom_data);
           
    U_RAM: RAM generic map (N => AWIDTH, M => DWIDTH) 
               port map    (CLK => clk, MemWrite => ram_we, ADDR => ram_addr, DATA_IN => ram_din, RAM_OUT => ram_dout);
           
    -- Data_out shows to the current memory position that our program uses       
    Data_Out <= ram_dout;
    done     <= '1' when r_state = S_DONE else '0';
    
    -- sequational logic
    REGS: process(clk, reset) 
    begin
        if reset = '1' then
            r_state      <= S_RESET;
            r_i          <= 0;
            r_j          <= 0;
            r_temp_val   <= (others => '0');
            r_temp_val_2 <= (others => '0');
        elsif rising_edge(clk) then
            r_state      <= next_state;
            r_i          <= next_i;
            r_j          <= next_j;
            r_temp_val   <= next_temp_val;
            r_temp_val_2 <= next_temp_val_2;
        end if;
    end process;
    
    -- combinational logic
    FSM: process(r_state, r_i, r_j, r_temp_val, r_temp_val_2, rom_data, ram_dout)
    begin
        -- Default Assignments
        next_state      <= r_state;
        next_i          <= r_i;
        next_j          <= r_j;
        next_temp_val   <= r_temp_val;
        next_temp_val_2 <= r_temp_val_2;
        
        ram_we   <= '0';
        ram_addr <= (others => '0');
        ram_din  <= (others => '0');
        rom_addr <= (others => '0');
        
        case r_state is
        
            when S_RESET =>
            
                next_state <= S_LOAD;
            
            -- LOAD from ROM to RAM 
            when S_LOAD =>
            
                if (r_i < N_ITEMS) then
                    rom_addr <= std_logic_vector(to_unsigned(r_i, AWIDTH));
                    ram_addr <= std_logic_vector(to_unsigned(r_i, AWIDTH));
                    ram_din  <= rom_data;
                    ram_we   <= '1';
                    next_i   <= r_i + 1;
                else
                    next_state <= S_READ_1;
                    next_i     <= 0;
                    next_j     <= 0;
                end if;
                
           -- we cannot read two times in one cycle (distributed ram)
           when S_READ_1 =>
           
                ram_addr      <= std_logic_vector(to_unsigned(r_j, AWIDTH));
                next_temp_val <= ram_dout; -- first value [j] position, is now to a register
                next_state    <= S_READ_2;
                
           when S_READ_2 =>
           
                ram_addr <= std_logic_vector(to_unsigned(r_j + 1, AWIDTH));
                next_temp_val_2 <= ram_dout;
                -- ready to compare with register values
                next_state      <= S_COMPARE;
                
           when S_COMPARE =>
            
                if unsigned(r_temp_val) > unsigned(r_temp_val_2) then
                    next_state <= S_SWAP_1;
                else
                    -- continue to the next j
                    if r_j < (N_ITEMS - 2 - r_i) then
                        next_j     <= r_j + 1;
                        next_state <= S_READ_1;
                    else
                        -- if j cannot be increased continue to the next i
                        if r_i < (N_ITEMS - 2) then
                            next_i     <= r_i + 1;
                            next_j     <= 0;
                            next_state <= S_READ_1;
                        else
                            next_state <= S_DONE;
                            next_i     <= 0;
                        end if;
                    end if;
                end if;
           -- cannot swap in the same state two values
           when S_SWAP_1 =>
           
                ram_addr <= std_logic_vector(to_unsigned(r_j, AWIDTH));
                ram_din    <= r_temp_val_2; 
                ram_we     <= '1';
                next_state <= S_SWAP_2;

            when S_SWAP_2 =>
            
                ram_addr <= std_logic_vector(to_unsigned(r_j + 1, AWIDTH));
                ram_din  <= r_temp_val; 
                ram_we   <= '1';
                
                if r_j < (N_ITEMS - 2 - r_i) then
                    next_j     <= r_j + 1;
                    next_state <= S_READ_1;
                else
                    if r_i < (N_ITEMS - 2) then
                        next_i     <= r_i + 1;
                        next_j     <= 0;
                        next_state <= S_READ_1;
                    else
                        next_state <= S_DONE;
                        next_i     <= 0;
                    end if;
                end if;

            when S_DONE =>
                ram_addr <= std_logic_vector(to_unsigned(r_i, AWIDTH));
                if r_i < N_ITEMS - 1 then
                    next_i <= r_i + 1;
                else
                    next_i <= 0;
                end if;
                next_state <= S_DONE; 
                
            when others =>
                next_state <= S_RESET;
        end case;
    end process;
end Behavioral;