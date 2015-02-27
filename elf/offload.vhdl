----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2015 03:33:44 PM
-- Design Name: 
-- Module Name: offload - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity offload is
  Port (
  clk : in std_logic;
  tri : in std_logic;
  en : in std_logic;

  r0 : inout std_logic_vector(31 downto 0);
  r1 : inout std_logic_vector(31 downto 0);
  r2 : inout std_logic_vector(31 downto 0);
  r3 : inout std_logic_vector(31 downto 0);
  r4 : inout std_logic_vector(31 downto 0);
  r5 : inout std_logic_vector(31 downto 0);
  r6 : inout std_logic_vector(31 downto 0);
  r7 : inout std_logic_vector(31 downto 0);
  r8 : inout std_logic_vector(31 downto 0);
  r9 : inout std_logic_vector(31 downto 0);
  r10 : inout std_logic_vector(31 downto 0);
  r11 : inout std_logic_vector(31 downto 0);
  r12 : inout std_logic_vector(31 downto 0);
  r13 : inout std_logic_vector(31 downto 0)
  );
end offload;

architecture Behavioral of offload is

--<<< BEGIN SIGNALS
  signal t_40_s, t_50_s, t_60_s, t_70_s, t_80_s, t_90_s, t_a0_s, t_b0_s, t_c0_s, t_d0_s : std_logic_vector(31 downto 0);
--->>> END SIGNALS

begin

  LOGIC : process(clk)
  begin
  if clk'event and clk = '1' then
    if tri = '1' then
      r0 <= (others => 'Z');
      r1 <= (others => 'Z');
      r2 <= (others => 'Z');
      r3 <= (others => 'Z');
      r4 <= (others => 'Z');
      r5 <= (others => 'Z');
      r6 <= (others => 'Z');
      r7 <= (others => 'Z');
      r8 <= (others => 'Z');
      r9 <= (others => 'Z');
      r10 <= (others => 'Z');
      r11 <= (others => 'Z');
      r12 <= (others => 'Z');
      r13 <= (others => 'Z');
    else
      if en = '1' then

---<<< BEGIN LOGIC
    r3 <= std_logic_vector( unsigned(r0) + unsigned(r1));
  t_40_s <= std_logic_vector(unsigned(r3) sll TO_INTEGER(unsigned(r0)));
r3 <= std_logic_vector( unsigned(r1) or unsigned(t_40_s));
r3 <= std_logic_vector( unsigned(r3) xor unsigned(r0));
r3 <= std_logic_vector( unsigned(r3) - unsigned(r1));
r3 <= std_logic_vector(RESIZE(unsigned(r3) * unsigned(r0) + unsigned(r1), 32));
t_50_s <= std_logic_vector(unsigned(r3) sll TO_INTEGER(unsigned(r0)));
r3 <= std_logic_vector( unsigned(r1) or unsigned(t_50_s));
r3 <= std_logic_vector( unsigned(r3) xor unsigned(r0));
r3 <= std_logic_vector( unsigned(r3) - unsigned(r1));
r3 <= std_logic_vector(RESIZE(unsigned(r3) * unsigned(r0) + unsigned(r1), 32));
t_60_s <= std_logic_vector(unsigned(r3) sll TO_INTEGER(unsigned(r0)));
r3 <= std_logic_vector( unsigned(r1) or unsigned(t_60_s));
r3 <= std_logic_vector( unsigned(r3) xor unsigned(r0));
r3 <= std_logic_vector( unsigned(r3) - unsigned(r1));
r3 <= std_logic_vector(RESIZE(unsigned(r3) * unsigned(r0) + unsigned(r1), 32));
t_70_s <= std_logic_vector(unsigned(r3) sll TO_INTEGER(unsigned(r0)));
r3 <= std_logic_vector( unsigned(r1) or unsigned(t_70_s));
r3 <= std_logic_vector( unsigned(r3) xor unsigned(r0));
r3 <= std_logic_vector( unsigned(r3) - unsigned(r1));
r3 <= std_logic_vector(RESIZE(unsigned(r3) * unsigned(r0) + unsigned(r1), 32));
t_80_s <= std_logic_vector(unsigned(r3) sll TO_INTEGER(unsigned(r0)));
r3 <= std_logic_vector( unsigned(r1) or unsigned(t_80_s));
r3 <= std_logic_vector( unsigned(r3) xor unsigned(r0));
r3 <= std_logic_vector( unsigned(r3) - unsigned(r1));
r3 <= std_logic_vector(RESIZE(unsigned(r3) * unsigned(r0) + unsigned(r1), 32));
t_90_s <= std_logic_vector(unsigned(r3) sll TO_INTEGER(unsigned(r0)));
r3 <= std_logic_vector( unsigned(r1) or unsigned(t_90_s));
r3 <= std_logic_vector( unsigned(r3) xor unsigned(r0));
r3 <= std_logic_vector( unsigned(r3) - unsigned(r1));
r3 <= std_logic_vector(RESIZE(unsigned(r3) * unsigned(r0) + unsigned(r1), 32));
t_a0_s <= std_logic_vector(unsigned(r3) sll TO_INTEGER(unsigned(r0)));
r3 <= std_logic_vector( unsigned(r1) or unsigned(t_a0_s));
r3 <= std_logic_vector( unsigned(r3) xor unsigned(r0));
r3 <= std_logic_vector( unsigned(r3) - unsigned(r1));
r3 <= std_logic_vector(RESIZE(unsigned(r3) * unsigned(r0) + unsigned(r1), 32));
t_b0_s <= std_logic_vector(unsigned(r3) sll TO_INTEGER(unsigned(r0)));
r3 <= std_logic_vector( unsigned(r1) or unsigned(t_b0_s));
r3 <= std_logic_vector( unsigned(r3) xor unsigned(r0));
r3 <= std_logic_vector( unsigned(r3) - unsigned(r1));
r3 <= std_logic_vector(RESIZE(unsigned(r3) * unsigned(r0) + unsigned(r1), 32));
t_c0_s <= std_logic_vector(unsigned(r3) sll TO_INTEGER(unsigned(r0)));
r3 <= std_logic_vector( unsigned(r1) or unsigned(t_c0_s));
r3 <= std_logic_vector( unsigned(r3) xor unsigned(r0));
r3 <= std_logic_vector( unsigned(r3) - unsigned(r1));
r3 <= std_logic_vector(RESIZE(unsigned(r3) * unsigned(r0) + unsigned(r1), 32));
t_d0_s <= std_logic_vector(unsigned(r3) sll TO_INTEGER(unsigned(r0)));
r3 <= std_logic_vector( unsigned(r1) or unsigned(t_d0_s));
r0 <= std_logic_vector( unsigned(r0) xor unsigned(r3));
r0 <= std_logic_vector( unsigned(r0) - unsigned(r1));
--->>> END LOGIC

      end if;
    end if;
  end if;
end process;

end Behavioral;
