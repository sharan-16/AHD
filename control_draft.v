module(
    input wire [31:0]instr,
    input wire start,
    input wire clk,
);

reg [31:0] imm=0,rs1,rs2;
wire [31:0] operand1, operand2;

localparam IDLE = 3'd0;
localparam IF = 3'd0;
localparam ID = 3'd0;
localparam EX = 3'd0;
localparam MEM = 3'd0;
localparam WB = 3'd0;

reg [2:0] STATE = 0;
reg branch_res = 0;
wire PC_out; reg PC;

reg [31:0] instr_addr;
reg [31:0] W_instr; //can be used in upper level
reg instr_WEn=0; reg I_clr=0;
reg I_err =0; //can be used later when dealing with errors
wire [31:0] R_instr;
reg instr_REn=0;
reg I_valid=0;

reg is_branch, is_load, is_store, is_imm, is_shift, is_reg, is_fence, is_Etype, is_LUI, is_AUIPC, is_JAL, is_JALR;
reg imm_valid;


reg [3:0] alu_opcode;
localparam add = 0;
//define alu_res decide reg or wire

//module instatiations
//PC
// ALU
MUX21 PC_sel (.in1(),.in2(alu_res).sel(branch_res),.out(PC_out)); // two inputs are PC+4 and ALU output
MUX21 A_sel (.in1(rs1),.in2(PC).sel(is_branch||is_AUIPC||is_JAL),.out(operand1));
MUX21 B_sel (.in1(rs2),.in2(imm).sel(imm_valid),.out(operand2));
MUX21 JAL_sel (.in1(/*alu module's output, should mostly be register*/),.in2(PC+32'd4).sel(is_JAL),.out(alu_res)); // special mux for JAL instruction
MUX21 JAL_sel (.in1(/*alu module's output, should mostly be register*/),.in2(/*MEM stage output*/).sel(is_load),.out(/*reg_write data*/)); // for load instructions
IM IMemory(.instr_addr(instr_addr),.W_instr(W_instr),.R_instr(R_instr),.instr_WEn(instr_WEn),.instr_REn(instr_REn),.I_valid(I_valid),.I_clr(I_clr),.I_err(I_err)); 
DM DMemory(.data_addr(data_addr),.W_data(W_data),.R_data(R_data),.data_WEn(data_WEn),.data_REn(data_REn),.D_valid(D_valid),.D_clr(D_clr),.D_err(D_err));

always@posedge clk begin

    case(State) // need to includen error conditions in every stage - in this or the next alwasys block

    IDLE: begin
        if start == 1 STATE <= IF;
    end
    IF: begin
        STATE <= IF;
    end
    ID: begin
        STATE <= EX;
    end
    EX: begin
        STATE <= MEM;
    end
    MEM: begin
        STATE <= WB;
    end 
    WB: begin
        STATE <= IDLE;
    end
    endcase
end

always @ STATE begin
        
    case(State) 

    IDLE: begin
        //use this state to load the instrs into the IM
    end
    IF: begin
        if start == 1 begin
            instr_addr = PC;
            I_valid = 1;
            instr = R_instr; 
            I_valid = 0;
            //used in IF stage
            is_branch <=  instr[6:2] == 5'b11000 ? 1:0;
            is_load   <=  instr[6:2] == 5'b0 ? 1:0;
            is_store  <=  instr[6:2] == 5'b01000 ? 1:0;
            is_imm    <=  instr[6:2] == 5'b00100 ? 1:0;
            is_shift  <=  instr[6:2] == 5'b00100 && instr[14:12] == 001|101 ? 1:0;
            is_reg    <=  instr[6:2] == 5'b01100 ? 1:0;
            is_fence  <=  instr[6:2] == 5'b00100 ? 1:0;
            is_Etype  <=  instr[6:2] == 5'b11100 ? 1:0;
            is_LUI    <=  instr[6:2] == 5'b01101 ? 1:0;
            is_AUIPC  <=  instr[6:2] == 5'b00101 ? 1:0;
            is_JAL    <=  instr[6:2] == 5'b11011 ? 1:0;
            is_JALR   <=  instr[6:2] == 5'b11001 ? 1:0;
        end
    end
    ID: begin
        if start == 1 begin
            if is_branch == 1 begin
                imm <= {instr[31:25],instr[11:7]};
                //read rs1 and rd
                imm_valid = 1;
                data_REn = 1;
                alu_opcode <= add;
            end
            else if is_load || is_imm == 1 begin
                imm <= instr[31:20];
                //read rs1 and rs2
                imm_valid = 1;
                reg_WEn = 1;
                alu_opcode <= add;
            end
            else if is_store == 1 begin
                imm <= {instr[31:25],instr[11:7]};
                //read rs1 and rs2
                imm_valid = 1;
                data_WEn = 1;
                alu_opcode <= add;
            end
            else if is_imm == 1 begin
                imm <= instr[31:20];
                //read rs1 and rs2
                imm_valid = 1;
                reg_WEn = 1;
                alu_opcode <= instr[14:12];
            end
            else if is_shift == 1 begin
                imm <= instr[24:20];
                //read rs1 
                imm_valid = 1;
                reg_WEn = 1;
                alu_opcode <= instr[14:12];
            end
            else if is_reg == 1 begin
                //read rs1 and rs2
                imm_valid = 0;
                reg_WEn = 1;
                alu_opcode <= instr[14:12];
            end
            else if is_fence == 1 begin
                //need to check
                imm <= 32'd0;
                imm_valid <= 1;
                // reg read addr zero 0 and write addr is also zero 
                reg_WEn <= 1;
                alu_opcode <= add;
                //the iunstruction manual advices to implement addi r0,r0,0 what if the writing into r0 is restrcited in the reg file, can write r1
            end
            else if is_Etype == 1 begin
                start <= 0;
            end
            else if is_LUI == 1 begin
                //need to adjust
                imm <= {instr[31:12],12'd0};
                imm_valid <= 1; 
                reg_WEn <= 1;
                alu_opcode <= /*a separate special alu opcode is needed to let the ALU act as a buffer, i.e just reflects the imm value at output*/;
            end
            else if is_AUIPC == 1 begin
                //need to check
                imm <= {instr[31:12],12'd0};
                imm_valid <= 1; 
                reg_WEn <= 1;
                alu_opcode <= add;
            end
            else if is_JAL == 1 begin
                //need to check
                imm <= {instr[31:12],12'd0}; // need confirmation on this, in actual it is sign extended imm value
                imm_valid <= 1; 
                reg_WEn <= 1;
                alu_opcode <= add;
            end
            else if is_JALR == 1 begin
                //need to check
                imm <= {instr[31:12],12'd0}; // need confirmation on this, in actual it is sign extended imm value
                imm_valid <= 1; 
                reg_WEn <= 1;
                alu_opcode <= add;
            end
        end
    end
    EX: begin
        if start == 1 begin
            //ALU(operand1, operannd2, opcode, alu_res)
            //branch comparator
        end
    end
    MEM: begin
        if start == 1 begin
            if data_REn || data_WEn == 1 begin
                data_Waddr = alu_res;
                data_Raddr = alu_res;
            end
        end
    end 
    WB: begin
        if start == 1 begin
            if Reg_WEn == 1 begin
                reg_addr = instr[11:7];
            end
        end
    end
    endcase
end

endmodule
