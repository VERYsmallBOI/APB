`define DATA_WIDTH 8
`define NSLAVE 2
module master(PCLK,PRESETN,PADDR,PSEL,PENABLE,PWRITE,PREADY,PRDATA,PSLVERR,READ_WRITE);
input PCLK,PRESETN,transfer,READ_WRITE;
input PREADY;
input [`DATA_WIDTH-1:0]PRDATA;
output PWRITE;
input [8:0]apb_write_paddr,apb_read_paddr;
output reg [`DATA_WIDTH-1:0]PWDATA;
output reg [7:0]PADDR;
output reg [`DATA_WIDTH-1:0]apb_read_data_out;
input [`DATA_WIDTH-1:0]apb_write_data;
input PSLVERR;
output reg PENABLE;
reg [1:0]state;


//only clears read on reset never otherwise


always@(posedge PCLK,negedge PRESETN)
begin
if(!PRESETN)
begin
state<=0;
PADDR<=0;
PWRITE<=0;
apb_read_data_out<=0;
PWDATA<=0;
PENABLE<=0;
end

else 
begin
case(state)
2'b0:begin
if(transfer)
begin
state<=2'b1;
PADDR<=(READ_WRITE?apb_write_paddr:apb_read_paddr);
PWDATA<=(READ_WRITE?0:apb_write_data);
PWRITE<=~(READ_WRITE);
PENABLE<=0;
end
else
begin
  state<=0;
  PADDR<=0;
  PWDATA<=0;
  PWRITE<=0;
  PRDATA<=PRDATA;  
end
end

2'b1:begin
  state<=2'b10;
  PENABLE<=1;
end
2'b10:begin
  if(PREADY==1'b1)
  begin
    apb_read_data_out<=apb_read_data_out;
    if((PWRITE==0)&&(PSLVERR==0))
      begin
        apb_read_data_out<=PRDATA;
      end
    if(transfer==1'b1)
      begin
        state<=2'b1;
        PADDR<=(READ_WRITE?apb_write_paddr:apb_read_paddr);
        PWDATA<=(READ_WRITE?0:apb_write_data);
        PWRITE<=~(READ_WRITE);
        PENABLE<=0;
      end
      else begin
        state<=2'b0;
        PADDR<=0;
        PWDATA<=0;
        PWRITE<=0;
        PENABLE<=0;
      end
  end


end

default:begin
end



endcase
end

end




endmodule