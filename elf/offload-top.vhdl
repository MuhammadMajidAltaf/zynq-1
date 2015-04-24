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
use IEEE.STD_LOGIC_MISC.ALL;

---------------------------------------------------------------------------
Entity offload_top is 
---------------------------------------------------------------------------
port
(
  clk : in std_logic;
  reset_n : in std_logic;

  s_axis_tvalid : in std_logic;
  s_axis_tready : out std_logic;
  s_axis_tdata : in std_logic_vector(511 downto 0);
  s_axis_tkeep : in std_logic_vector(63 downto 0);
  s_axis_tlast : in std_logic;

  m_axis_tvalid : out std_logic;
  m_axis_tready : in std_logic;
  m_axis_tdata : out std_logic_vector(511 downto 0);
  m_axis_tkeep : out std_logic_vector(63 downto 0);
  m_axis_tlast : out std_logic;

  dbg : out std_logic_vector(3 downto 0)
);
end entity;


---------------------------------------------------------------------------
Architecture offload_top_1 of offload_top is
---------------------------------------------------------------------------

  type state_type is (s_filling, s_full, s_draining);
  signal state : state_type;

  constant PIPELINE_DEPTH : integer := 3;
  constant NUM_REGS       : integer := 14;
  constant REG_SIZE       : integer := 32;

  constant STAGE_PROCESS  : integer := 2;
  constant STAGE_DATA_OUT : integer := 3;

  --ignoring SP, LR, PC registers
  type reg_array is array (0 to NUM_REGS-1) of std_logic_vector(REG_SIZE-1 downto 0);
  type regs_array is array(0 to PIPELINE_DEPTH-1) of reg_array;

  signal regs : regs_array;

  signal s_axis_tready_out : std_logic;

  signal pipeline_en : std_logic;
  signal pipeline_state : std_logic_vector(0 to PIPELINE_DEPTH-1);
  signal pipeline_state_feed : std_logic;

  constant PKT_MAGIC : std_logic_vector(31 downto 0) := x"0FFA0FFB";

begin

  s_axis_tready <= s_axis_tready_out;

  PIPELINE: process(clk, reset_n)
  begin
    if clk'event and clk = '0' then
      if pipeline_en = '0' then
        pipeline_state(0 to pipeline_state'length-1) <= (others => '0');
      else
        --Move stages at next clock
        pipeline_state(0) <= pipeline_state_feed;
        STAGES: for i in 0 to PIPELINE_DEPTH-2 loop
          pipeline_state(i+1) <= pipeline_state(i);
        end loop STAGES;

        --Stage 1 - clock in registers
        REGS_IN: for i in 0 to NUM_REGS-1 loop
          --TODO: endianess?
          regs(0)(i) <= s_axis_tdata(((i + 1) * REG_SIZE - 1) downto (i * REG_SIZE));
        end loop REGS_IN;

        --Stage 2 - process
        regs(2) <= regs(1);

        --Stage 3 - clock out registers
        m_axis_tdata(16*REG_SIZE-1 downto 15*REG_SIZE) <= PKT_MAGIC;
        REGS_OUT: for i in 0 to NUM_REGS-1 loop
          --TODO: endianess
          m_axis_tdata(((i + 1) * REG_SIZE - 1) downto (i * REG_SIZE)) <= regs(2)(i);
        end loop REGS_OUT;

      end if;
    end if;
  end process;

  FSM: process(clk, reset_n, s_axis_tvalid, s_axis_tkeep, s_axis_tdata, m_axis_tready, pipeline_en)
  begin
    if clk'event and clk='1' then
      if reset_n = '0' then
        state <= s_filling;
        s_axis_tready_out <= '0';
        m_axis_tvalid <= '0';
        dbg <= "0000";
        pipeline_en <= '0';
      else
        case state is
          --TODO: should really wait for tready. Hmm...:
          when s_filling =>
            s_axis_tready_out <= '1';
            m_axis_tvalid <= '0';
            m_axis_tlast <= '0';
            dbg(0) <= '1';

            if s_axis_tvalid = '1' and s_axis_tkeep = x"ffffffffffffffff" and s_axis_tdata(16*REG_SIZE-1 downto 15*REG_SIZE) = PKT_MAGIC then
              pipeline_en <= '1';
              pipeline_state_feed <= '1';
              --Triggers when almost full
              if and_reduce(pipeline_state(0 to pipeline_state'length-2)) = '1' then
                state <= s_full;
              end if;
            end if;

          when s_full =>
            m_axis_tvalid <= '1';
            m_axis_tkeep <= (others => '1');
            dbg(1) <= '1';

            if s_axis_tvalid = '1' and s_axis_tkeep = x"ffffffffffffffff" and s_axis_tdata(16*REG_SIZE-1 downto 15*REG_SIZE) = PKT_MAGIC then
              --no change
            else
              pipeline_state_feed <= '0';
              state <= s_draining;
            end if;

          when s_draining =>
            dbg(2) <= '1';
            pipeline_state_feed <= '0';
            if pipeline_state(STAGE_DATA_OUT-1) = '0' then
              pipeline_en <= '0';
              m_axis_tlast <= '1';
              state <= s_filling;
            end if;

        end case;
      end if;
    end if;
  end process;


  process(clk, state, pipeline_state)
--<<< BEGIN SIGNALS
variable r3_30, r3_34, r3_38, r3_3c, r3_40, r3_44, r3_48, r3_4c, r3_50, r0_54 : std_logic_vector(31 downto 0);
--->>> END SIGNALS
  begin
    if clk'event and clk = '0' and pipeline_state(STAGE_PROCESS-2) = '1' then
---<<< BEGIN LOGIC
r3_30 := std_logic_vector(unsigned(regs(0)(0)) + unsigned(regs(0)(1)));
r3_34 := std_logic_vector(RESIZE(unsigned(r3_30) * unsigned(regs(0)(0)) + unsigned(regs(0)(1)), 32));
r3_38 := std_logic_vector(RESIZE(unsigned(r3_34) * unsigned(regs(0)(0)) + unsigned(regs(0)(1)), 32));
r3_3c := std_logic_vector(RESIZE(unsigned(r3_38) * unsigned(regs(0)(0)) + unsigned(regs(0)(1)), 32));
r3_40 := std_logic_vector(RESIZE(unsigned(r3_3c) * unsigned(regs(0)(0)) + unsigned(regs(0)(1)), 32));
r3_44 := std_logic_vector(RESIZE(unsigned(r3_40) * unsigned(regs(0)(0)) + unsigned(regs(0)(1)), 32));
r3_48 := std_logic_vector(RESIZE(unsigned(r3_44) * unsigned(regs(0)(0)) + unsigned(regs(0)(1)), 32));
r3_4c := std_logic_vector(RESIZE(unsigned(r3_48) * unsigned(regs(0)(0)) + unsigned(regs(0)(1)), 32));
r3_50 := std_logic_vector(RESIZE(unsigned(r3_4c) * unsigned(regs(0)(0)) + unsigned(regs(0)(1)), 32));
r0_54 := std_logic_vector(RESIZE(unsigned(r3_50) * unsigned(regs(0)(0)) + unsigned(regs(0)(1)), 32));
regs(1)(0) <= r3_30;
regs(1)(1) <= r0_54;
regs(1)(2) <= r0_54;
regs(1)(3) <= r3_50;
regs(1)(4) <= r0_54;
regs(1)(5) <= r0_54;
regs(1)(6) <= r0_54;
regs(1)(7) <= r0_54;
regs(1)(8) <= r0_54;
regs(1)(9) <= r0_54;
regs(1)(10) <= r0_54;
regs(1)(11) <= r0_54;
regs(1)(12) <= r0_54;
regs(1)(13) <= r0_54;
--->>> END LOGIC
    end if;
  end process;

end architecture offload_top_1;
