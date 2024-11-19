`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2024 03:58:01 PM
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
    input logic [3:0] ALU_op,
    input logic [31:0] alu_data1,
    input logic [31:0] alu_data2,
    output logic [31:0] ALU_result
);

// Define a struct to represent the ALU operation
typedef struct packed {
    logic [31:0] data1;
    logic [31:0] data2;
    logic [31:0] result;
} ALU_Operation;

// Instantiate an ALU_Operation object
ALU_Operation alu_operation;

// ALU operation logic using always_comb
always_comb begin
    case (ALU_op)
        // ADD
        4'b0000: alu_operation.result = alu_operation.data1 + alu_operation.data2; //add
        // SUB
        4'b0001: alu_operation.result = alu_operation.data1 - alu_operation.data2; //sub
        // SLL
        4'b0010: alu_operation.result = alu_operation.data1 << alu_operation.data2; // sll
        // SLT
        4'b0011: alu_operation.result = (alu_operation.data1 < alu_operation.data2) ? 32'b1 : 32'b0; // slt
        // SLTU
        4'b0100: alu_operation.result = (alu_operation.data1 < alu_operation.data2) ? 32'b1 : 32'b0; // Unsigned comparison
        // XOR
        4'b0101: alu_operation.result = alu_operation.data1 ^ alu_operation.data2; //xor
        // SRL
        4'b0110: alu_operation.result = alu_operation.data1 >> alu_operation.data2;  // srl
        // SRA
        4'b0111: alu_operation.result = $signed(alu_operation.data1) >>> alu_operation.data2[4:0]; // Arithmetic right shift
        // OR
        4'b1000: alu_operation.result = alu_operation.data1 | alu_operation.data2; // or
        // AND
        4'b1001: alu_operation.result = alu_operation.data1 & alu_operation.data2;  // and
        // Case for alu_op = 1010
        4'b1010: alu_operation.result = alu_operation.data2; // Direct connect imm with output
        // for Nop
        4'b1111: alu_operation.result = 0;
        default: alu_operation.result = 0; // Unsupported operation
    endcase
end

// Assign inputs to the ALU operation struct
assign alu_operation.data1 = alu_data1;
assign alu_operation.data2 = alu_data2;

// Output the result from the ALU operation struct
assign ALU_result = alu_operation.result;

endmodule


/*
module ALU (
    input logic [3:0] ALU_op,
    input logic [31:0] alu_data1,
    input logic [31:0] alu_data2,
    output logic [31:0] ALU_result
);

always_comb begin
    case (ALU_op)
        // ADD
        4'b0000: ALU_result = alu_data1 + alu_data2; //add
        // SUB
        4'b0001: ALU_result = alu_data1 - alu_data2; //sub
        // SLL
        4'b0010: ALU_result = alu_data1 << alu_data2; // sll
        // SLT
        4'b0011: ALU_result = (alu_data1 < alu_data2) ? 32'b1 : 32'b0; // slt
        // SLTU
        4'b0100: ALU_result = (alu_data1 < alu_data2) ? 32'b1 : 32'b0; // Unsigned comparison
        // XOR
        4'b0101: ALU_result = alu_data1 ^ alu_data2; //xor
        // SRL
        4'b0110: ALU_result = alu_data1 >> alu_data2;  // srl
        // SRA
        4'b0111: ALU_result = $signed(alu_data1) >>> alu_data2[4:0]; // Arithmetic right shift
        // OR
        4'b1000: ALU_result = alu_data1 | alu_data2; // or
        // AND
        4'b1001: ALU_result = alu_data1 & alu_data2;  // and
        // Case for alu_op = 1010
        4'b1010: ALU_result = alu_data2; // Direct connect imm with output
       
       
       
       /*
       
        // Case for alu_op = 1011
        4'b1011: ALU_result = alu_data2; // Copy rs2_data
        // Case for alu_op = 1100
        4'b1100: ALU_result = ~alu_data1; // Bitwise NOT of rs1_data
        // Case for alu_op = 1101
        4'b1101: ALU_result = ~alu_data2; // Bitwise NOT of rs2_data
        // Case for alu_op = 1110
        4'b1110: ALU_result = alu_data1 + 1; // Increment rs1_data by 1
        // Case for alu_op = 1111
        4'b1111: ALU_result = alu_data1 - 1; // Decrement rs1_data by 1
        
        
        default: ALU_result = 32'b0; // Unsupported operation
    endcase
end

endmodule
*/