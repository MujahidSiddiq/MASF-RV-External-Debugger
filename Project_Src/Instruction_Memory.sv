`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2024 12:37:17 PM
// Design Name: 
// Module Name: Instruction_Memory
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


module Instruction_Memory(
    input logic [31:0] pc,
    output logic [31:0] instruction
);

// Define memory array
logic [31:0] i_memory_array [0:999]  = '{1000{32'b0}}; // 15 32-bit words
logic [29:0] addr;
// Read data from memory initialization file
initial begin
   // $readmemh("memory_instruction.mem", i_memory_array);
   
     i_memory_array[2] = 32'h00520663; 
     i_memory_array[3] = 32'h00128293;
     i_memory_array[4] = 32'hFF9FF16F; // jump 
     i_memory_array[5] = 32'h40520333;
     i_memory_array[6] = 32'h00530393;

     i_memory_array[7] = 32'h00C02603;
     i_memory_array[8] = 32'h00D60733;

     i_memory_array[9] = 32'h00742123; // break point 0x24
     i_memory_array[10] = 32'h0034A503;
     i_memory_array[11] = 32'h00250593;
     
    // i_memory_array[2] = 32'h00012083;
    // i_memory_array[3] = 32'h00308213;
end
always@(*) begin
// addr = {pc[31:2], 2'b00};
 addr = pc[31:2] ;
// Assign instruction directly from memory_array using the provided address
 instruction = i_memory_array[addr];
end
endmodule
