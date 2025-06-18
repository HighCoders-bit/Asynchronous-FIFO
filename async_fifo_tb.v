

 
`timescale 1ns/1ns

module Asyn_fifo_tb();
    parameter datawidth = 8;       // Data width (8-bit FIFO)
    parameter adress_size = 4;     // Address size (Not used in TB)
    parameter fifo_depth = 16;      // FIFO depth (8 entries)

    // Testbench signals
    reg wrclk, rdclk, rst, wr, rd;
    reg [datawidth-1:0] wdata;     // 8-bit data input
    wire [datawidth-1:0] rdata;    // 8-bit data output
    wire valid, empty, full, overflow, underflow;

    // Instantiate the FIFO module (Unit Under Test)
    Asyn_fifo uut (
        .wrclk(wrclk), .rdclk(rdclk), .rst(rst), .wr(wr), .rd(rd),
        .wdata(wdata), .rdata(rdata), .valid(valid),
        .empty(empty), .full(full), .overflow(overflow), .underflow(underflow)
    );

    // Generate Write and Read Clocks
    always #5 wrclk = ~wrclk;  // Write clock with 10ns period
    always #7 rdclk = ~rdclk;  // Read clock with 14ns period

    // Task to write data into FIFO
  task write_fifo(input [datawidth-1:0] data);
    begin
        @(posedge wrclk);
        wr = 1;
        wdata = data;
        $display("Time: %0t | WRITE: wdata = %0h", $time, data);
        @(posedge wrclk);
        wr = 0;
    end
  endtask

   //Task to read data from FIFO
  task read_fifo;
    begin
        @(posedge rdclk);
        rd = 1;
        @(posedge rdclk);
        rd = 0;
        if (valid)
            $display("Time: %0t | READ : rdata = %0h", $time, rdata);
        else
            $display("Time: %0t | READ attempted but data not valid", $time);
    end
  endtask

    // Testbench Execution
    initial begin
        // Initialize all signals
        wrclk = 0; rdclk = 0; rst = 1; wr = 0; rd = 0;
        wdata = 0;

        #15 rst = 0; // Release reset after 15ns

        // **Write Data into FIFO**
        wdata = 0;  // Start with wdata = 0
        repeat (fifo_depth) begin
            write_fifo(wdata);
            wdata = wdata + 1;  // Increment data value
        end

        // **Check FIFO Full Condition**
        if (full) 
            $display("FIFO is FULL at time %t", $time);
        else 
            $display("ERROR: FIFO should be full but is not!");

        // **Overflow Test**
        write_fifo(8'hFF); // Attempt to write beyond capacity
        if (overflow) 
            $display("Overflow detected as expected at time %t", $time);
        else 
            $display("ERROR: Overflow not detected!");

        // **Read Data from FIFO**
        repeat (fifo_depth) read_fifo(); // Read all 8 values

        // **Check FIFO Empty Condition**
        if (empty) 
            $display("FIFO is EMPTY at time %t", $time);
        else 
            $display("ERROR: FIFO should be empty but is not!");

        // **Underflow Test**
        read_fifo(); // Attempt to read beyond empty FIFO
        if (underflow) 
            $display("Underflow detected as expected at time %t", $time);
        else 
            $display("ERROR: Underflow not detected!");

        #50;
        $finish;
    end
endmodule
