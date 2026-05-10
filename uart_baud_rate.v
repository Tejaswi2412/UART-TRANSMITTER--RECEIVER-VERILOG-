//UART 

//baud_tick is reg because it is inside always block 

`timescale 1ns/1ps

// TIMESCALE EXPLANATION:
// Without timescale, Verilog doesn't know what #10 means
// Is it 10ns? 10ms? 10 seconds? Compiler guesses wrongly!
// `timescale 1ns/1ps means:
// 1ns  = time unit (#1 = 1 nanosecond, #10 = 10 nanoseconds)
// 1ps  = precision (smallest measurable time = 1 picosecond)
// Must be added to ALL .v files so all modules are in sync!
// Without it: baud_tick fires at wrong time, start pulse misses it!

module uart_baud_rate(input clk ,  output reg baud_tick );

reg [12:0]count;   //we used reg because we want to count clock cycles till 5207 . hence we need 13 bits
   always@(posedge clk) begin   //posedge clk is written not * because we are changing output only when clock changes
    
      if (count <5207)     // for loop is not used bcoz it does perform everything at once . it does not reset to zero and we can give only one condition to perform
      count <=count+1;     // we used non blocking assignment because whenever clk is there we use non blocking assignment 
      else 
      count<=0;          //if count reaches 5207 then count resets to 0. 5207 means it is counting from 0 to 5207 cycles which means total cycles is 5208

      if (count ==5207)   //if count complete 5208  cycles make baud_tick HIGH else LOW
      baud_tick<= 1'b1 ;

      else
       baud_tick<= 1'b0 ;

      
   end 
   
endmodule