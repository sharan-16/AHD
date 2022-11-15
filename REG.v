// Code your design here
module REGISTERS( 
  input wire readaddr1,
  input wire readaddr2,
  input wire writeaddr,
  input wire write_data,
  input wire write_cntrl,
  input clk,
  input clr,
  output reg read1,
  output reg read2
);
  
  reg [31:0][31:0]REG;
  integer i=0;
  
  assign REG[0]=0;
  
  assign read1=REG[readaddr1];
  assign read2=REG[readaddr2];    
  
  always @(posedge clk or posedge clr) begin
    if (clr==1) begin
      for(i=0;i<32;i++) begin
        REG[i]<=0;
      end
    end
    else if (write_cntrl==1) begin
      REG[writeaddr]=writedata;
      
    end
  end
  
endmodule