module DM(
  input wire [31:0] data_Raddr,
  input wire [31:0] W_data,
  output reg [31:0] R_data,
  input wire data_WEn,
  input wire data_REn,
  input wire D_valid,
  input wire D_clr,
  output reg D_err
);
  
  const no_reg=4096;
  localparam start_addr = 32'h80000000 
  reg [31:0][reg_no-1:0]DATA;
  genvar i;
  
  generate
    for (i=0;i<no_reg;i++) begin
      always@ posedge D_valid begin
        if data_addr >= start_addr && data_addr <= start_addr + no_reg * 4 && data_addr%4 == 0 begin
            if D_clr==1 begin
            DATA[i]<=0;   end// can include if statements here to not clear some memory locations
            else if data_REn ==1 begin
            if i==data_addr R_data<=DATA[i]; end
            else if data_WEn ==1 begin
            if i==data_addr DATA[i]<=W_data; end
            else D_err<=1
        end
        else I_err<=1;
      end
    end
  endgenerate
  endmodule
