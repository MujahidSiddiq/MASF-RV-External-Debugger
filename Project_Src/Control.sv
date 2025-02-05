`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2024 01:53:51 AM
// Design Name: 
// Module Name: Control
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


module Control(
     //Global control
    input  logic            clk,

     //Control signals
    input  logic            reg_WEn,  
    input  logic            Mem_R,
    input  logic            Mem_W,
    input  logic            Stall,
    input  logic [1:0]      WB_sel,
    input  logic            reset_stages,
    output logic            reg_wrMW, 
    output logic            Mem_read,
    output logic            Mem_write,
    output logic [1:0]      WB_sel_MW
    
    );


    ////////////////////////////////////////////////////////////////////
    // **** Registers to store previous values of output signals **** //
    ////////////////////////////////////////////////////////////////////

           logic            reg_wrMW_reg;
           logic            Mem_read_reg;
           logic            Mem_write_reg;
           logic [1:0]      WB_sel_MW_reg;


    initial begin
           reg_wrMW_reg     =      0;
           Mem_read_reg     =      0;
           Mem_write_reg    =      0;
           WB_sel_MW_reg    =      0;
    end


    always @(posedge clk) begin

        if(reset_stages) begin
           reg_wrMW_reg     =      0;
           Mem_read_reg     =      0;
           Mem_write_reg    =      0;
           WB_sel_MW_reg    =      0;
        end

        else if (!Stall) begin

            // Update control signals if not stalled

           reg_wrMW_reg     <=     reg_WEn;
           Mem_read_reg     <=     Mem_R;
           Mem_write_reg    <=     Mem_W;
           WB_sel_MW_reg    <=     WB_sel;
        end 
        
        else begin

            // Retain previous values when stalled

           reg_wrMW_reg     <=     reg_wrMW_reg;
           Mem_read_reg     <=     Mem_read_reg;
           Mem_write_reg    <=     Mem_write_reg;
           WB_sel_MW_reg    <=     WB_sel_MW_reg;
        end

    end


    /////////////////////////////////////////////////////////
    // **** Assign output signals to registered values ****//
    /////////////////////////////////////////////////////////

           assign reg_wrMW  =      reg_wrMW_reg;
           assign Mem_read  =      Mem_read_reg;
           assign Mem_write =      Mem_write_reg;
           assign WB_sel_MW =      WB_sel_MW_reg;


endmodule

