module tb;
    reg  pclk;
    reg  presetn;
    reg  [3:0] addrin;
    reg  [7:0] datain;
    reg  newd;
    reg  wr;
    reg  pready;
    reg  [7:0] prdata;
    wire [7:0] dataout;
    wire [3:0] paddr;
    wire [7:0] pwdata;
    wire pwrite;
    wire psel;
    wire penable;
    
    event done;

    apb_m dut
    (
        .pclk(pclk),
        .presetn(presetn),
        .addrin(addrin),
        .datain(datain),
        .newd(newd),
        .wr(wr),
        .pready(pready),
        .prdata(prdata),
        .dataout(dataout),
        .paddr(paddr),
        .pwdata(pwdata),
        .pwrite(pwrite),
        .psel(psel),
        .penable(penable)
    );
    initial begin
        pclk = 'd0;
        presetn = 'd0;
        addrin = 'd0;
        datain = 'd0;
        newd = 'd0;
        wr = 'd0;
        pready = 'd0;
        prdata = 'd0;
    end

    always #10 pclk = ~pclk;

    task reset();
        repeat(5)@(posedge pclk);
        presetn = 'd1;
        @(posedge pclk);
    endtask

    task write();
        @(posedge pclk);
        wr = 'd1;
        newd = 'd1;
        addrin = $urandom_range(1,5);
        datain = $urandom_range(1,9);
        @(posedge pclk);
        pready = 'd1;
        prdata = $urandom_range(1,9);
        @(posedge pclk);
        newd = 'd0;
        addrin = 'd0;
        pready = 'd0;
        datain = 'd0;
    endtask

    task read();
        wr = 'd0;
        newd = 'd1;
        addrin = $urandom_range(1,5);
        @(posedge pclk);
        pready = 'd1;
        @(posedge pclk);
        newd = 'd0;
        pready = 'd0;
        addrin = 'd0;
    endtask
    
    initial begin
        reset();
        for(integer count = 0; count < 10; count++) begin
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
