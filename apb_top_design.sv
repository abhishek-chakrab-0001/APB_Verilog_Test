`include "apb_m_design.sv"
`include "apb_s_design.sv"

module apb_top
    (
        input clk,
        input rstn,
        input [3:0] ain,
        input [7:0] din,
        input newd,
        input wr,
        input is_wait,
        output dout
    );

    wire psel;
    wire penable;
    wire pwrite;
    wire [3:0] paddr_c;
    wire [7:0] pwdata_c;
    wire pready;
    wire [7:0] prdata;

    apb_m master_dut(
        .pclk(clk),
        .presetn(rstn),
        .addrin(ain),
        .datain(din),
        .newd(newd),
        .wr(wr),
        .pready(pready),
        .prdata(prdata),
        .dataout(dout),
        .paddr(paddr_c),
        .pwdata(pwdata_c),
        .pwrite(pwrite),
        .psel(psel),
        .penable(penable)
    );

    apb_s slave_dut(
        .pclk(clk),
        .presetn(rstn),
        .paddr(paddr_c),
        .pwdata(pwdata_c),
        .pwrite(pwrite),
        .psel(psel),
        .penable(penable),
        .is_wait(is_wait),
        .pready(pready),
        .prdata(prdata)
    );
endmodule
