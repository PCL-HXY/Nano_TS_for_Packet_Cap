
//dsp  07/08


module Fifo_align (
  // clock and resets
  input wire           clk,  

  // high-reset
  input wire           rst,    
  
  //opkwenb:  1---eth0  has data ,  0--no  data  input
  input wire        opkwenb,
  

  output  reg   flush_i,
  
  input wire flush_done

  );

  reg  [31:0]  data;
  reg enable;

  always @(posedge clk) 
    begin
         if(rst) 
         begin
               data <=32'b1;
               flush_i<=1'b0;
               enable <= 1'b0;
         end
         else if(flush_done)
               flush_i <= 1'b0;
         else if(opkwenb)  
         begin
               data <=32'b0;
               enable <= 1'b1;
         end
         else if(enable)
         begin
               if(data==32'h4A817C8)//500ms dsp0114
               begin             
                  data<=32'b0;
                  flush_i<=1'b1;
                  enable <= 1'b0;
               end
               else   
                  data <= data + 1'b1;
        end
        else
            begin
              data <= data;
              flush_i <= flush_i;
            end
    end


endmodule
  


