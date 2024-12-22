module apb_s_tb;
    reg  pclk;
    reg  presetn;
    reg  [3:0] paddr;
    reg  [7:0] pwdata;
    reg  pwrite;
    reg  psel;
    reg  penable;
    reg  is_wait;
    wire pready;
    wire [7:0] prdata;

    event done;

    apb_s dut
    (
        .pclk(pclk),
        .presetn(presetn),
        .paddr(paddr),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .psel(psel),
        .penable(penable),
        .is_wait(is_wait),
        .pready(pready),
        .prdata(prdata)
    );

    initial begin
        pclk = 'd0;
    end

    always #10 pclk = ~pclk;

    task reset();
        repeat(5)@(posedge pclk);
        presetn = 'd0;
        psel   = 'd0;
        pwrite = 'd0;
        penable = 'd0;
        paddr = 'd0;
        pwdata = 'd0;
        is_wait = 'd0;
        @(posedge pclk);
        presetn = 'd1;
        @(posedge pclk);
    endtask

    task read();
        @(posedge pclk);
        psel = 'd1;
        pwrite = 'd0;
        paddr = $urandom_range(1,8);
        @(posedge pclk);
        is_wait = 'd0;
        penable = 'd1;
        @(posedge pclk);
        psel = 'd0;
        paddr = 'd0;
        pwdata = 'd0;
        penable = 'd0;
        is_wait = 'd0;
    endtask

    task write();
        @(posedge pclk);
        psel = 'd1;
        pwrite = 'd1;
        paddr = $urandom_range(1,8);
        pwdata = $urandom_range(1,9);
        @(posedge pclk);
        is_wait = 'd0;
        penable = 'd1;
        @(posedge pclk);
        psel = 'd0;
        paddr = 'd0;
        pwdata = 'd0;
        penable = 'd0;
        is_wait = 'd1;
    endtask
    task read_wait();
        @(posedge pclk);
        psel = 'd1;
        pwrite = 'd0;
        paddr = $urandom_range(1,8);
        repeat(3) @(posedge pclk);
        is_wait = 'd1;
        @(posedge pclk);
        is_wait = 'd0;
        penable = 'd1;
        @(posedge pclk);
        psel = 'd0;
        paddr = 'd0;
        pwdata = 'd0;
        penable = 'd0;
        is_wait = 'd0;
    endtask
    task write_wait();
        @(posedge pclk);
        psel = 'd1;
        pwrite = 'd1;
        paddr = $urandom_range(1,8);
        pwdata = $urandom_range(1,9);
        repeat(3)@(posedge pclk);
        is_wait = 'd1;
        @(posedge pclk);
        is_wait = 'd0;
        penable = 'd1;
        @(posedge pclk);
        psel = 'd0;
        paddr = 'd0;
        pwdata = 'd0;
        penable = 'd0;
        is_wait = 'd1;
    endtask

    initial  begin
        reset();
        for(integer count = 0; count < 10; count++) begin
            write_wait();
            read_wait();
        end
        ->done;
    end

    initial begin
        wait(done.triggered);
        $finish();
    end

endmodule


