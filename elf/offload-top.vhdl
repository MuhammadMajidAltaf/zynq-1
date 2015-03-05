---------------------------------------------------------------------------
-- Author   : Ali Lown <ali@lown.me.uk>
-- File          : offload_top.vhdl
--
-- Abstract :
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

---------------------------------------------------------------------------
Entity offload_top is 
---------------------------------------------------------------------------
port 
(
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
end entity;


---------------------------------------------------------------------------
Architecture offload_top_1 of offload_top is
---------------------------------------------------------------------------

  component offload
  port (
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

  end component offload;

  type state_type is (s0_check, s1_have_header, s2_compute, s3_results);
  signal state : state_type;

  --ignoring SP, LR, PC registers
  type reg_array is array (0 to 13) of std_logic_vector(31 downto 0);
  signal regs : reg_array;
  signal off_en : std_logic := '0';
  signal off_tri : std_logic;
  signal reg_count : natural := 0;

  constant PKT_MAGIC : std_logic_vector(31 downto 0) := x"0FFA0FFB";

begin

  u_offload : offload
  port map (clk => clk,
            en => off_en,
            tri => off_tri,
            r0 => regs(0),
            r1 => regs(1),
            r2 => regs(2),
            r3 => regs(3),
            r4 => regs(4),
            r5 => regs(5),
            r6 => regs(6),
            r7 => regs(7),
            r8 => regs(8),
            r9 => regs(9),
            r10 => regs(10),
            r11 => regs(11),
            r12 => regs(12),
            r13 => regs(13)
           );

  FSM: process(clk, reset_n)
  begin
    if clk'event and clk='1' then
      if reset_n = '0' then
        state <= s0_check;
        off_en <= '0';
        off_tri <= '0';
        s_axis_tready <= '1';
        m_axis_tvalid <= '0';
        reg_count <= 0;
        dbg <= "0000";
      else
        case state is
          when s0_check =>
            m_axis_tvalid <= '0';
            off_tri <= '0';
            for i in 0 to 13 loop
              regs(i) <= (others => 'Z');
            end loop;

            if s_axis_tvalid = '1' then
              if s_axis_tkeep = "0000" and s_axis_tdata = PKT_MAGIC then
                reg_count <= 0;
                state <= s1_have_header;
              end if;
            end if;

          when s1_have_header =>
            off_tri <= '1';

            --Next 14 data items are the register starting states - assuming no partial packets
            if not (s_axis_tkeep = "1111" ) or s_axis_tlast = '1' or s_axis_tvalid = '0' then
              state <= s0_check;
            end if;

            regs(reg_count) <= s_axis_tdata;
            reg_count <= reg_count + 1;
            if reg_count = 14 then
              state <= s2_compute;
            end if;

          when s2_compute =>
            off_en <= '1';
            off_tri <= '0';
            for i in 0 to 13 loop
              regs(i) <= (others => 'Z');
            end loop;
            state <= s3_results;
            reg_count <= 0;

          when s3_results =>
            off_en <= '0';

            m_axis_tvalid <= '1';
            m_axis_tkeep <= "1111";
            if m_axis_tready = '1' then
              m_axis_tlast <= '0';
              if reg_count = 0 then
                m_axis_tdata <= PKT_MAGIC;
              else
                m_axis_tdata <= regs(reg_count-1);
              end if;
              reg_count <= reg_count + 1;
              if reg_count = 15 then
                m_axis_tlast <= '1';
                state <= s0_check;
              end if;
            end if;

        end case;
      end if;
    end if;
  end process;
end architecture offload_top_1;

