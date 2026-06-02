`define DATA_WIDTH 8

module slave(
    input PCLK, PRESETN, PWRITE, PSEL, PENABLE,
    input [7:0] PADDR,
    input [`DATA_WIDTH-1:0] PWDATA,
    output reg [`DATA_WIDTH-1:0] PRDATA,
    output reg PREADY, PSLVERR
);

    reg [7:0] arr[0:127];

    always @(*) begin
        if (PRESETN && PENABLE && PSEL) begin
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
        end else begin
            PRDATA  = 0;
            PREADY  = 0;
            PSLVERR = 0;
        end
    end

endmodule