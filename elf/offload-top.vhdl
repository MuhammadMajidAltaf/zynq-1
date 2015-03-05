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

  type state_type is (s0_check, s1_have_header, s2_compute, s3_results);
  signal state : state_type;

  --ignoring SP, LR, PC registers
  type reg_array is array (0 to 13) of std_logic_vector(31 downto 0);
  signal regs_in, regs_out : reg_array;
  signal reg_count : natural := 0;

  constant PKT_MAGIC : std_logic_vector(31 downto 0) := x"0FFA0FFB";

begin

  s_axis_tready <= s_axis_tready_out;

  FSM: process(clk, reset_n, s_axis_tvalid, s_axis_tkeep, s_axis_tdata, m_axis_tready)
  begin
    if clk'event and clk='1' then
      if reset_n = '0' then
        state <= s0_check;
        s_axis_tready_out <= '0';
        m_axis_tvalid <= '0';
        reg_count <= 0;
        dbg <= "0000";
      else
        case state is
          when s0_check =>
            s_axis_tready_out <= '1';
            m_axis_tvalid <= '0';
            m_axis_tlast <= '0';

            if s_axis_tvalid = '1' then
              if s_axis_tkeep = "0000" and s_axis_tdata = PKT_MAGIC then
                reg_count <= 0;
                state <= s1_have_header;
              end if;
            end if;

          when s1_have_header =>
            dbg(1) <= '1';

            --Next 14 data items are the register starting states - assuming no partial packets
            if not (s_axis_tkeep = "1111" ) or s_axis_tlast = '1' or s_axis_tvalid = '0' then
              state <= s0_check;
            else
              regs_in(reg_count) <= s_axis_tdata;
              if reg_count = 13 then
                state <= s2_compute;
              else
                reg_count <= reg_count + 1;
              end if;
            end if;

          when s2_compute =>
            dbg(3) <= '1';
            state <= s3_results;
            reg_count <= 0;

          when s3_results =>
            m_axis_tvalid <= '1';
            m_axis_tkeep <= "1111";
            if m_axis_tready = '1' then
              m_axis_tlast <= '0';
              if reg_count = 0 then
                m_axis_tdata <= PKT_MAGIC;
              else
                m_axis_tdata <= regs_out(reg_count-1);
              end if;
              if reg_count = 14 then
                m_axis_tlast <= '1';
                state <= s0_check;
              else
                reg_count <= reg_count + 1;
              end if;
            end if;

        end case;
      end if;
    end if;
  end process;
end architecture offload_top_1;

