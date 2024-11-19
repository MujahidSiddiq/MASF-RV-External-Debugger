`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2024 02:01:22 PM
// Design Name: 
// Module Name: Reg_File
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


module Reg_File(
    input logic [31:0] data_rd,
    input logic [4:0] addr_rs1, addr_rs2, addr_rd,
    input logic reg_WEn, clk,
    output logic [31:0] data_rs1, data_rs2 //, current_rd_data
);
    // Register file memory
    logic [31:0] reg_memory[0:31]; // No initialization needed
    // logic [4:0]prevrd;
    // Ensure R0 is always zero
    initial begin
    reg_memory = '{default: 32'b0}; // SystemVerilog shorthand
    end

    always @* begin
        reg_memory[0] = 32'h00000000;
    end
    
    initial begin
        // Write data to memory
        
        reg_memory[2] = 32'h00000000;
        reg_memory[4] = 32'h00000009; 
        reg_memory[5] = 32'h00000006;
        reg_memory[8] = 32'h00000003;
        reg_memory[9] = 32'h00000002;
        reg_memory[13] = 32'h00000007;
        
       // reg_memory[2] = 32'h00000001;
        // Read data from memory
        //$display("Data at address 0: %h", memory[0]);
    end
    // Read operation
    assign data_rs1 = reg_memory[addr_rs1];
    assign data_rs2 = reg_memory[addr_rs2];
    // assign current_rd_data = reg_memory[prevrd];

    // Write operation (positive edge-triggered)
    always @(posedge clk) begin
        if ( (reg_WEn) && (addr_rd != 5'b00000) ) begin
            reg_memory[addr_rd] <= data_rd;
            // prevrd <= addr_rd;
        end
    end
endmodule

