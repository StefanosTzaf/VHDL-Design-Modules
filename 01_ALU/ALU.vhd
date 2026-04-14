----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/20/2025 09:09:10 PM
-- Design Name: 
-- Module Name: ALU - Dataflow
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

entity ALU is
 port (
     A, B : in std_logic_vector(31 downto 0);
     OP : in std_logic_vector(2 downto 0);
     Signed_mode : in std_logic;
     Result: out std_logic_vector(31 downto 0);
     Z : out std_logic_vector(3 downto 0);
     N : out std_logic_vector(3 downto 0);
     C : out std_logic_vector(3 downto 0);
     V : out std_logic_vector(3 downto 0);
     S : out std_logic_vector(3 downto 0)
 );
end entity ALU;

architecture Dataflow of ALU is

    signal A0, A1, A2, A3, B0, B1, B2, B3, R0, R1, R2, R3: std_logic_vector(7 downto 0);
    signal Signed_mode_fix: std_logic_vector(7 downto 0);
    signal Sum_s0, Sum_s1, Sum_s2, Sum_s3: signed(8 downto 0);
    signal Sum_u0, Sum_u1, Sum_u2, Sum_u3: unsigned(8 downto 0);
    signal Sub_u0, Sub_u1, Sub_u2, Sub_u3: unsigned(8 downto 0);
    
begin

    A0 <= A(7 downto 0);
    A1 <= A(15 downto 8);
    A2 <= A(23 downto 16);
    A3 <= A(31 downto 24);
    
    B0 <= B(7 downto 0);
    B1 <= B(15 downto 8);
    B2 <= B(23 downto 16);
    B3 <= B(31 downto 24);
    Signed_mode_fix <= (others=>Signed_mode);
    
    -- needed in saturation
    Sum_s0 <= resize(signed(A0), 9) + resize(signed(B0), 9);
    Sum_u0 <= resize(unsigned(A0), 9) + resize(unsigned(B0), 9);
    
-- ADD
    R0<= (std_logic_vector( signed(A0) + signed(B0)) and Signed_mode_fix) or 
         (std_logic_vector( unsigned(A0) + unsigned(B0)) and not Signed_mode_fix)
          when OP = "000" else
          
-- SUB
         (std_logic_vector( signed(A0) - signed(B0)) and Signed_mode_fix) or 
         (std_logic_vector( unsigned(A0) - unsigned(B0)) and not Signed_mode_fix)
          when OP = "001" else
          
-- MAX
        A0 when (OP="100" and Signed_mode='1' and signed(A0) >= signed(B0)) else
        B0 when (OP="100" and Signed_mode='1' and signed(A0) < signed(B0)) else
        A0 when (OP="100" and Signed_mode='0' and unsigned(A0) >= unsigned(B0)) else
        B0 when (OP="100" and Signed_mode='0' and unsigned(A0) < unsigned(B0)) else

-- SAT_ADD

    -- SIGNED overflow positive  > 127
        "01111111" 
        when (OP="101" and Signed_mode='1' and Sum_s0 > to_signed(127, 9)) else

    -- SIGNED overflow negative < -128
        "10000000"
        when (OP="101" and Signed_mode='1' and Sum_s0 < to_signed(-128, 9)) else

    -- SIGNED normal in-range
        std_logic_vector(Sum_s0(7 downto 0))
        when (OP="101" and Signed_mode='1') else

    -- UNSIGNED overflow > 255
        "11111111"
        when (OP="101" and Signed_mode='0' and Sum_u0 > 255) else

    -- UNSIGNED normal in-range
        std_logic_vector(Sum_u0(7 downto 0))
        when (OP="101" and Signed_mode='0') else
        
-- LSL
        A0(6 downto 0) & '0' when OP = "110" else
        
--ASR      
        B0(7) & B0(7 downto 1) when (OP = "111" )else
--AND    
        A0 and B0 when OP = "010" else
--XOR    
        A0 xor B0 when OP = "011" else
      
    (others=>'0');
    
-- -----------------------------------------------SECOND NUMBER-----------------------------------------------
    Sum_s1 <= resize(signed(A1), 9) + resize(signed(B1), 9);
    Sum_u1 <= resize(unsigned(A1), 9) + resize(unsigned(B1), 9);
    
-- ADD
    R1<= (std_logic_vector( signed(A1) + signed(B1)) and Signed_mode_fix) or 
         (std_logic_vector( unsigned(A1) + unsigned(B1)) and not Signed_mode_fix)
          when OP = "000" else
          
-- SUB
         (std_logic_vector( signed(A1) - signed(B1)) and Signed_mode_fix) or 
         (std_logic_vector( unsigned(A1) - unsigned(B1)) and not Signed_mode_fix)
          when OP = "001" else
          
-- MAX
        A1 when (OP="100" and Signed_mode='1' and signed(A1) >= signed(B1)) else
        B1 when (OP="100" and Signed_mode='1' and signed(A1) < signed(B1)) else
        A1 when (OP="100" and Signed_mode='0' and unsigned(A1) >= unsigned(B1)) else
        B1 when (OP="100" and Signed_mode='0' and unsigned(A1) < unsigned(B1)) else

-- SAT_ADD

    -- SIGNED overflow positive  > 127
        "01111111" 
        when (OP="101" and Signed_mode='1' and Sum_s1 > to_signed(127, 9)) else

    -- SIGNED overflow negative < -128
        "10000000"
        when (OP="101" and Signed_mode='1' and Sum_s1 < to_signed(-128, 9)) else

    -- SIGNED normal in-range
        std_logic_vector(Sum_s1(7 downto 0))
        when (OP="101" and Signed_mode='1') else

    -- UNSIGNED overflow > 255
        "11111111"
        when (OP="101" and Signed_mode='0' and Sum_u1 > 255) else

    -- UNSIGNED normal in-range
        std_logic_vector(Sum_u1(7 downto 0))
        when (OP="101" and Signed_mode='0') else
        
-- LSL
        A1(6 downto 0) & '0' when OP = "110" else
        
--ASR      
        B1(7) & B1(7 downto 1) when (OP = "111" )else
--AND    
        A1 and B1 when OP = "010" else
--XOR    
        A1 xor B1 when OP = "011" else    
      
    (others=>'0');
  

-- -----------------------------------------------THIRD NUMBER-----------------------------------------------
    Sum_s2 <= resize(signed(A2), 9) + resize(signed(B2), 9);
    Sum_u2 <= resize(unsigned(A2), 9) + resize(unsigned(B2), 9);
    
-- ADD
    R2<= (std_logic_vector( signed(A2) + signed(B2)) and Signed_mode_fix) or 
         (std_logic_vector( unsigned(A2) + unsigned(B2)) and not Signed_mode_fix)
          when OP = "000" else
          
-- SUB
         (std_logic_vector( signed(A2) - signed(B2)) and Signed_mode_fix) or 
         (std_logic_vector( unsigned(A2) - unsigned(B2)) and not Signed_mode_fix)
          when OP = "001" else
          
-- MAX
        A2 when (OP="100" and Signed_mode='1' and signed(A2) >= signed(B2)) else
        B2 when (OP="100" and Signed_mode='1' and signed(A2) < signed(B2)) else
        A2 when (OP="100" and Signed_mode='0' and unsigned(A2) >= unsigned(B2)) else
        B2 when (OP="100" and Signed_mode='0' and unsigned(A2) < unsigned(B2)) else

-- SAT_ADD

    -- SIGNED overflow positive  > 127
        "01111111" 
        when (OP="101" and Signed_mode='1' and Sum_s2 > to_signed(127, 9)) else

    -- SIGNED overflow negative < -128
        "10000000"
        when (OP="101" and Signed_mode='1' and Sum_s2 < to_signed(-128, 9)) else

    -- SIGNED normal in-range
        std_logic_vector(Sum_s2(7 downto 0))
        when (OP="101" and Signed_mode='1') else

    -- UNSIGNED overflow > 255
        "11111111"
        when (OP="101" and Signed_mode='0' and Sum_u2 > 255) else

    -- UNSIGNED normal in-range
        std_logic_vector(Sum_u2(7 downto 0))
        when (OP="101" and Signed_mode='0') else
        
-- LSL
        A2(6 downto 0) & '0' when OP = "110" else
        
--ASR
        B2(7) & B2(7 downto 1) when (OP = "111" )else
--AND    
        A2 and B2 when OP = "010" else
--XOR    
        A2 xor B2 when OP = "011" else
      
    (others=>'0');
    
    
-- -----------------------------------------------FOURTH NUMBER-----------------------------------------------
    Sum_s3 <= resize(signed(A3), 9) + resize(signed(B3), 9);
    Sum_u3 <= resize(unsigned(A3), 9) + resize(unsigned(B3), 9);
    
-- ADD
    R3<= (std_logic_vector( signed(A3) + signed(B3)) and Signed_mode_fix) or 
         (std_logic_vector( unsigned(A3) + unsigned(B3)) and not Signed_mode_fix)
          when OP = "000" else
          
-- SUB
         (std_logic_vector( signed(A3) - signed(B3)) and Signed_mode_fix) or 
         (std_logic_vector( unsigned(A3) - unsigned(B3)) and not Signed_mode_fix)
          when OP = "001" else
          
-- MAX
        A3 when (OP="100" and Signed_mode='1' and signed(A3) >= signed(B3)) else
        B3 when (OP="100" and Signed_mode='1' and signed(A3) < signed(B3)) else
        A3 when (OP="100" and Signed_mode='0' and unsigned(A3) >= unsigned(B3)) else
        B3 when (OP="100" and Signed_mode='0' and unsigned(A3) < unsigned(B3)) else

-- SAT_ADD

    -- SIGNED overflow positive  > 127
        "01111111" 
        when (OP="101" and Signed_mode='1' and Sum_s3 > to_signed(127, 9)) else

    -- SIGNED overflow negative < -128
        "10000000"
        when (OP="101" and Signed_mode='1' and Sum_s3 < to_signed(-128, 9)) else

    -- SIGNED normal in-range
        std_logic_vector(Sum_s3(7 downto 0))
        when (OP="101" and Signed_mode='1') else

    -- UNSIGNED overflow > 255
        "11111111"
        when (OP="101" and Signed_mode='0' and Sum_u3 > 255) else

    -- UNSIGNED normal in-range
        std_logic_vector(Sum_u3(7 downto 0))
        when (OP="101" and Signed_mode='0') else
        
-- LSL
        A3(6 downto 0) & '0' when OP = "110" else
        
--ASR      
        B3(7) & B3(7 downto 1) when (OP = "111" )else
--AND    
        A3 and B3 when OP = "010" else
--XOR    
        A3 xor B3 when OP = "011" else
      
    (others=>'0');
-- AND and OR can be executed without seperating the numbers    
    Result <= R3 & R2 & R1 & R0;

                                    
-- FLAGS
     
    -- Zero FLAG
    Z(0) <= '1' when R0 = "00000000" else '0';
    Z(1) <= '1' when R1 = "00000000" else '0';
    Z(2) <= '1' when R2 = "00000000" else '0';
    Z(3) <= '1' when R3 = "00000000" else '0';
    
    -- Negative FLAG
    N(0) <= R0(7) when Signed_mode='1' else '0';
    N(1) <= R1(7) when Signed_mode='1' else '0';
    N(2) <= R2(7) when Signed_mode='1' else '0';
    N(3) <= R3(7) when Signed_mode='1' else '0';
    
    -- oVerflow FLAG
    V(0) <= '1' when Signed_mode='1' and (
           (OP="000" and (A0(7) = B0(7)) and (R0(7) /= A0(7))) or
           (OP="001" and (A0(7) /= B0(7)) and (R0(7) /= A0(7))) or
           (OP="110" and ((A0(7) xor A0(6)) = '1'))
       )
       
       else '0';
    
    V(1) <= '1' when Signed_mode='1' and (
       (OP="000" and (A1(7) = B1(7)) and (R1(7) /= A1(7))) or
       (OP="001" and (A1(7) /= B1(7)) and (R1(7) /= A1(7))) or
       (OP="110" and ((A1(7) xor A1(6)) = '1'))
   )
   else '0';

    V(2) <= '1' when Signed_mode='1' and (
       (OP="000" and (A2(7) = B2(7)) and (R2(7) /= A2(7))) or
       (OP="001" and (A2(7) /= B2(7)) and (R2(7) /= A2(7))) or
       (OP="110" and ((A2(7) xor A2(6)) = '1'))
   )
   else '0';

    V(3) <= '1' when Signed_mode='1' and (
       (OP="000" and (A3(7) = B3(7)) and (R3(7) /= A3(7))) or
       (OP="001" and (A3(7) /= B3(7)) and (R3(7) /= A3(7)))or
       (OP="110" and ((A3(7) xor A3(6)) = '1'))
   )
   else '0';

    -- Carry flag
    Sub_u0 <= resize(unsigned(A0), 9) - resize(unsigned(B0), 9);
    Sub_u1 <= resize(unsigned(A1), 9) - resize(unsigned(B1), 9);
    Sub_u2 <= resize(unsigned(A2), 9) - resize(unsigned(B2), 9);
    Sub_u3 <= resize(unsigned(A3), 9) - resize(unsigned(B3), 9);
    
    C(0) <= Sum_u0(8) when (OP="000" and Signed_mode='0') else
            Sub_u0(8) when (OP="001" and Signed_mode='0') else
            A0(7) when (OP = "110" and Signed_mode='0') else -- carry for LSL
            '0';
    
    C(1) <= Sum_u1(8) when (OP="000" and Signed_mode='0') else
            Sub_u1(8) when (OP="001" and Signed_mode='0') else
            A1(7) when (OP = "110" and Signed_mode='0') else
            '0';
    
    C(2) <= Sum_u2(8) when (OP="000" and Signed_mode='0') else
            Sub_u2(8) when (OP="001" and Signed_mode='0') else
            A2(7) when (OP = "110" and Signed_mode='0') else
            '0';
    
    C(3) <= Sum_u3(8) when (OP="000" and Signed_mode='0') else
            Sub_u3(8) when (OP="001" and Signed_mode='0') else
            A3(7) when (OP = "110" and Signed_mode='0') else
            '0';
            
    -- Saturation FLAG
    S(0) <= '1' when (OP="101" and Signed_mode='1' and 
                     (Sum_s0 > to_signed(127, 9) or Sum_s0 < to_signed(-128, 9))) else
            '1' when (OP="101" and Signed_mode='0' and Sum_u0 > to_unsigned(255,9)) else
            '0';
    
    S(1) <= '1' when (OP="101" and Signed_mode='1' and 
                     (Sum_s1 > to_signed(127, 9) or Sum_s1 < to_signed(-128, 9))) else
            '1' when (OP="101" and Signed_mode='0' and Sum_u1 > to_unsigned(255,9)) else
            '0';
    
    S(2) <= '1' when (OP="101" and Signed_mode='1' and 
                     (Sum_s2 > to_signed(127, 9) or Sum_s2 < to_signed(-128, 9))) else
            '1' when (OP="101" and Signed_mode='0' and Sum_u2 > to_unsigned(255,9)) else
            '0';
    
    S(3) <= '1' when (OP="101" and Signed_mode='1' and 
                     (Sum_s3 > to_signed(127, 9) or Sum_s3 < to_signed(-128, 9))) else
            '1' when (OP="101" and Signed_mode='0' and Sum_u3 > to_unsigned(255,9)) else
            '0';
            
            
end Dataflow;
