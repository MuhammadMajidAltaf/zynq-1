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
wire [3:0] dbg;

wire s_axis_tvalid;
wire s_axis_tready;
wire [511:0] s_axis_tdata;
wire [63:0] s_axis_tkeep;
wire s_axis_tlast;

wire m_axis_tvalid;
wire m_axis_tready;
wire [511:0] m_axis_tdata;
wire [63:0] m_axis_tkeep;
wire m_axis_tlast;

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
wire s_axis_tready_out;
genvar i;

reg state;
reg [REG_SIZE-1:0] regs [PIPELINE_DEPTH-1:0][NUM_REGS-1:0];

reg pipeline_en;
reg [PIPELINE_DEPTH-1:0] pipeline_state;
reg pipeline_state_feed;

//Actual logic starts here
assign s_axis_tready = s_axis_tready_out;

//Pipeline management
always@(negedge clk)
  if (!pipeline_en) begin
    pipeline_state <= 0;
  end
  else
    //Move pipeline stages along
    pipeline_state[0] <= pipeline_state_feed;
    for (i=0; i<PIPELINE_DEPTH-2; i=i+1) begin: STAGES
      pipeline_state[i+1] <= pipeline_state[i];
    end

    //Stage 1 - clock in registers
    for (i=0; i<NUM_REGS-1; i=i+1) begin: REGS_IN
      assign regs[0][i] = s_axis_tdata[(i+1) * REG_SIZE-1:i*REG_SIZE];
    end

    //Stage 2 - perform processing
    assign regs[2] = regs[1];

    //Stage 3 - clock out registers
    assign m_axis_tdata[16*REG_SIZE-1:15*REG_SIZE] = PKT_MAGIC;
    for (i=0;i<NUM_REGS-1; i=i+1) begin: REGS_OUT
      //TODO: check endianess?
      assign m_axis_tdata[(i+1)*REG_SIZE-1:i*REG_SIZE] = regs[2][i];
    end

//FSM control
always@(posedge clk)
  if (reset) begin
    state <= S_FILLING;
    s_axis_tready_out <= 0;
    m_axis_tvalid <= 0;
    dbg <= 4'b0000;
    pipeline_en <= 0;
  end
  else
    //TODO: wait for tready
    case (state)
      S_FILLING: begin
        s_axis_tready_out <= 1;
        m_axis_tvalid <= 0;
        m_axis_tlast <= 0;
        dbg[0] <= 1;

        if (s_axis_tvalid && s_axis_tkeep == 'hffffffffffffffff && s_axis_tdata[16*REG_SIZE-1:15*REG_SIZE] == PKT_MAGIC) begin
          pipeline_en <= 1;
          pipeline_state_feed <= 1;
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

        if (s_axis_tvalid && s_axis_tkeep == 'hffffffffffffffff && s_axis_tdata[16*REG_SIZE-1:15*REG_SIZE] == PKT_MAGIC) begin
          //No change
        end
        else
          pipeline_state_feed <= 0;
          state <= S_DRAINING;
        end

      S_DRAINING: begin
        dbg[2] <= 1;
        pipeline_state_feed <= 0;
        if (!pipeline_state[STAGE_DATA_OUT-1]) begin
          pipeline_en <= 0;
          m_axis_tlast <= 1;
          state <= S_FILLING;
        end
      end
    endcase

    //TODO:ADD SECTION THAT DOES ACTUAL DATA PROCESSING!

endmodule
