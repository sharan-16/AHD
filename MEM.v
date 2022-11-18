// Code your design here
module MEM (
  input wire [31:0] instaddr,
  input wire [31:0] dataaddr,
  input wire [31:0] data_write,
  input wire [31:0] inst_write,
  input wire instclr,
  input wire dataclr,
  input wire instWE,
  input wire dataWE,
  output reg [31:0] data_read,
  output reg [31:0] inst_read
);
  
  reg [31:0] MEM [1540:0];
  genvar i;
  MEM[0]=32'd11685268;
  MEM[1]=32'd11685268;
  MEM[2]=32'd11685268;
  
  if (instaddr%4==0 || datataddr%4==0) begin
    if (dataaddr == 32'h0) data = MEM[0];
    else if (dataaddr == 32'h00100000 && dataWE==0) data_read = MEM[1];
    else if (dataaddr == 32'h00100004 && dataWE==0) data_read = MEM[2];
    else if (dataaddr == 32'h00100008 && dataWE==0) data_read = MEM[2];
    else if (dataaddr == 32'h00100010 && dataWE==0) data_read = MEM[3];
    else if (dataaddr == 32'h00100014 && dataWE==1) MEM[4] = data_write;
    else if (instaddr<=32'h01000800 && instaddr>=32'h01000000) begin
      generate
        for (i=0;i<512;i++) begin
          if (instclr==1) MEM[i+5]=32'd0;
          else if (instWE==1) begin
            if (32'h01000000+i == writeaddr)  MEM[i+5] = inst_write;
          end
          else if (instWE==0) begin
            if (32'h01000000+i==readaddr) inst_read = MEM[i+5];
          end
        end
      endgenerate
    end
     else if (dataaddr<=32'h80000000 && dataaddr>=32'h800007fc) begin
      generate
        for (i=0;i<1024;i++) begin
          if (dataclr==1) REG[i+517]=32'd0;
          else if (dataWE==1) begin
            if (32'h80000000+i == dataeaddr) MEM[i+517] = data_write;
          end
          else if (instWE==0) begin
            if (32'h80000000+i==readaddr) data_read = MEM[i+517];
          end
        end      
      endgenerate
     end
    else $display("invalid operation");
  end
  else $display("Invalid Memory Addressing");
  
endmodule
