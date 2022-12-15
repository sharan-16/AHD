`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2022 06:54:43 PM
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU (
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    output reg [31:0] alu_res,
    input wire [2:0] opcode,
    input wire is_signed
);

//assign operand1 =  is_signed && operand1[31] == 1 ? {1'b0,~(operand1[30:0])+1'b1} : operand1;
//assign operand2 =  is_signed && operand2[31] == 1 ? {1'b0,~(operand2[30:0])+1'b1} : operand2;

// twos compliment of operand1 = {1'b0,~(operand1[30:0])+1'b1} -- need to try this
always@(*) begin
    case(opcode)
    
        000: begin 
            if(is_signed==1)  alu_res = operand1 + operand2; //module module ALU
            else alu_res = operand1 - operand2; //sub 
            end
        010: alu_res = $signed(operand1) < $signed(operand2) ? 1:0; //set less than signed   
        011: alu_res = operand1 < operand2 ? 1:0; //set les than unsigned
        100: alu_res = operand1 ^ operand2; //XOR
        110: alu_res = operand1 | operand2; //OR
        111: alu_res = operand1 & operand2; //AND
        001: alu_res = operand1 << operand2; //shift left logical
        101: begin // shift right for both unsigned and signed
            if (is_signed == 1) begin
                alu_res = $signed(operand1) >> operand2; //arithematic right shift
            end
            else alu_res = operand1 >> operand2;
            end
    endcase
    //assign alu_res =  is_signed && alu_res[31] == 1 ? {1'b0,~(alu_res[30:0])+1'b1} : alu_res;
end
endmodule
