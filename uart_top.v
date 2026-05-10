//UART TOP MODULE = it connects all the modules together.
// RULE 1= If CPU/ Testbench want to check the data or see the data , then make it a top module port.
// RULE 2= If you just want to connect the modules internally then declare those it as wires.

// clk , start , tx_data are inputs from outside world. rx_data is output to outside world . hence they are declared as port .
// clk(comes from fpga board), start (testbench start the sending process), tx_data(testbench give the data from outside for sending).
// rx_data (testbench receives the data).
// PORT: testbench monitors this to know data is ready.


//FOR UNDERSTANDING PURPOSE:
// WHY IS 'data' NOT DECLARED IN uart_top?
// ============================================
// 'data' is a PORT NAME that exists INSIDE uart_tx and uart_rx modules.
// It is NOT our signal — it belongs to those modules.
//
// Think of it like a socket and plug:
// uart_tx has a socket labeled 'data'  (input  [7:0] data)
// uart_rx has a socket labeled 'data'  (output [7:0] data)
//
// In uart_top we have OUR OWN signals:
// tx_data → 8-bit data coming FROM outside world TO uart_tx
// rx_data → 8-bit data going  FROM uart_rx   TO outside world
//
// When we write:
// .data(tx_data) → we are plugging OUR tx_data into uart_tx's 'data' socket
// .data(rx_data) → we are plugging OUR rx_data into uart_rx's 'data' socket
//
// RULE:
// Declare in uart_top  → your own ports and wires only
// Never declare        → port names belonging to other modules
//
// 'data' lives inside uart_tx and uart_rx
// 'tx_data' and 'rx_data' live inside uart_top
// .data(tx_data) is just the CONNECTION between them!
// ============================================




// WHY IS 'tx_line' DECLARED AS WIRE BUT 'data' IS NOT?
// ============================================
// This is the most confusing part of top modules — let me explain clearly.
//
// RULE: Ask yourself ONE question:
// "Is this signal travelling BETWEEN my internal modules?"
// YES → declare it as WIRE in uart_top
// NO  → don't declare it, just use it in instantiation
//
// tx_line IS declared as wire because:
// - it is OUTPUT of uart_tx  (.tx_line(tx_line))
// - it is INPUT  of uart_rx  (.rx_line(tx_line))
// - it physically travels between two modules INSIDE uart_top
// - uart_top owns this wire and is responsible for it
// - without declaring it, how would uart_top know it exists?
//
// data is NOT declared as wire because:
// - tx_data comes FROM outside world (it is a PORT, not a wire)
// - rx_data goes TO outside world    (it is a PORT, not a wire)
// - 'data' is just the SOCKET NAME inside uart_tx and uart_rx
// - uart_top does not own 'data' — it belongs to other modules
// - uart_top just PASSES tx_data and rx_data through the socket
//
// SIMPLE ANALOGY:
// tx_line = extension cord INSIDE the room (wire)
//           you bought it, you own it, you declare it
//
// data    = name printed ON the socket of someone else's device (port name)
//           you don't own it, you just plug into it
//           your plug is called tx_data or rx_data
//
// YOU CAN NAME tx_line ANYTHING YOU WANT:
// wire tx_line;       → readable, recommended
// wire serial_data;   → also valid
// wire banana;        → valid but confusing
//
// Verilog compiler doesn't care about names
// It only cares about connections in instantiation:
// .tx_line(banana) → plugs 'banana' wire into tx_line socket
// .rx_line(banana) → plugs same 'banana' wire into rx_line socket
// Both modules are now connected through 'banana'!
//
// FINAL RULE SUMMARY:
// Signal travels between internal modules → WIRE (declare it!)
// Signal comes from/goes to outside world → PORT (in module declaration!)
// Port name of another module            → never declare, just use in instantiation!
// ============================================
`timescale 1ns/1ps

module uart_top(input clk,start ,input [7:0] tx_data , output[7:0] rx_data , output done);

wire baud_tick, idle ;                  //they are internal wires defined in modules inside . outside world does not care about this.
wire tx_line ;                          //They are internal wires defined in uart_tx, uart_rx module

 uart_baud_rate  instant1 (.clk(clk), .baud_tick(baud_tick) );
 uart_tx instant2(.tx_line(tx_line),.baud_tick(baud_tick),.clk(clk),.start(start),.idle(idle), .data(tx_data));
 uart_rx instant3(.rx_line(tx_line) , .clk(clk),.done(done) ,.data(rx_data));

endmodule



