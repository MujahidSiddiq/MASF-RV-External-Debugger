`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2024 09:29:33 AM
// Design Name: 
// Module Name: CSRs
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


module CSRs(
            input logic clk_i,
            input logic reset_i,
            input logic [31:0] Pipeline_PC_i,
            
            // Debug Support inputs and outputs
            input logic DSP_reg_access_i,
            input logic DSP_status_reset_i,
            input logic [1:0] DSP_cause_control_i,
            output logic [31:0] DSP_dscratch_reg0_o,
            output logic DSP_dcsr_step_o,
            output logic DSP_dcsr_ebreakm_o,
            
            // DM inputs, outputs, and inouts
            input logic dm_reg_rd_wr_en_i,
            input logic dm_reg_rd_wr_i,
            input logic [15:0] dm_reg_rd_wr_address_i,
            inout logic [31:0] dm_reg_rd_wr_data_io

    );
    
    

                                                 
                                                 
                                                 
        Debug_CSRs Debug_CSRs       (
                                    .clk_i                 (clk_i),
                                    .reset_i               (reset_i),
                                    .Pipeline_PC_i         (Pipeline_PC_i),
                                    .DSP_reg_access_i      (DSP_reg_access_i),
                                    .DSP_status_reset_i    (DSP_status_reset_i),
                                    .DSP_cause_control_i   (DSP_cause_control_i),
                                    .DSP_dscratch_reg0_o   (DSP_dscratch_reg0_o),
                                    .DSP_dcsr_step_o       (DSP_dcsr_step_o),
                                    .DSP_dcsr_ebreakm_o    (DSP_dcsr_ebreakm_o),
                                    .dm_reg_rd_wr_en_i     (dm_reg_rd_wr_en_i),
                                    .dm_reg_rd_wr_i          (dm_reg_rd_wr_i),
                                    .dm_reg_rd_wr_address_i  (dm_reg_rd_wr_address_i),
                                    .dm_reg_rd_wr_data_io      (dm_reg_rd_wr_data_io)           // Connecting rd_wr_data to dm_rd_wr_data_io
                                    );                                                 
endmodule
