module MUX21 (
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire sel,
    output wire out
);

    case(sel)

        0: assign out = in1;
        1: assign out = in2;

    endcase

endmodule 
