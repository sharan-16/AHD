// Code your design here
// Code your design here
module REGISTERS( 
  input wire [4:0] readaddr1,
  input wire [4:0] readaddr2,
  input wire [4:0] writeaddr,
  input wire [31:0] write_data,
  input wire write_cntrl,
  input clk,
  input clr,
  output reg [31:0] read1,
  output reg [31:0] read2
);
  
  reg [31:0]REG[31:0];
  genvar i;
  
  assign REG[0]=32'd0;
  assign read1=REG[readaddr1];
  assign read2=REG[readaddr2];    

  generate 
    for (i=1; i<31; i=i+1) begin
      always @(posedge clk or posedge clr) begin
        if (clr==1) begin
          REG[i]<=32'd0;
        end
        else if (write_cntrl==1) begin
            if (i == writeaddr) begin
              REG[i] = write_data;
            end
        end
      end  
    end  
  endgenerate      
endmodule
