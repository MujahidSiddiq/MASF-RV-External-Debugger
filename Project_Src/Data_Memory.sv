`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2024 08:55:34 AM
// Design Name: 
// Module Name: Data_Memory
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


module Data_Memory(

     //Global control
    input  logic                   clk_i,

    input  logic                   Mem_read,
    input  logic                   Mem_write,
    input  logic [31:0]            Mem_addr,
    input  logic [31:0]            Mem_write_data,
    output logic [31:0]            Mem_out, 
     
    // DM
    
    input  logic                   dm_Mem_rd_en_i,             
    input  logic [31:0]            dm_Mem_rd_address_i,        
    inout  logic [31:0]            dm_Mem_rd_wr_data_io       
    
    
    );


    ///////////////////////////////////
    // **** Define memory array **** //
    ///////////////////////////////////

        logic [31:0] memory_array [0:31] =    '{32{32'b0}}; // 15 32-bit words

    initial begin
        memory_array[12]                 =    32'h00000008;
    end

    always @(posedge clk_i) begin

        if (Mem_write)
            memory_array[Mem_addr]       <=   Mem_write_data;

    end

    
    //////////////////////////////////////////////////////////
    // **** Read data from memory if Mem_R is asserted **** //
    //////////////////////////////////////////////////////////

    always_comb begin
        
        if (Mem_read)
            Mem_out                      =    memory_array[Mem_addr];
        else
        Mem_out                          =    32'b0; // Output zero if Mem_R is not asserted
        
    end

        assign dm_Mem_rd_wr_data_io      =    dm_Mem_rd_en_i ? memory_array[dm_Mem_rd_address_i] :  
                                              32'bz;


endmodule