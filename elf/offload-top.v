//---------------------------------------------------------------------------
//-- Author   : Ali Lown <ali@lown.me.uk>
//-- File          : offload_top.vhdl
//--
//-- Abstract : Top-level offloading system over AXI-S ports
//--            (Converted from VHDL, sigh)
//---------------------------------------------------------------------------

module offload_top (clk, reset_n, dbg,
  s_axis_tvalid,
  s_axis_tready,
  s_axis_tdata,
  s_axis_tkeep,
  s_axis_tlast,
  m_axis_tvalid,
  m_axis_tready,
  m_axis_tdata,
  m_axis_tkeep,
  m_axis_tlast);

input clk;
input reset_n;
output [3:0] dbg;

input s_axis_tvalid;
output s_axis_tready;
input [511:0] s_axis_tdata;
input [63:0] s_axis_tkeep;
input s_axis_tlast;

output m_axis_tvalid;
input m_axis_tready;
output [511:0] m_axis_tdata;
output [63:0] m_axis_tkeep;
output m_axis_tlast;

//Port wires
wire clk;
wire reset_n;
reg [3:0] dbg;

wire s_axis_tvalid;
reg s_axis_tready;
wire [511:0] s_axis_tdata;
wire [63:0] s_axis_tkeep;
wire s_axis_tlast;

reg m_axis_tvalid;
wire m_axis_tready;
reg [511:0] m_axis_tdata;
reg [63:0] m_axis_tkeep;
reg m_axis_tlast;

//Constants
parameter PIPELINE_DEPTH = 3;
parameter NUM_REGS       = 14;
parameter REG_SIZE       = 32;

parameter STAGE_PROCESS  = 2;
parameter STAGE_DATA_OUT = 3;

parameter PKT_MAGIC = 32'h0FFA0FFB;

//FSM declaration. Ugh. Types when?
parameter S_FILLING  = 3'b001;
parameter S_FULL     = 3'b010;
parameter S_DRAINING = 3'b100;

//Internal Variables
integer i;

reg [2:0] state;
reg [REG_SIZE-1:0] regs [PIPELINE_DEPTH-1:0][NUM_REGS-1:0];

reg pipeline_en;
reg [PIPELINE_DEPTH-1:0] pipeline_state;
reg pipeline_state_feed;

//Actual logic starts here

//Pipeline management
always@(posedge clk)
  begin
    //Move pipeline stages along
    for (i=0; i<PIPELINE_DEPTH-1; i=i+1) begin: STAGES
      pipeline_state[i+1] <= pipeline_state[i];
    end

    //Stage 1 - clock in registers
    for (i=0; i<NUM_REGS-1; i=i+1) begin: REGS_IN
      regs[0][i] <= s_axis_tdata[i*REG_SIZE +: REG_SIZE];
    end

    //Stage 2 - perform processing
    for(i=0; i<NUM_REGS-1; i=i+1) begin: REGS_PROCESS
      regs[2][i] <= regs[1][i];
    end

    //Stage 3 - clock out registers
    m_axis_tdata[16*REG_SIZE-1:15*REG_SIZE] <= PKT_MAGIC;
    for (i=0;i<NUM_REGS-1; i=i+1) begin: REGS_OUT
      //TODO: check endianess?
      m_axis_tdata[i*REG_SIZE +: REG_SIZE] <= regs[2][i];
    end
  end

//FSM control
always@(posedge clk)
  if (!reset_n) begin
    state <= S_FILLING;
    s_axis_tready <= 0;
    m_axis_tvalid <= 0;
    dbg <= 4'b0000;
    pipeline_en <= 0;
  end
  else begin
    //TODO: wait for tready?
    case (state)
      S_FILLING: begin
        s_axis_tready <= 1;
        m_axis_tvalid <= 0;
        m_axis_tlast <= 0;
        dbg[0] <= 1;

        if (s_axis_tvalid && s_axis_tkeep == 64'hffffffffffffffff && s_axis_tdata[16*REG_SIZE-1:15*REG_SIZE] == PKT_MAGIC) begin
          pipeline_en <= 1;
          pipeline_state[0] <= 1;
          //Triggers when almost full
          if (&pipeline_state[PIPELINE_DEPTH-2:0]) begin
            state <= S_FULL;
          end
        end
      end

      S_FULL: begin
        m_axis_tvalid <= 1;
        m_axis_tkeep <= 'b1;
        dbg[1] <= 1;

        if (s_axis_tvalid && s_axis_tkeep == 64'hffffffffffffffff && s_axis_tdata[16*REG_SIZE-1:15*REG_SIZE] == PKT_MAGIC) begin
          //No change
        end
        else begin
          pipeline_state[0] <= 0;
          state <= S_DRAINING;
        end
      end

      S_DRAINING: begin
        dbg[2] <= 1;
        pipeline_state[0] <= 0;
        if (!pipeline_state[STAGE_DATA_OUT-1]) begin
          pipeline_en <= 0;
          m_axis_tlast <= 1;
          state <= S_FILLING;
        end
      end
    endcase
  end

//Actual Work
//Knowingly breaks Verilog coding guidelines by mixing assignment types

//<<< BEGIN VARIABLES
reg [31:0] r3_30;
//>>> END VARIABLES
always@(posedge clk)
  if (pipeline_state[0]) begin
    //<<< BEGIN LOGIC
    r3_30 = regs[0][0] + regs[0][1];
    regs[1][0] <= r3_30;
    regs[1][1] <= r3_30;
    regs[1][2] <= r3_30;
    regs[1][3] <= r3_30;
    regs[1][4] <= r3_30;
    regs[1][5] <= r3_30;
    regs[1][6] <= r3_30;
    regs[1][7] <= r3_30;
    regs[1][8] <= r3_30;
    regs[1][9] <= r3_30;
    regs[1][10] <= r3_30;
    regs[1][11] <= r3_30;
    regs[1][12] <= r3_30;
    regs[1][13] <= regs[1][0];
    //>>> END LOGIC
  end

endmodule
