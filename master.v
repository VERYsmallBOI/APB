`define DATA_WIDTH 8
`define NSLAVE 2
module master(PCLK,PRESETN,transfer,READ_WRITE,PREADY,PRDATA,PWRITE,apb_write_paddr,apb_read_paddr,PWDATA,PADDR,apb_read_data_out,apb_write_data,PSLVERR,PENABLE,PSEL);
input PCLK,PRESETN,transfer,READ_WRITE;
input PREADY;
input [`DATA_WIDTH-1:0]PRDATA;
input [8:0]apb_write_paddr,apb_read_paddr; 
input [`DATA_WIDTH-1:0]apb_write_data;
input PSLVERR;
output reg PWRITE;
output reg [`DATA_WIDTH-1:0]PWDATA; 
output reg [7:0]PADDR;
output reg [`DATA_WIDTH-1:0]apb_read_data_out;
output reg PENABLE;
output reg [`NSLAVE-1:0]PSEL;
  reg [1:0]state;
  

  //only clears read on reset never otherwise

  always@(posedge PCLK,negedge PRESETN)
  begin
    if(!PRESETN)
    begin

      PWRITE <= 0;
PWDATA <= 0;
PADDR <= 0;
apb_read_data_out <= 0;
PENABLE <= 0;
PSEL <= 0;
state <= 0;
    end
    else 
    begin
      case(state)
        2'b0:begin
          apb_read_data_out<=apb_read_data_out;
          if(transfer)
          begin
            
            

            PWRITE <= ~(READ_WRITE);
PWDATA <= (READ_WRITE ? 0 : apb_write_data);
PADDR <= (READ_WRITE ? apb_read_paddr[7:0] : apb_write_paddr[7:0]);
PENABLE <= 0;
PSEL <= 1 << ((READ_WRITE ? apb_read_paddr[8] : apb_write_paddr[8]));
state <= 2'b1;
          end
          else
          begin
            PWRITE <= 0;
PWDATA <= 0;
PADDR <= 0;
PENABLE <= 0;
PSEL <= 0;
state <= 0;
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
              PWDATA<=(READ_WRITE?0:apb_write_data);
              PWRITE<=~(READ_WRITE);
              PENABLE<=0;
              PSEL<=1<<((READ_WRITE?apb_read_paddr[8]:apb_write_paddr[8]));
              PADDR<=(READ_WRITE?apb_read_paddr[7:0]:apb_write_paddr[7:0]);
            end
            else begin
              state<=2'b0;
              PADDR<=0;
              PWDATA<=0;
              PWRITE<=0;
              PENABLE<=0;
              PSEL<=0;
              apb_read_data_out<=apb_read_data_out;
            end
          end
        end

        default:begin
          state<=0;
          PADDR<=0;
          PWRITE<=0;
          apb_read_data_out<=0;
          PWDATA<=0;
          PENABLE<=0;
          PSEL<=0;
        end
      endcase
    end
  end
endmodule