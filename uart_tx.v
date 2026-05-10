`timescale 1ns/1ps

module uart_tx(input clk, start , input baud_tick, input [7:0] data ,output reg idle, output reg tx_line);

reg [3:0] state=0 ;   //it is defined to show the number of states i.e. FSM . it gives 16 states , and we need 11 states so it can be used

always@(posedge clk)begin      //for every rising edge state and output changes

   idle <= (state == 0);     //here we don't need idle condition . it says that if state is 0 then idle =1 , otherwise state is different
    //clk and start cannot be assigned to 0 or anything because they are inputs , they come from outside
   if (baud_tick)begin     // when baud_tick goes HIGH then only state changes
   
   //CASE 1= USED TO TELL WHEN TO CHANGE STATE 
   
    case(state)            
    0: if(start) state<=1;    //IF START = 1 , change state from state 0 to state 1
    1: state <=2;             //change state 1 to state 2 and so on 
    2: state <=3;
    3: state <=4;
    4: state <=5;
    5: state <=6;
    6: state <=7;
    7:state <=8;
    8:state <=9; 
    9:state <=10;
    10:state <=0;           // here when state 10 comes it goes to state 0 (starting over) not moving to state 11 
    
    default: state<=0;      //for other states make it state 0 as we don't need other states

   
    endcase
   end

   //CASE 2= USED TO TRANSMIT THE DATA i.e. AT WHAT STATE OUTPUT WILL BE WHAT?
    case(state)

    0: tx_line <= 1'b1;    //For state 0 -- IDLE state, line stays HIGH, no transmission happening. It means FREE.
    1: tx_line <= 1'b0;    //AT state 1 ---START = 0 FOR UART, RECEIVER WAKES UP! when start =0
    2: tx_line <= data[0];    //at state 2 --- start transmitting data
    3: tx_line <= data[1];
    4: tx_line <= data[2];
    5: tx_line <= data[3];
    6: tx_line <= data[4];
    7: tx_line <= data[5];
    8: tx_line <= data[6];
    9: tx_line <= data[7];    //MSB last
    10: tx_line <= 1'b1;    //state 10 STOP ---STOP=1 FOR UART  
    default: tx_line <= 1'b0;   //unknown state, keep line low as safety.
    

    endcase

    end

endmodule     



     