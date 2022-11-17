// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
module REG_TB();
  
  reg [4:0] readaddr1;
  reg [4:0] readaddr2;
  reg [4:0] writeaddr;
  reg [31:0] write_data;
  reg write_cntrl;
  reg clk;
  reg clr;
  wire [31:0] read1;
  wire [31:0] read2;
  
  REGISTERS DUT(readaddr1, readaddr2, writeaddr, write_data, write_cntrl, clk, clr, read1, read2);
  
  always
    #10 clk=~clk;
  
  initial begin
    
    clk=0;
    #2
    clr=1;
    #2
    clr=0;
    #2
    
    readaddr1 = 0; readaddr2=0;
    #2
    if (read1==0 && read2==0) $display("test case1 passed");
    else $display("test case1 failed");
    
    #2
    write_cntrl=1;
    write_data=32'd25;
    writeaddr=5'd25;
    @ (posedge clk)
    #2
    readaddr1=5'd25;
    #2
    if (read1==32'd25) $display("test case2 passed", read1);
    else $display("test case2 failed", read1);
    
    write_data=32'd28;
    writeaddr=5'd28;
    @ (posedge clk)
    #2
    readaddr1=5'd28; 
    #2
    if (read1==32'd28) $display("test case3 passed", read1);
    else $display("test case3 failed", read1, readaddr1, writeaddr, write_data);
    
    #2
    readaddr1=5'd28; readaddr2=5'd25;#1
    write_data=read1+read2;
    writeaddr=5'd16;
    
    
    @ (posedge clk)
    #2readaddr1=5'd16;#2
    if (read1==32'd53) $display("test case4 passed");
    else $display("test case4 failed",read1);
    
    #2
    clr=1;
    #2
    readaddr1=5'd16;
    if (read1==32'd0) $display("test case5 passed");
    else $display("test case5 failed");
    #2
    readaddr1=5'd25;
    if (read1==32'd0) $display("test case5 passed");
    else $display("test case5 failed");
    
  end
   
endmodule
