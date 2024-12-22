module apb_s
(
    input pclk,
    input presetn,
    input [3:0] paddr,
    input [7:0] pwdata,
    input pwrite,
    input psel,
    input penable,
    input is_wait,
    output reg pready,
    output reg [7:0] prdata
);

localparam idle = 'd0;
localparam read = 'd1;
localparam write = 'd2;

reg [1:0] state,nstate;

//mem 
reg [7:0] apb_mem[15:0];


//RESET_LOGIC
always@(posedge pclk) begin
    if(presetn) state <= nstate;
    else state <= idle;
end

//NEXT_STATE_DECODER
always@(*) begin
    case(state)
        idle : begin
            if(presetn) begin
                if(pwrite && psel && ~penable) begin
                    nstate = write;
                end
                else if(~pwrite && psel && ~penable) begin
                    nstate = read;
                end
            end
            else begin
                nstate = idle;
            end
        end

        read : begin
            if(presetn) begin
                if(pwrite && psel && ~penable) begin
                    nstate = write;
                end
                else if(~pwrite && psel && ~penable)begin
                    nstate = read;
                end
            end
            else begin
                nstate = idle;
            end

        end

        write : begin
            if(presetn) begin
                if(~pwrite && psel && ~penable) begin
                    nstate = read;
                end
                else if(pwrite && psel && ~penable)begin
                    nstate = write;
                end
            end
            else begin
                nstate = idle;
            end
        end
    endcase
end

always@(*) begin
    case(state)
        idle : begin
            pready = 'd0;
            //for(integer i = 0; i < 16; i++) begin
            //    apb_mem[i] = 'd0;
            //end
        end

        read : begin
            if(is_wait) begin
                pready = 'd0;
            end
            else if(~is_wait && psel && penable && presetn) begin
                pready = 'd1;
                prdata = apb_mem[paddr];
            end
            else if(~presetn) begin
                pready = 'd0;
                prdata = 'd0;
            end
        end

        write : begin
            if(is_wait) begin
                pready = 'd0;
            end
            else if(~is_wait && psel && penable && presetn) begin
                pready = 'd1;
                apb_mem[paddr] = pwdata;
            end
            else if(~presetn) begin
                pready = 'd0;
            end
        end
    endcase
end
endmodule
