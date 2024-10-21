`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2024 04:58:59 PM
// Design Name: 
// Module Name: top_module
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


module top_module(

        input   logic           clk, 
        input   logic           reset,
        
        
        // dmi
        input   logic            dmi_req_valid_i,
        input   logic [1:0]      dmi_req_op_i,
        input   logic [6:0]      dmi_req_address_i,
        input   logic [31:0]     dmi_req_data_i,
        
        output  logic            dmi_req_ready_o, 
        output  logic            dmi_rsp_valid_o,
        output  logic [1:0]      dmi_rsp_op_o,
        output  logic [31:0]     dmi_rsp_data_o,
        
        // core
        input   logic            core_inst_comp_i,    
        input   logic [31:0]     core_pc_to_dpc_i,
        output  logic            core_halt_o, 
        output  logic            core_resuming_o,
        output  logic [31:0]     core_dpc_for_pc_o
      
    );
    
                logic             ht_halt_ack;
                logic             ht_resume_ack;
                logic             ht_halt_req;
                logic             ht_rd_wr_en;
                logic             ht_rd_wr;
                logic             ht_stepping;
                logic             ht_first_step_exec;   
                logic [15:0]      ht_rd_wr_address;
                wire  [31:0]      ht_rd_wr_data;


    
    DM Debug_Module             (
                                    .clk_i                          (clk),
                                    .reset_i                        (reset),
                                    .dmi_req_op_i                   (dmi_req_op_i),
                                    .dmi_req_data_i                 (dmi_req_data_i),
                                    .dmi_req_address_i              (dmi_req_address_i),
                                    .dmi_req_valid_i                (dmi_req_valid_i),
                                    .dmi_req_ready_o                (dmi_req_ready_o),
                                    .dmi_rsp_valid_o                (dmi_rsp_valid_o),
                                    .dmi_rsp_data_o                 (dmi_rsp_data_o),
                                    .dmi_rsp_op_o                   (dmi_rsp_op_o),
                                    .ht_halt_ack_i                  (ht_halt_ack),
                                    .ht_halt_req_o                  (ht_halt_req),
                                    .ht_rd_wr_en_o                  (ht_rd_wr_en),
                                    .ht_rd_wr_o                     (ht_rd_wr),
                                    .ht_rd_wr_address_o             (ht_rd_wr_address),
                                    .ht_rd_wr_data_io               (ht_rd_wr_data),
                                    .ht_stepping_i                  (ht_stepping),
                                    .ht_first_step_exec_i           (ht_first_step_exec),
                                    .ht_resume_ack_i                (ht_resume_ack)
                                );
                        
                        
                        
    HART Hardware_Thread        (
                                    .clk_i                          (clk),
                                    .reset_i                        (reset),
                                    .dm_halt_ack_o                  (ht_halt_ack),
                                    .dm_resume_ack_o                (ht_resume_ack),
                                    .dm_halt_req_i                  (ht_halt_req),                
                                    .dm_rd_wr_en_i                  (ht_rd_wr_en),
                                    .dm_rd_wr_i                     (ht_rd_wr),
                                    .dm_rd_wr_address_i             (ht_rd_wr_address),
                                    .dm_rd_wr_data_io               (ht_rd_wr_data),                   
                                    .dm_stepping_o                  (ht_stepping),
                                    .dm_first_step_exec_o           (ht_first_step_exec),                    
                                    .core_halt_o                    (core_halt_o),
                                    .core_resuming_o                (core_resuming_o),
                                    // .core_dpc_io                 (core_dpc_io),
                                    .core_pc_to_dpc_i               (core_pc_to_dpc_i),
                                    .core_dpc_for_pc_o              (core_dpc_for_pc_o),
                                    .core_inst_comp_i               (core_inst_comp_i)
                                );
                        
                    
endmodule
