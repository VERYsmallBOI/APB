//wires + sequnectial logic on when ok
// PSLVERR is driven LOW when PSEL, PENABLE, or PREADY are LOW.
//using N to 1 insteaed of N-1 to 0 indexing cos of labelling 
`define NSLAVE 2
`define DATA_WIDTH 8
module apb (
    

//N PSEL IN MASTER(input) 1 FOR EACH SLAVE(outut)
//1 WIDTH SIZED WRITE AND READ WIRE FOR MASTER AND ONE WIDTH SIZED FOR EACH SLAAVE
//PWDATA IS INPUT FOR MASTER AND OUPUT FOR SLAVES PRDATA IS OPPOSITE
//PLCLK AND PRESETN 1 BOTH INPUT
// PADDR ONE FOR MASTER AND ONE FOR EACH SLAVE BYTE SIZED 8(HARDCODED) ONLY(INOUT ON B.S.)
//NO CONCURRENT READ AND WRITE
// PENABLE 1(MASTER) + PENABLE(1 FOR EACH SLAVE)
//PWRITE IS FOR MASTER ONLY INPUT
// NO NEED TO CHECK FOR ENABLE COS AFTER ONE CYCLE IT SHOULD AUTOMACTICALLY GO TO ACCESS STATE ANYWAY
// 1 FOR EACH SLAVE (INPUT) AND 1 FOR MASTER OUTPUT

//READY IS INPUPT FOR SLAVES(ONE FOR EACH) AND OUTPUT FOR MASTER(ONE)
// _S FOR SALVE SIGNAL AND _M FOR MASTER SIGNAL
// ALL ARE CAPS 
//2 cosnts `NSLAVE and `WIDTH are defined 
input PCLK,
input PRESETN,

input wire [7:0]PADDR_M, //master connection
output wire [7:0]PADDR_S[`NSLAVE:1],

output wire PSEL_S[`NSLAVE:1],
input wire [`NSLAVE:1]PSEL_M,


input PENABLE_M,
output PENABLE_S[`NSLAVE:1],

input PWRITE_M,
output PWRITE_S[`NSLAVE:1],

input PREADY_S[`NSLAVE:1],
output PREADY_M,

input wire [`DATA_WIDTH-1:0]PWDATA_M,
output wire [`DATA_WIDTH-1:0]PWDATA_S[`NSLAVE:1],


output wire [`DATA_WIDTH-1:0]PRDATA_M,
input wire [`DATA_WIDTH-1:0]PRDATA_S[`NSLAVE:1],


output PSLVERR_M,
input PSLVERR_S[`NSLAVE:1]
);
   reg  active_ready;
    reg [`DATA_WIDTH:1] active_rdata;
    reg  active_slverr;

//it is by protocol only one PSEL can be active
    genvar i;
    generate
        for (i = 1; i <= `NSLAVE; i = i + 1) begin : en //connection happens if state is not idle
            assign PENABLE_S[i] = (PRESETN && PSEL_M[i]) ? PENABLE_M : 1'b0;
            assign PADDR_S[i] = (PRESETN && PSEL_M[i]) ? PADDR_M : '0;
            assign PSEL_S[i]=PSEL_M[i];
            assign PWRITE_S[i]  = PSEL_M[i] ? PWRITE_M  : 1'b0;
            assign PWDATA_S[i] = (PRESETN && PSEL_M[i]) ? PWDATA_M : 1'b0;
        end
    endgenerate

    assign PREADY_M   = active_ready;
    assign PRDATA_M   = active_rdata;
    assign PSLVERR_M  = active_slverr;


integer j;
 always @(*) begin
        active_ready   = 1'b0;
        active_rdata   = {`DATA_WIDTH{1'b0}};
        active_slverr  = 1'b0;
        
        for (j = 1; j <= `NSLAVE; j = j + 1) begin
            if (PSEL_M[j]) begin
                active_ready   = PREADY_S[j];
                active_rdata   = PRDATA_S[j];
                active_slverr  = PSLVERR_S[j];
                // No break; if multiple PSEL high, last one wins (should not happen)
            end
        end
    end





endmodule