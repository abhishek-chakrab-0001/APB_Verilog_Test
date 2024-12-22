module apb_m
(
    input pclk,
    input presetn,
    input [3:0] addrin,
    input [7:0] datain,
    input newd,
    input wr,
    input pready,
    input [7:0] prdata,
    output [7:0] dataout,
    output reg [3:0] paddr,
    output reg [7:0] pwdata,
    output reg pwrite,
    output reg psel,
    output reg penable    
);

localparam idle = 0;
localparam setup = 1;
localparam enable = 2;

reg [1:0] state,nstate;

//RESET_LOGIC
//

always@(posedge pclk) begin
    if(presetn) state <= nstate;
    else state <= idle;
end

//NEXT_STATE_DECODER
//
always@(*) begin
    case(state)
        idle : begin
            if(presetn) begin
                if(newd) begin
                    nstate = setup;
                end
                else begin
                    nstate = idle;
                end
            end
            else begin
                nstate = setup;
            end
        end

        setup : begin
            if(presetn) begin
                if(newd) begin
                    if(psel) begin
                        nstate = enable;
                    end
                    else begin
                        nstate = setup;
                    end
                end
                else begin
                    nstate = setup;
                end
            end
            else begin
                nstate = idle;
            end
        end

        enable : begin
            if(presetn && penable) begin
                if(~pready) begin
                    nstate = enable;
                end
                else begin
                    if(newd) begin
                        nstate = setup;
                    end
                    else begin
                        nstate = idle;
                    end
                end
            end
            else begin
                nstate = idle;
            end
        end
    endcase

end

//OUTPUT_DECODE_LOGIC
//

always@(*) begin
    case(state)
        idle : begin
            paddr = 'd0;
            pwdata = 'd0;
            pwrite = 'd0;
            psel = 'd0;
            penable = 'd0;
        end

        setup : begin
            psel = 'd1;
            penable = 'd0;
            paddr = addrin;
            pwdata = datain;
            pwrite = wr;
        end

        enable : begin
            penable = 'd1;
        end
    endcase
end

 assign dataout = (pready && penable && ~pwrite) ? prdata : 'd0;

endmodule

