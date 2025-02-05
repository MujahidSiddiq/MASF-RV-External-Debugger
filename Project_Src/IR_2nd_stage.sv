`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 11:06:52 PM
// Design Name: 
// Module Name: IR_2nd_stage
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


module IR_2nd_stage(

     //Global control
    input  logic               clk,
    input  logic               reset_stages,

    input  logic               Stall,
    input  logic               Flush,
    input  logic [31:0]        in,
    output logic [31:0]        out
    
 
    );


    //////////////////////////////////////////////////
    // **** Registers to hold the output value **** //
    //////////////////////////////////////////////////

        logic [31:0]         out_reg;

    initial begin
        out_reg        =     32'h00000013;
    end


    always @(posedge clk) begin

        if ((Flush | reset_stages)) begin
            out_reg    <=    32'h00000013;
        end 
        
        else if (!Stall) begin
            out_reg    <=    in;
        end 
        
        else begin
            out_reg    <=    out_reg;
        end

    end


    /////////////////////////////////////////////////////
    // **** Assign output to the registered value **** //
    /////////////////////////////////////////////////////

        assign out     =     out_reg;


endmodule

