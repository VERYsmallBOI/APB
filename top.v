`define DATA_WIDTH 8
`define NSLAVE 2
module top(PCLK,PRESETN,transfer,READ_WRITE,apb_write_paddr,apb_read_paddr,apb_read_data_out,apb_write_data);
input PCLK,PRESETN,transfer,READ_WRITE;
input [8:0]apb_write_paddr,apb_read_paddr;
input [`DATA_WIDTH-1:0]apb_write_data;
output [`DATA_WIDTH-1:0]apb_read_data_out;

wire PREADY,PSLVERR,PWRITE,PENABLE;
wire [`NSLAVE-1:0]PSEL;
wire [`DATA_WIDTH-1:0]PRDATA,PWDATA;
wire [7:0]PADDR;
//sigs for each
wire [`DATA_WIDTH-1:0]PRDATA_S[`NSLAVE-1:0];
reg [`DATA_WIDTH-1:0]PRDATA_r;

wire [`NSLAVE-1:0]PSLVERR_S;
reg PSLVERR_r;

wire [`NSLAVE-1:0]PREADY_S;
reg PREADY_r;

wire [`DATA_WIDTH-1:0]PWDATA1,PWDATA2;
wire PENABLE1,PENABLE2;

    integer i;

master m1 (
    .PCLK(PCLK),
    .PRESETN(PRESETN),
    .transfer(transfer),
    .READ_WRITE(READ_WRITE),
    .PREADY(PREADY),
    .PRDATA(PRDATA),
    .PWRITE(PWRITE),
    .apb_write_paddr(apb_write_paddr),
    .apb_read_paddr(apb_read_paddr),
    .PWDATA(PWDATA),
    .PADDR(PADDR),
    .apb_read_data_out(apb_read_data_out),
    .apb_write_data(apb_write_data),
    .PSLVERR(PSLVERR),
    .PENABLE(PENABLE),
    .PSEL(PSEL)
);
always @(*) begin
    PRDATA_r  = 0;
    PSLVERR_r = 0;
    PREADY_r  = 0;
    for (i = 0; i < `NSLAVE; i = i + 1) begin
        if (PSEL == (1 << i)) begin
            PRDATA_r  = PRDATA_S[i];
            PSLVERR_r = PSLVERR_S[i];
            PREADY_r  = PREADY_S[i];
        end
    end
end


assign PRDATA= PRDATA_r;
assign PSLVERR= PSLVERR_r;
assign PREADY= PREADY_r;
assign PENABLE1= PSEL[0]?PENABLE:0;
assign PENABLE2= PSEL[1]?PENABLE:0;
assign PWDATA1=PSEL[0]?PWDATA:0;
assign PWDATA2=PSEL[1]?PWDATA:0;
slave1 s1(.PCLK(PCLK), .PRESETN(PRESETN), .PWRITE(PWRITE), .PSEL(PSEL[0]), .PENABLE(PENABLE1), .PADDR(PADDR), .PWDATA(PWDATA1), .PRDATA(PRDATA_S[0]), .PREADY(PREADY_S[0]), .PSLVERR(PSLVERR_S[0]));
slave2 s2(.PCLK(PCLK), .PRESETN(PRESETN), .PWRITE(PWRITE), .PSEL(PSEL[1]), .PENABLE(PENABLE2), .PADDR(PADDR), .PWDATA(PWDATA2), .PRDATA(PRDATA_S[1]), .PREADY(PREADY_S[1]), .PSLVERR(PSLVERR_S[1]));


endmodule