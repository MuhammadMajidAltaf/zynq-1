----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/04/2015 03:22:01 AM
-- Design Name: 
-- Module Name: offload_test - Behavioral
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

entity offload_test is
--  Port ( );
end offload_test;

architecture Behavioral of offload_test is

  component offload_top
    port (
  clk : in std_logic;
  reset_n : in std_logic;

  s_axis_tvalid : in std_logic;
  s_axis_tready : out std_logic;
  s_axis_tdata : in std_logic_vector(31 downto 0);
  s_axis_tkeep : in std_logic_vector(3 downto 0);
  s_axis_tlast : in std_logic;

  m_axis_tvalid : out std_logic;
  m_axis_tready : in std_logic;
  m_axis_tdata : out std_logic_vector(31 downto 0);
  m_axis_tkeep : out std_logic_vector(3 downto 0);
  m_axis_tlast : out std_logic;
  dbg : out std_logic_vector(3 downto 0)

         );
  end component offload_top;


  signal clk : std_logic;
  signal rst : std_logic;

  signal s_axis_tvalid, s_axis_tready, s_axis_tlast, m_axis_tvalid, m_axis_tready, m_axis_tlast : std_logic;
  signal s_axis_tdata, m_axis_tdata : std_logic_vector(31 downto 0);
  signal s_axis_tkeep, m_axis_tkeep : std_logic_vector(3 downto 0);

  signal dbg : std_logic_vector(3 downto 0);

begin

  uut : offload_top
  port map (
            clk => clk,
            reset_n => rst,

            s_axis_tvalid => s_axis_tvalid,
            s_axis_tready => s_axis_tready,
            s_axis_tdata => s_axis_tdata,
            s_axis_tkeep => s_axis_tkeep,
            s_axis_tlast => s_axis_tlast,
            m_axis_tvalid => m_axis_tvalid,
            m_axis_tready => m_axis_tready,
            m_axis_tdata => m_axis_tdata,
            m_axis_tkeep => m_axis_tkeep,
            m_axis_tlast => m_axis_tlast,

            dbg => dbg
           );

  PCLK: process
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;

  PSTD: process
  begin
    rst <= '0';
    wait for 20 ns;
    rst <= '1';
    m_axis_tready <= '1';
    wait until s_axis_tready = '1';

    wait for 10ns;
    s_axis_tvalid <= '1';
    s_axis_tlast <= '0';
    s_axis_tkeep <= "1111";
    s_axis_tdata <= x"0ffa0ffb";
    wait for 10 ns;
    s_axis_tdata <= x"00000001";
    wait for 10 ns;
    s_axis_tdata <= x"00000002";
    wait for 10 ns;
    s_axis_tdata <= x"00000003";
    wait for 10 ns;
    s_axis_tdata <= x"00000004";
    wait for 10 ns;
    s_axis_tdata <= x"00000005";
    wait for 10 ns;
    s_axis_tdata <= x"00000006";
    wait for 10 ns;
    s_axis_tdata <= x"00000007";
    wait for 10 ns;
    s_axis_tdata <= x"00000008";
    wait for 10 ns;
    s_axis_tdata <= x"00000009";
    wait for 10 ns;
    s_axis_tdata <= x"0000000a";
    wait for 10 ns;
    s_axis_tdata <= x"0000000b";
    wait for 10 ns;
    s_axis_tdata <= x"0000000c";
    wait for 10 ns;
    s_axis_tdata <= x"0000000d";
    wait for 10 ns;
    s_axis_tlast <= '1';
    s_axis_tdata <= x"0000000e";
    wait for 10 ns;
    s_axis_tvalid <= '0';
    s_axis_tlast <= '0';

    wait for 1 us;

  end process;
end Behavioral;
