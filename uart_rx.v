`timescale 1ns/1ps

module uart_rx(input rx_line , clk , output reg [7:0] data , output reg done);

reg[12:0] rx_count=0;
reg sampling =0;
reg [3:0] state =0;     // we need 11 states hence we used 4 bit state , first i took 1 bit state which is wrong
                        // WHY = 0?
                        // Same reason as uart_tx
                        // Without = 0: state = x → RX FSM stuck, never receives!
                        // With = 0: RX starts in IDLE, watches rx_line for start bit
initial done = 0;

                        // WHY initialize done?
                        // Without it: done = x (unknown) at simulation start
                        // GTKWave shows red "x" line → can't trust done signal!
                        // CPU/testbench can't tell if done is real 1 or unknown x!
                        // With initial done=0:
                        // done = 0 at start → clean known state 
                        // done = 1 only when data is fully received 
                        // GTKWave shows clean 0→1 transition

  always@(posedge clk) begin
    
    if (!sampling && rx_line==0)begin          //!sampling= i am not receiving and i am idle . rx_line ==0 means start bit is detected
      sampling <=1;                            // it sets to 1 to represent that i am busy now and started receiving
      rx_count <= 0;                        // make the count 0 and start from scratch. it is the beauty of rx independent counter. for every new data it counts from scratch i.e zero
      state <=1;                 // directly move to state 1 , state 0 is not required as we checked the start bit by rx_line ==0 , no need to check again
      done <= 0;                 //since data is not fully received set done to 0 .
    end               
    else if(sampling)begin

            if(rx_count==5207)begin
               rx_count<=0;
              if (state==10)begin
               sampling <=0;
               state<=0;
              end
              else
               state<=state+1;
              end 

            else
               rx_count<=rx_count+1;
          end
  
// CASE  = USED for reading the transmitted data . rx_line and tx_line are same , just for our convenience we have used rx_line for understanding purpose
if(sampling && rx_count==2603)begin
case(state )                        // state 0 and state 1 is not needed because transmitter cares about idle and start , receiver only cares about receiving the data
   2 :data[0] <= rx_line;          //read LSB data first
   3 : data[1] <= rx_line;
   4 : data[2] <= rx_line;
   5 : data[3] <= rx_line;
   6 : data[4] <= rx_line;
   7 : data[5] <= rx_line;
   8:  data[6] <= rx_line;
   9 : data[7] <= rx_line;
   10 : done<=1'b1;                // data is received completely . Tells CPU that you can now READ the data

   default: data<= 8'b0;          //for all other states data is 0

   endcase 
end  

end
endmodule



