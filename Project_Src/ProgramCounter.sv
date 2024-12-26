`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2024 11:55:59 AM
// Design Name: 
// Module Name: ProgramCounter
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

module ProgramCounter (
    input logic [31:0] pc_new,
    input logic clk, Stall, reset,
    output logic [31:0] pc,
    input logic halt_active,
    input logic reset_stages
);

    // Define program counter register
    logic [31:0] pc_reg;
    initial begin
        pc_reg = 32'h00000008;
    end
    // Always block to update the program counter register
    always @(posedge clk or negedge reset) begin
        if ((!reset | (reset_stages))) begin
            // Reset program counter
            pc_reg <= 32'h00000008;
        end else if (!halt_active) begin
                if(!Stall) begin
                    // Update program counter if not stalled
                    pc_reg <= pc_new;
                end
            
        end else begin
            // If stalled, retain the previous value of the program counter
            pc_reg <= pc_reg;
        end
    end

    // Assign the program counter value to output
    assign pc = pc_reg;

endmodule


/*
module ProgramCounter (
    input logic [31:0] pc_new,
    input logic clk,Stall,
    input logic reset,
    output logic [31:0] pc
);  
  

    // Define program counter register
    logic [31:0] pc_reg;

   
    always_ff @(posedge clk, posedge reset)
    begin
        if (reset)
            pc_reg <= 32'b0; // Reset program counter
        else begin
        
            pc_reg <= pc_new;
   
        end
    end

    // Output the program counter value
    assign pc = pc_reg;


endmodule
*/