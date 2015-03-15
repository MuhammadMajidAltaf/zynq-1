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
  signal s_axis_tready_out : std_logic;

  constant PKT_MAGIC : std_logic_vector(31 downto 0) := x"0FFA0FFB";

--<<< BEGIN SIGNALS
signal t_40_s, t_50_s, t_60_s, t_70_s, t_80_s, t_90_s, t_a0_s, t_b0_s, t_c0_s, t_d0_s, r3_3c, r3_40, r3_44, r3_48, r3_4c, r3_50, r3_54, r3_58, r3_5c, r3_60, r3_64, r3_68, r3_6c, r3_70, r3_74, r3_78, r3_7c, r3_80, r3_84, r3_88, r3_8c, r3_90, r3_94, r3_98, r3_9c, r3_a0, r3_a4, r3_a8, r3_ac, r3_b0, r3_b4, r3_b8, r3_bc, r3_c0, r3_c4, r3_c8, r3_cc, r3_d0, r0_d4, r0_d8 : std_logic_vector(31 downto 0);
--->>> END SIGNALS

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
              if s_axis_tkeep = "1111" and s_axis_tdata = PKT_MAGIC then
                dbg(0) <= '1';
                reg_count <= 0;
                state <= s1_have_header;
              end if;
            end if;

          when s1_have_header =>
            dbg(1) <= '1';

            --Next 14 data items are the register starting states - assuming no partial packets
            if not (s_axis_tkeep = "1111" ) or (s_axis_tlast = '1' and not (reg_count = 13)) or s_axis_tvalid = '0' then
              dbg(2) <= '1';
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

---<<< BEGIN LOGIC
r3_3c <= std_logic_vector(unsigned(regs_in(0)) + unsigned(regs_in(1)));
t_40_s <= std_logic_vector(unsigned(r3_3c) sll TO_INTEGER(unsigned(regs_in(0))));
r3_40 <= std_logic_vector(unsigned(regs_in(1)) or unsigned(t_40_s));
r3_44 <= std_logic_vector(unsigned(r3_40) xor unsigned(regs_in(0)));
r3_48 <= std_logic_vector(unsigned(r3_44) - unsigned(regs_in(1)));
r3_4c <= std_logic_vector(RESIZE(unsigned(r3_4c) * unsigned(regs_in(0)) + unsigned(regs_in(1)), 32));
t_50_s <= std_logic_vector(unsigned(r3_4c) sll TO_INTEGER(unsigned(regs_in(0))));
r3_50 <= std_logic_vector(unsigned(regs_in(1)) or unsigned(t_50_s));
r3_54 <= std_logic_vector(unsigned(r3_50) xor unsigned(regs_in(0)));
r3_58 <= std_logic_vector(unsigned(r3_54) - unsigned(regs_in(1)));
r3_5c <= std_logic_vector(RESIZE(unsigned(r3_5c) * unsigned(regs_in(0)) + unsigned(regs_in(1)), 32));
t_60_s <= std_logic_vector(unsigned(r3_5c) sll TO_INTEGER(unsigned(regs_in(0))));
r3_60 <= std_logic_vector(unsigned(regs_in(1)) or unsigned(t_60_s));
r3_64 <= std_logic_vector(unsigned(r3_60) xor unsigned(regs_in(0)));
r3_68 <= std_logic_vector(unsigned(r3_64) - unsigned(regs_in(1)));
r3_6c <= std_logic_vector(RESIZE(unsigned(r3_6c) * unsigned(regs_in(0)) + unsigned(regs_in(1)), 32));
t_70_s <= std_logic_vector(unsigned(r3_6c) sll TO_INTEGER(unsigned(regs_in(0))));
r3_70 <= std_logic_vector(unsigned(regs_in(1)) or unsigned(t_70_s));
r3_74 <= std_logic_vector(unsigned(r3_70) xor unsigned(regs_in(0)));
r3_78 <= std_logic_vector(unsigned(r3_74) - unsigned(regs_in(1)));
r3_7c <= std_logic_vector(RESIZE(unsigned(r3_7c) * unsigned(regs_in(0)) + unsigned(regs_in(1)), 32));
t_80_s <= std_logic_vector(unsigned(r3_7c) sll TO_INTEGER(unsigned(regs_in(0))));
r3_80 <= std_logic_vector(unsigned(regs_in(1)) or unsigned(t_80_s));
r3_84 <= std_logic_vector(unsigned(r3_80) xor unsigned(regs_in(0)));
r3_88 <= std_logic_vector(unsigned(r3_84) - unsigned(regs_in(1)));
r3_8c <= std_logic_vector(RESIZE(unsigned(r3_8c) * unsigned(regs_in(0)) + unsigned(regs_in(1)), 32));
t_90_s <= std_logic_vector(unsigned(r3_8c) sll TO_INTEGER(unsigned(regs_in(0))));
r3_90 <= std_logic_vector(unsigned(regs_in(1)) or unsigned(t_90_s));
r3_94 <= std_logic_vector(unsigned(r3_90) xor unsigned(regs_in(0)));
r3_98 <= std_logic_vector(unsigned(r3_94) - unsigned(regs_in(1)));
r3_9c <= std_logic_vector(RESIZE(unsigned(r3_9c) * unsigned(regs_in(0)) + unsigned(regs_in(1)), 32));
t_a0_s <= std_logic_vector(unsigned(r3_9c) sll TO_INTEGER(unsigned(regs_in(0))));
r3_a0 <= std_logic_vector(unsigned(regs_in(1)) or unsigned(t_a0_s));
r3_a4 <= std_logic_vector(unsigned(r3_a0) xor unsigned(regs_in(0)));
r3_a8 <= std_logic_vector(unsigned(r3_a4) - unsigned(regs_in(1)));
r3_ac <= std_logic_vector(RESIZE(unsigned(r3_ac) * unsigned(regs_in(0)) + unsigned(regs_in(1)), 32));
t_b0_s <= std_logic_vector(unsigned(r3_ac) sll TO_INTEGER(unsigned(regs_in(0))));
r3_b0 <= std_logic_vector(unsigned(regs_in(1)) or unsigned(t_b0_s));
r3_b4 <= std_logic_vector(unsigned(r3_b0) xor unsigned(regs_in(0)));
r3_b8 <= std_logic_vector(unsigned(r3_b4) - unsigned(regs_in(1)));
r3_bc <= std_logic_vector(RESIZE(unsigned(r3_bc) * unsigned(regs_in(0)) + unsigned(regs_in(1)), 32));
t_c0_s <= std_logic_vector(unsigned(r3_bc) sll TO_INTEGER(unsigned(regs_in(0))));
r3_c0 <= std_logic_vector(unsigned(regs_in(1)) or unsigned(t_c0_s));
r3_c4 <= std_logic_vector(unsigned(r3_c0) xor unsigned(regs_in(0)));
r3_c8 <= std_logic_vector(unsigned(r3_c4) - unsigned(regs_in(1)));
r3_cc <= std_logic_vector(RESIZE(unsigned(r3_cc) * unsigned(regs_in(0)) + unsigned(regs_in(1)), 32));
t_d0_s <= std_logic_vector(unsigned(r3_cc) sll TO_INTEGER(unsigned(regs_in(0))));
r3_d0 <= std_logic_vector(unsigned(regs_in(1)) or unsigned(t_d0_s));
r0_d4 <= std_logic_vector(unsigned(regs_in(0)) xor unsigned(r3_d0));
r0_d8 <= std_logic_vector(unsigned(r0_d4) - unsigned(regs_in(1)));
regs_out(0) <= r0_d8;
regs_out(1) <= regs_in(1);
regs_out(2) <= regs_in(2);
regs_out(3) <= r3_d0;
regs_out(4) <= regs_in(4);
regs_out(5) <= regs_in(5);
regs_out(6) <= regs_in(6);
regs_out(7) <= regs_in(7);
regs_out(8) <= regs_in(8);
regs_out(9) <= regs_in(9);
regs_out(10) <= regs_in(10);
regs_out(11) <= regs_in(11);
regs_out(12) <= regs_in(12);
regs_out(13) <= regs_in(13);
--->>> END LOGIC

end architecture offload_top_1;

