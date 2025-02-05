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
     // Global control
    input  logic             clk,
    input  logic             reset,

     // Counter
    input  logic [31:0]      pc_new,

     // Control signals
    input  logic             Stall,
    input  logic             halt_active,
    input  logic             reset_stages,

     // Instruction memory
    output logic [31:0]      pc


);


    //////////////////////////////////////////////
    // **** Define program counter register ****//
    //////////////////////////////////////////////


    logic [31:0] pc_reg;
    initial begin
        pc_reg = 32'h00000008;
    end

     
    ///////////////////////////////////////////////////////////////////
    // **** Always block to update the program counter register **** //
    //////////////////////////////////////////////////////////////////


    always @(posedge clk or negedge reset) begin


        if ((!reset | (reset_stages))) begin
            pc_reg <= 32'h00000008; // Reset program counter
        end 

        else if (!halt_active) begin
            if(!Stall) begin
                 pc_reg <= pc_new; // Update program counter if not stalled
            end
        end 
        
        else begin
            pc_reg <= pc_reg; // If stalled, retain the previous value of the program counter
        end


        end


    /////////////////////////////////////////////////////////
    // **** Assign the program counter value to output ****//
    /////////////////////////////////////////////////////////


    assign pc = pc_reg;


endmodule