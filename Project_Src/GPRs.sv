`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2024 08:28:51 AM
// Design Name: 
// Module Name: GPRs
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


module GPRs(
    input logic [31:0] data_rd,
    input logic [4:0] addr_rs1, addr_rs2, addr_rd,
    input logic reg_WEn, clk_i,
    output logic [31:0] data_rs1, data_rs2, //, current_rd_data
    
    
    // DM
    input logic dm_reg_rd_wr_en_i,
    input logic dm_reg_rd_wr_i,
    input logic [15:0] dm_reg_rd_wr_address_i,
    inout logic [31:0] dm_reg_rd_wr_data_io,
    
    input logic DSP_reg_access_i
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
    always @(posedge clk_i) begin
        if ( (reg_WEn) && (addr_rd != 5'b00000) ) begin
            reg_memory[addr_rd] <= data_rd;
            // prevrd <= addr_rd;
        end
    end
    assign dm_reg_rd_wr_data_io =  ( (dm_reg_rd_wr_en_i) & (!dm_reg_rd_wr_i)  & (dm_reg_rd_wr_address_i[15:8] == 8'h10 ) & (dm_reg_rd_wr_address_i[7:5] == 0 ) & (DSP_reg_access_i) )  ? reg_memory[dm_reg_rd_wr_address_i[4:0]] : 32'bz;

endmodule
