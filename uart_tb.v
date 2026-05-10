// ============================================
// HOW UART TRANSMISSION WORKS — COMPLETE FLOW
// ============================================
//
// TWO TYPES OF SIGNALS:
// 1. OUR signals    → start, done (convenience signals we created)
// 2. PROTOCOL bits  → tx_line=0 (start bit), tx_line=1 (stop bit)
//
// 'start' is OUR signal — not part of UART protocol!
// 'start=1' just triggers uart_tx FSM — nothing else
// tx_line=0 is the ACTUAL UART start bit on the wire
//
// ============================================
// STEP BY STEP FLOW:
// ============================================
//
// OUR WORLD:
// testbench sets start=1
//         ↓
// uart_tx FSM wakes up (state 0 → state 1)
//         ↓
// UART PROTOCOL TAKES OVER:
// uart_tx sends tx_line=0  ← ACTUAL UART start bit on wire
//         ↓                   uart_rx is always watching tx_line
// uart_rx sees tx_line=0
//         ↓
// uart_rx FSM wakes up (state 0 → state 1)
//         ↓
// uart_tx sends data bits (D0→D7) on tx_line
//         ↓
// uart_rx reads each bit and rebuilds 8-bit data
//         ↓
// uart_tx sends tx_line=1  ← ACTUAL UART stop bit on wire
//         ↓
// uart_rx knows frame is complete
//         ↓
// BACK TO OUR WORLD:
// done=1  ← uart_rx tells testbench "data is ready!"
//         ↓
// testbench reads rx_data and verifies it!
//
// ============================================
// SIGNAL SUMMARY:
// ============================================
// start      → OUR trigger   : testbench → uart_tx (not on wire!)
// tx_line=0  → PROTOCOL bit  : uart_tx   → uart_rx (start bit)
// tx_line=1  → PROTOCOL bit  : uart_tx   → uart_rx (stop bit)
// done       → OUR flag      : uart_rx   → testbench (not on wire!)
//
// start and done are OUR convenience signals
// tx_line bits are ACTUAL UART protocol signals
// ============================================
`timescale 1ns/1ps
module uart_tb;

        reg [7:0]tx_data;
        reg clk, start;
        wire [7:0] rx_data;
        wire done;

uart_top uut(.clk(clk), .tx_data(tx_data), .start(start), .rx_data(rx_data), .done(done));

initial clk=0;                        //Generating clock 
always #10 clk=~clk;

initial begin 
    start =0;
    tx_data= 8'b00010110;
    #200 start =1;        //waking the uart_tx
                            // WHY #200 and not #20?
                            // baud_tick first fires at 104,170ns
                            // Original #20 start=1 → start goes LOW at 40ns
                            // When baud_tick fires at 104,170ns → start=0 already!
                            // FSM checks: if(start) → start=0 → FSM NEVER MOVES! 
                            // Fix: start=1 at 200ns, stays HIGH until 200,200ns
                            // When baud_tick fires at 104,170ns → start=1 still! 
                            // FSM catches it and moves to state 1! 
                            // Think of it like holding a doorbell long enough to be heard!

    #200000 start =0;     //release start back to 0. from here onwards FSM takes the charge on its own.
                            // WHY #200000 and not #20?
                            // Hold start HIGH for full baud period (104,170ns)
                            // So FSM definitely catches start=1 on baud_tick!
                            // After FSM moves to state 1, start=0 doesn't matter
                            // FSM runs on its own from here onwards!

end 

initial begin
    #5000000 ;      // in UART transmission we are sending 11 bits , each bit stays for 5208 cycles and each cycle is of 20 ns.
                    // WHY #5000000 and not #1200000?
                    // One UART frame = 11 bits × 5208 cycles × 20ns = 1,145,760ns
                    // Plus start delay = 200,000ns
                    // Total needed    = 1,345,760ns
                    // Old value #1200000 = 1,200,000ns → NOT ENOUGH! simulation ended early!
                    // New value #5000000 = 5,000,000ns → plenty of time! 
                    // done=1 appears at 1,145,810ns, simulation runs until 5,000,000ns
    $finish;        //So to finish simulation we need 11 bits × 5208 cycles × 20ns per cycle. //  = 11 × 5208 × 20= 1,145,760 ns
                                          
end

initial begin
    $dumpfile("uart_tb.vcd");
    $dumpvars(0, uart_tb);
end 

initial begin
    $monitor("Time=%0t done=%b rx_data=%b", $time, done, rx_data);
end

endmodule