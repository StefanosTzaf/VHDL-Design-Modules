----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2025 02:14:22 PM
-- Design Name: 
-- Module Name: ALU_Sim - Testbench
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

entity ALU_Sim is
--  Port ( );
end ALU_Sim;

architecture Testbench of ALU_Sim is
    signal A_sim, B_sim : std_logic_vector(31 downto 0);
    signal Result_sim : std_logic_vector(31 downto 0);
    signal OP_sim : std_logic_vector(2 downto 0);
    signal Signed_mode_sim : std_logic;
    signal Z_sim, N_sim, C_sim, V_sim, S_sim : std_logic_vector(3 downto 0);
    
    -- Signals to give values to each byte and to be able to see i through waveform
    signal A0_sim, A1_sim, A2_sim, A3_sim : std_logic_vector(7 downto 0);
    signal B0_sim, B1_sim, B2_sim, B3_sim : std_logic_vector(7 downto 0);
    
    -- Signals so as to check results easier in waveforms
    signal R0_sim, R1_sim, R2_sim, R3_sim : std_logic_vector(7 downto 0);
    
    
    component ALU
        port (
            A : in std_logic_vector(31 downto 0);
            B : in std_logic_vector(31 downto 0);
            Result : out std_logic_vector(31 downto 0);
            OP : in std_logic_vector(2 downto 0);
            Signed_mode : in std_logic;
            Z : out std_logic_vector(3 downto 0);
            N : out std_logic_vector(3 downto 0);
            C : out std_logic_vector(3 downto 0);
            V : out std_logic_vector(3 downto 0);
            S : out std_logic_vector(3 downto 0)
        );
    end component;
    
begin

    A_sim <= A3_sim & A2_sim & A1_sim & A0_sim;
    B_sim <= B3_sim & B2_sim & B1_sim & B0_sim;
    R0_sim <= Result_sim(7 downto 0);
    R1_sim <= Result_sim(15 downto 8);
    R2_sim <= Result_sim(23 downto 16);
    R3_sim <= Result_sim(31 downto 24);

    uut: ALU
        port map(
            A => A_sim,
            B => B_sim,
            Result => Result_sim,
            OP => OP_sim,
            Signed_mode => Signed_mode_sim,
            Z => Z_sim,
            N => N_sim,
            C => C_sim,
            V => V_sim,
            S => S_sim
        );

    test: process is
        begin
        -- First are the tests with unsigned numbers so as to change it only one time in simulation window (unsigned results will be one after another)
        
            -- ===================== TEST 1: ADD Unsigned (no overflow) =====================
            -- A = [10, 20, 30, 40], B = [5, 15, 25, 35]
            -- Expected Result: R0=15, R1=35, R2=55, R3=75 | Flags: Z=0000, N=0000, C=0000 , S=0000, V=0000
            A0_sim <= std_logic_vector(to_unsigned(10, 8));
            A1_sim <= std_logic_vector(to_unsigned(20, 8));
            A2_sim <= std_logic_vector(to_unsigned(30, 8));
            A3_sim <= std_logic_vector(to_unsigned(40, 8));
            B0_sim <= std_logic_vector(to_unsigned(5, 8));
            B1_sim <= std_logic_vector(to_unsigned(15, 8));
            B2_sim <= std_logic_vector(to_unsigned(25, 8));
            B3_sim <= std_logic_vector(to_unsigned(35, 8));
            Signed_mode_sim <= '0';
            OP_sim <= "000";  -- ADD
            wait for 20 ns;
            
            -- ===================== TEST 2: ADD Unsigned (with carry) =====================
            -- A = [200, 150, 100, 50], B = [100, 150, 2, 250]
            -- Expected Result: R0=44, R1=44, R2=102, R3=44 | Flags: C=1011 and the others 0
            A0_sim <= std_logic_vector(to_unsigned(200, 8));
            A1_sim <= std_logic_vector(to_unsigned(150, 8));
            A2_sim <= std_logic_vector(to_unsigned(100, 8));
            A3_sim <= std_logic_vector(to_unsigned(50, 8));
            B0_sim <= std_logic_vector(to_unsigned(100, 8));
            B1_sim <= std_logic_vector(to_unsigned(150, 8));
            B2_sim <= std_logic_vector(to_unsigned(2, 8));
            B3_sim <= std_logic_vector(to_unsigned(250, 8));
            Signed_mode_sim <= '0';
            OP_sim <= "000";  -- ADD
            wait for 20 ns;
            
            -- ===================== TEST 3: SUB Unsigned (no carry) =====================
            -- A = [100, 200, 150, 250], B = [50, 150, 150, 125]
            -- Expected Result: R0=50, R1=50, R2=0, R3=125 | Flags: C=0000 N=0000 Z=0100
            A0_sim <= std_logic_vector(to_unsigned(100, 8));
            A1_sim <= std_logic_vector(to_unsigned(200, 8));
            A2_sim <= std_logic_vector(to_unsigned(150, 8));
            A3_sim <= std_logic_vector(to_unsigned(250, 8));
            B0_sim <= std_logic_vector(to_unsigned(50, 8));
            B1_sim <= std_logic_vector(to_unsigned(150, 8));
            B2_sim <= std_logic_vector(to_unsigned(150, 8));
            B3_sim <= std_logic_vector(to_unsigned(125, 8));
            Signed_mode_sim <= '0';
            OP_sim <= "001";  -- SUB
            wait for 20 ns;
            
            -- ===================== TEST 4: SUB Unsigned (with carry) =====================
            -- A = [50, 100, 75, 125], B = [100, 200, 150, 250]
            -- Expected Result: underflow | Flags: C=1111
            A0_sim <= std_logic_vector(to_unsigned(50, 8));
            A1_sim <= std_logic_vector(to_unsigned(100, 8));
            A2_sim <= std_logic_vector(to_unsigned(75, 8));
            A3_sim <= std_logic_vector(to_unsigned(125, 8));
            B0_sim <= std_logic_vector(to_unsigned(100, 8));
            B1_sim <= std_logic_vector(to_unsigned(200, 8));
            B2_sim <= std_logic_vector(to_unsigned(150, 8));
            B3_sim <= std_logic_vector(to_unsigned(250, 8));
            Signed_mode_sim <= '0';
            OP_sim <= "001";  -- SUB
            wait for 20 ns;
            
            
            -- ===================== TEST 5: MAX Unsigned =====================
            -- A = [50, 150, 100, 200], B = [100, 200, 50, 250]
            -- Expected Result: R0=100, R1=200, R2=100, R3=250
            A0_sim <= std_logic_vector(to_unsigned(50, 8));
            A1_sim <= std_logic_vector(to_unsigned(150, 8));
            A2_sim <= std_logic_vector(to_unsigned(100, 8));
            A3_sim <= std_logic_vector(to_unsigned(200, 8));
            B0_sim <= std_logic_vector(to_unsigned(100, 8));
            B1_sim <= std_logic_vector(to_unsigned(200, 8));
            B2_sim <= std_logic_vector(to_unsigned(50, 8));
            B3_sim <= std_logic_vector(to_unsigned(250, 8));
            Signed_mode_sim <= '0';
            OP_sim <= "100";  -- MAX
            wait for 20 ns;
            
            
            -- ===================== TEST 6: SAT_ADD Unsigned (with saturation) =====================
            -- A = [255, 100, 150, 20], B = [16, 200, 150, 24]
            -- Expected Result: R0=255(sat), R1=255(sat), R2=255(sat), R3=44 | Flags: S=0111
            A0_sim <= std_logic_vector(to_unsigned(255, 8));
            A1_sim <= std_logic_vector(to_unsigned(100, 8));
            A2_sim <= std_logic_vector(to_unsigned(150, 8));
            A3_sim <= std_logic_vector(to_unsigned(20, 8));
            B0_sim <= std_logic_vector(to_unsigned(16, 8));
            B1_sim <= std_logic_vector(to_unsigned(200, 8));
            B2_sim <= std_logic_vector(to_unsigned(150, 8));
            B3_sim <= std_logic_vector(to_unsigned(24, 8));
            Signed_mode_sim <= '0';
            OP_sim <= "101";  -- SAT_ADD
            wait for 20 ns;
            
    -- signed numbers change it in simulation window (radix to be set to signed decimal)
    
            -- ===================== TEST 7 ADD Signed (no overflow) =====================
            -- A = [10, -20, 30, -35], B = [5, 15, -25, 35]
            -- Expected Result: R0=15, R1=-5, R2=5, R3=0 | Flags: N=0010, Z=1000
            A0_sim <= std_logic_vector(to_signed(10, 8));
            A1_sim <= std_logic_vector(to_signed(-20, 8));
            A2_sim <= std_logic_vector(to_signed(30, 8));
            A3_sim <= std_logic_vector(to_signed(-35, 8));
            B0_sim <= std_logic_vector(to_signed(5, 8));
            B1_sim <= std_logic_vector(to_signed(15, 8));
            B2_sim <= std_logic_vector(to_signed(-25, 8));
            B3_sim <= std_logic_vector(to_signed(35, 8));
            Signed_mode_sim <= '1';
            OP_sim <= "000";  -- ADD
            wait for 20 ns;
    
            -- ===================== TEST 8: ADD Signed (with overflow) =====================
            -- A = [127, 100, -100, -128], B = [10, 50, -50, -10]
            -- Expected Result: overflow on bytes 0 and 3 | Flags: V=1111
            A0_sim <= std_logic_vector(to_signed(127, 8));
            A1_sim <= std_logic_vector(to_signed(100, 8));
            A2_sim <= std_logic_vector(to_signed(-100, 8));
            A3_sim <= std_logic_vector(to_signed(-128, 8));
            B0_sim <= std_logic_vector(to_signed(10, 8));
            B1_sim <= std_logic_vector(to_signed(50, 8));
            B2_sim <= std_logic_vector(to_signed(-50, 8));
            B3_sim <= std_logic_vector(to_signed(-10, 8));
            Signed_mode_sim <= '1';
            OP_sim <= "000";  -- ADD
            wait for 20 ns;
            
            -- ===================== TEST 9: SUB Signed =====================
            -- A = [50, -50, 100, -100], B = [25, 25, -25, -25]
            -- Expected Result: R0=25, R1=-75, R2=125, R3=-75 | Flags: N=1010
            A0_sim <= std_logic_vector(to_signed(50, 8));
            A1_sim <= std_logic_vector(to_signed(-50, 8));
            A2_sim <= std_logic_vector(to_signed(100, 8));
            A3_sim <= std_logic_vector(to_signed(-100, 8));
            B0_sim <= std_logic_vector(to_signed(25, 8));
            B1_sim <= std_logic_vector(to_signed(25, 8));
            B2_sim <= std_logic_vector(to_signed(-25, 8));
            B3_sim <= std_logic_vector(to_signed(-25, 8));
            Signed_mode_sim <= '1';
            OP_sim <= "001";  -- SUB
            wait for 20 ns;
            
            
            -- ===================== TEST 10 : SUB Signed (with overflow) =====================
            -- A = [127, -128, 100, -100], B = [-10, 10, -50, 50]
            -- Expected Flags: V=1111
            A0_sim <= std_logic_vector(to_signed(127, 8));
            A1_sim <= std_logic_vector(to_signed(-128, 8));
            A2_sim <= std_logic_vector(to_signed(100, 8));
            A3_sim <= std_logic_vector(to_signed(-100, 8));
            B0_sim <= std_logic_vector(to_signed(-10, 8));
            B1_sim <= std_logic_vector(to_signed(10, 8));
            B2_sim <= std_logic_vector(to_signed(-50, 8));
            B3_sim <= std_logic_vector(to_signed(50, 8));
            Signed_mode_sim <= '1';
            OP_sim <= "001";  -- SUB
            wait for 20 ns;
            
            -- ===================== TEST 11: MAX Signed =====================
            -- A = [50, -50, 100, -100], B = [25, -25, 75, -75]
            -- Expected Result: R0=50, R1=-25, R2=100, R3=-75
            A0_sim <= std_logic_vector(to_signed(50, 8));
            A1_sim <= std_logic_vector(to_signed(-50, 8));
            A2_sim <= std_logic_vector(to_signed(100, 8));
            A3_sim <= std_logic_vector(to_signed(-100, 8));
            B0_sim <= std_logic_vector(to_signed(25, 8));
            B1_sim <= std_logic_vector(to_signed(-25, 8));
            B2_sim <= std_logic_vector(to_signed(75, 8));
            B3_sim <= std_logic_vector(to_signed(-75, 8));
            Signed_mode_sim <= '1';
            OP_sim <= "100";  -- MAX
            wait for 20 ns;
        

        
            -- ===================== TEST 12: SAT_ADD Signed (with saturation) =====================
            -- A = [127, 5, -10, -128], B = [10, -111, 50, -10]
            -- Expected Result: R0=127(sat), R1=-106, R2=40, R3=-128(sat) | Flags: S=1001 N = 1010
            A0_sim <= std_logic_vector(to_signed(127, 8));
            A1_sim <= std_logic_vector(to_signed(5, 8));
            A2_sim <= std_logic_vector(to_signed(-10, 8));
            A3_sim <= std_logic_vector(to_signed(-128, 8));
            B0_sim <= std_logic_vector(to_signed(10, 8));
            B1_sim <= std_logic_vector(to_signed(-111, 8));
            B2_sim <= std_logic_vector(to_signed(50, 8));
            B3_sim <= std_logic_vector(to_signed(-10, 8));
            Signed_mode_sim <= '1';
            OP_sim <= "101";  -- SAT_ADD
            wait for 20 ns;
                
            
            
            -- ===================== TEST 13: AND in hexadecimal =====================
            -- A = x"FF_AA_55_0F", B = x"0F_55_AA_FF"
            -- Expected Result: R0=x"0F", R1=x"00", R2=x"00", R3=x"0F", Z = 0110
            A0_sim <= x"0F";
            A1_sim <= x"55";
            A2_sim <= x"AA";
            A3_sim <= x"FF";
            B0_sim <= x"FF";
            B1_sim <= x"AA";
            B2_sim <= x"55";
            B3_sim <= x"0F";
            OP_sim <= "010";  -- AND
            Signed_mode_sim <= '0';
            wait for 20 ns;
            
            -- ===================== TEST 14: XOR σε 16αδικό =====================
            -- A = x"FF_AA_55_0F", B = x"0F_55_AA_FF"
            -- Expected Result: R0=x"F0", R1=x"FF", R2=x"FF", R3=x"F0"
            A0_sim <= x"0F";
            A1_sim <= x"55";
            A2_sim <= x"AA";
            A3_sim <= x"FF";
            B0_sim <= x"FF";
            B1_sim <= x"AA";
            B2_sim <= x"55";
            B3_sim <= x"0F";
            Signed_mode_sim <= '0';
            OP_sim <= "011";  -- XOR
            wait for 20 ns;
        
            -- ===================== TEST 15: LSL (Logical Shift Left A)SIGNED =====================
            -- A = x"FF_AA_55_0F"
            -- A0=0x0F (00001111) << 1 = 0x1E (00011110)
            -- A1=0x55 (01010101) << 1 = 0xAA (10101010)
            -- A2=0x80 (10000000) << 1 = 0x00 (00000000)
            -- A3=0x40 (01000000) << 1 = 0x80 (10000000)
            -- Expected Result: R0=x"1E", R1=x"AA", R2=x"00", R3=x"80" V=1110
            A0_sim <= x"0F";
            A1_sim <= x"55";
            A2_sim <= x"80";
            A3_sim <= x"40";
            B0_sim <= x"00";
            B1_sim <= x"00";
            B2_sim <= x"00";
            B3_sim <= x"00";
            OP_sim <= "110";  -- LSL
            Signed_mode_sim<= '1';
            wait for 20 ns;
            
            -- ===================== TEST 16: LSL (Logical Shift Left A)UNSIGNED =====================
            -- A = x"FF_AA_55_0F"
            -- A0=0x0F (00001111) << 1 = 0x1E (00011110)
            -- A1=0x55 (01010101) << 1 = 0xAA (10101010)
            -- A2=0x80 (10000000) << 1 = 0x00 (00000000)
            -- A3=0x40 (01000000) << 1 = 0x80 (10000000)
            -- Expected Result: R0=x"1E", R1=x"AA", R2=x"00", R3=x"80" C=0100
            A0_sim <= x"0F";
            A1_sim <= x"55";
            A2_sim <= x"80";
            A3_sim <= x"40";
            B0_sim <= x"00";
            B1_sim <= x"00";
            B2_sim <= x"00";
            B3_sim <= x"00";
            OP_sim <= "110";  -- LSL
            Signed_mode_sim<= '0';
            wait for 20 ns;
            
            -- ===================== TEST 17: ASR (Arithmetic Shift Right B) =====================
            -- B = x"0F_55_AA_FF"
            -- B0=0xFF (11111111) >> 1 = 0xFF (11111111) - sign extends
            -- B1=0xAA (10101010) >> 1 = 0xD5 (11010101) - sign extends
            -- B2=0x55 (01010101) >> 1 = 0x2A (00101010) - zero extends
            -- B3=0x0F (00001111) >> 1 = 0x07 (00000111) - zero extends
            -- Expected Result: R0=x"FF", R1=x"D5", R2=x"2A", R3=x"07"
            A0_sim <= x"0F";
            A1_sim <= x"55";
            A2_sim <= x"AA";
            A3_sim <= x"FF";
            B0_sim <= x"FF";
            B1_sim <= x"AA";
            B2_sim <= x"55";
            B3_sim <= x"0F";
            OP_sim <= "111";  -- ASR
            wait for 20 ns;
            
     end process;
     
end Testbench;
