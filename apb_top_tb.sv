module tb;
    reg clk;
    reg rstn;
    reg [3:0] ain;
    reg [7:0] din;
    reg newd;
    reg wr;
    reg is_wait;
    wire dout;

    event done;

    apb_top top_dut(
        .clk(clk),
        .rstn(rstn),
        .ain(ain),
        .din(din),
        .newd(newd),
        .wr(wr),
        .is_wait(is_wait),
        .dout(dout)
    );

    initial begin
        clk = 'd0;
        rstn = 'd0;
        ain = 'd0;
        din = 'd0;
        newd = 'd0;
        wr = 'd0;
        is_wait = 'd0;
    end

    always #10 clk = ~clk;

    task reset();
        repeat(5)@(posedge clk);
        @(posedge clk);
        rstn = 'd1;
        @(posedge clk);
    endtask

    task write();
        @(posedge clk);
        wr = 'd1;
        ain = $urandom_range(1,5);
        din = $urandom_range(1,9);
        newd = 'd1;
        is_wait = 'd1;    
        repeat(5)@(posedge clk);
        is_wait = 'd0;
        @(posedge clk);
        ain = 'd0;
        din = 'd0;
        newd = 'd0;
    endtask

    task read();
        @(posedge clk);
        wr = 'd0;
        ain = $urandom_range(1,5);
        newd = 'd1;
        is_wait = 'd1;
        repeat(4)@(posedge clk);
        is_wait = 'd0;
        @(posedge clk);
        newd = 'd0;
        ain = 'd0;
        is_wait = 'd0;
        @(posedge clk);
    endtask

    initial begin
        reset();
        for(integer i = 0; i < 10; i++) begin
            write();
            read();
        end
        ->done;
    end

    initial begin
        wait(done.triggered());
        $finish();
    end

endmodule
