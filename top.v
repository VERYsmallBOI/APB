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
wire [`NSLAVE-1:0]PSLVERR_S;
wire [`NSLAVE-1:0]PREADY_S;
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
assign PRDATA= PSEL[1]?PRDATA2:(PSEL[0]?PRDATA1:0);
assign PSLVERR= PSEL[1]?PSLVERR2:(PSEL[0]?PSLVERR1:0);
assign PREADY = PSEL[1]?PREADY2:(PSEL[0]?PREADY1:0);
assign PENABLE1= PSEL[0]?PENABLE:0;
assign PENABLE2= PSEL[1]?PENABLE:0;
assign PWDATA1=PSEL[0]?PENABLE:0;
assign PW
slave1 s1(.PCLK(PCLK), .PRESETN(PRESETN), .PWRITE(PWRITE), .PSEL(PSEL[0]), .PENABLE(PENABLE1), .PADDR(PADDR), .PWDATA(PWDATA), .PRDATA(PRDATA1), .PREADY(PREADY1), .PSLVERR(PSLVERR1));
slave2 s2(.PCLK(PCLK), .PRESETN(PRESETN), .PWRITE(PWRITE), .PSEL(PSEL[1]), .PENABLE(PENABLE2), .PADDR(PADDR), .PWDATA(PWDATA), .PRDATA(PRDATA2), .PREADY(PREADY2), .PSLVERR(PSLVERR2));


endmodule