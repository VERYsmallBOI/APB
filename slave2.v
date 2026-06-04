`define DATA_WIDTH 8
`define WAITS 1
module slave2(
    input PCLK, PRESETN, PWRITE, PSEL, PENABLE,
    input [7:0] PADDR,
    input [`DATA_WIDTH-1:0] PWDATA,
    output reg [`DATA_WIDTH-1:0] PRDATA,
    output reg PREADY, PSLVERR
);
reg [$clog2(`WAITS):0]count;

    reg [7:0] arr[0:127];

    always @(posedge PCLK,negedge PRESETN) begin
        if (!PRESETN ) begin
                    count<=0;
            PRDATA  = 0;
            PREADY  = 0;
            PSLVERR = 0;
        end
        else  begin


            if( PENABLE && PSEL) begin
            
           if(count==`WAITS) begin
            count<=0;
            if (PADDR > 127) begin //error
                PSLVERR = 1;
                PREADY  = 1;
                if (~PWRITE) begin
                    PRDATA = 0;
                end
            end else begin 
                PSLVERR = 0;
                PREADY  = 1;
                if (~PWRITE) begin //read
                    PRDATA = arr[PADDR];
                end else begin //write
                    arr[PADDR] = PWDATA;
                end
            end
            end
            else 
            begin
                count<=count+1;
                PREADY<=0;
                PSLVERR<=0;
                PRDATA<=0;
            end
        end 

else begin


end

        end
        
        else begin


        end
        
        end
        
        else begin
            count<=0;
            PRDATA  = 0;
            PREADY  = 0;
            PSLVERR = 0;
        end


endmodule