module IM(
  input wire [31:0] instr_Raddr,
  input wire [31:0] W_instr,
  output reg [31:0] R_instr,
  input wire instr_WEn,
  input wire instr_REn,
  input wire I_valid,
  input wire I_clr,
  output reg I_err
);
  
  const no_reg=1024;
  reg [31:0][reg_no-1:0]INSTR;
  genvar i;
  
  generate
    for (i=0;i<no_reg;i++) begin
      always@ posedge I_valid begin
        if instr_addr >= 32'h01000000 && instr_addr <= 32'h01000000 + no_reg * 4 && instr_addr%4 == 0 begin
            if clr==1 begin
            MEM[i]<=0;   end// can include if statements here to not clear some memory locations
            else if instr_REn ==1 begin
            if i==dataRaddr R_instr<=INSTR[i]; end
            else if instr_WEn ==1 begin
            if i==dataRaddr INSTR[i]<=W_instr; end
            else I_err<=1
        end
        else I_err<=1;
      end
    end
  endgenerate
  endmodule
