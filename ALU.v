module ALU (
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    output wire [31:0] alu_res,
    input wire [2:0] opcode,
    input wire is_signed
);

reg [31:0] temp;

assign operand1 =  is_signed && operand1[31] == 1 ? {1'b0,~(operand1[30:0])+1'b1} : operand1;
assign operand2 =  is_signed && operand2[31] == 1 ? {1'b0,~(operand2[30:0])+1'b1} : operand2;

// twos compliment of operand1 = {1'b0,~(operand1[30:0])+1'b1} -- need to try this

case(opcode)

    000: alu_res = operand1 + operand2; //add
    010: begin //set less than signed
        temp = operand1 + operand2;
        alu_res = temp[31]==1 ? 0:1;
    end
    011: alu_res = operand1<operand2 ? 1:0; //set les than unsigned
    100: alu_res = operand1 ^ operand2; //XOR
    110: alu_res = operand1 | operand2; //OR
    111: alu_res = operand1 & operand2; //AND
    001: alu_res = operand1 << operand2; //shift left logical
    101: begin // shift right for both unsigned and signed
        if is_signed == 1 begin
            //arithematic right shift
        end
        else alu_res = operand1 >> operand2;
    end
endcase
assign alu_res =  is_signed && alu_res[31] == 1 ? {1'b0,~(alu_res[30:0])+1'b1} : alu_res;
end

endmodule
