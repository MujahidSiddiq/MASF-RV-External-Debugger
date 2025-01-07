`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2024 03:04:07 PM
// Design Name: 
// Module Name: Top_Module
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


module Top_Module(
                        input logic clk_i,
                        input logic reset_i,
                        // DMI Req to DM signals
                        input  logic [1:0]          dmi_req_op_i,
                        input  logic [31:0]         dmi_req_data_i,
                        input  logic [6:0]          dmi_req_address_i,
                        input  logic                dmi_req_valid_i,
                    
                        // DM response to DMI signals
                        output logic                dmi_req_ready_o, 
                        output logic                dmi_rsp_valid_o,
                        output logic [31:0]         dmi_rsp_data_o,
                        output logic [1:0]          dmi_rsp_op_o

    );
    
                        logic             halt_ack;
                        logic             resume_ack;
                        logic             halt_req;
                        logic             rd_wr_en;
                        logic             rd_wr;
                        logic [15:0]      rd_wr_address;
                        wire  [31:0]      rd_wr_data;
                        logic             ebreak;
                        logic             step_exec;
                        logic [31:0]      PC;
                        logic [31:0]      instruction;
                        
                        logic             Mem_read;;     
                        logic             Mem_write;    
                        logic [31:0]      Mem_addr;     
                        logic [31:0]      Mem_write_data;  
                        logic [31:0]      Mem_out;
                        logic Mem_rd_en;
                        logic [31:0] Mem_rd_address;
                             
    
    DM Debug_Module                                     (
                                                        .clk_i                          (clk_i),
                                                        .reset_i                        (reset_i),
                                                        .dmi_req_op_i                   (dmi_req_op_i),
                                                        .dmi_req_data_i                 (dmi_req_data_i),
                                                        .dmi_req_address_i              (dmi_req_address_i),
                                                        .dmi_req_valid_i                (dmi_req_valid_i),
                                                        .dmi_req_ready_o                (dmi_req_ready_o),
                                                        .dmi_rsp_valid_o                (dmi_rsp_valid_o),
                                                        .dmi_rsp_data_o                 (dmi_rsp_data_o),
                                                        .dmi_rsp_op_o                   (dmi_rsp_op_o),
                                                        .core_halt_ack_i                (halt_ack),
                                                        .core_halt_req_o                (halt_req),
                                                        .core_rd_wr_en_o                (rd_wr_en),
                                                        .core_rd_wr_o                   (rd_wr),
                                                        .core_rd_wr_address_o           (rd_wr_address),
                                                        .core_rd_wr_data_io             (rd_wr_data),
                                                        .core_resume_ack_i              (resume_ack),
                                                        .core_ebreak_i                  (ebreak),
                                                        .core_step_exec_i               (step_exec),
                                                        .Mem_rd_en_o                    (Mem_rd_en),
                                                        .Mem_rd_address_o               (Mem_rd_address)
                                                        
                                                        );
                                                        
                                                        
                                                        
                                                        

    Core Risc_V_Core                                     (
                                                        .clk_i                          (clk_i),
                                                        .reset_i                        (reset_i),
                                                        .dm_halt_ack_o                  (halt_ack),
                                                        .dm_halt_req_i                  (halt_req),
                                                        .dm_reg_rd_wr_en_i                  (rd_wr_en),
                                                        .dm_reg_rd_wr_i                     (rd_wr),
                                                        .dm_reg_rd_wr_address_i             (rd_wr_address),
                                                        .dm_reg_rd_wr_data_io               (rd_wr_data),
                                                        .dm_resume_ack_o                (resume_ack),
                                                        .dm_ebreak_o                    (ebreak),
                                                        .dm_step_exec_o                 (step_exec),
                                                        .Mem_read                       (Mem_read),     
                                                        .Mem_write                      (Mem_write),
                                                        .Mem_addr                       (Mem_addr),
                                                        .Mem_write_data                 (Mem_write_data),
                                                        .Mem_out                        (Mem_out),
                                                        .PC                             (PC),
                                                        .instruction                    (instruction)
                                                        );
                        
                        
       // Instruction Memory instantiation
    Instruction_Memory Instruction_Memory               (  
                                                        .pc                             (PC),
                                                        .instruction                    (instruction)                
                                                        // Add connections for Instruction_Memory ports here
                                                        );

    // Data Memory instantiation
    Data_Memory Data_Memory                             (
                                                        .clk_i                          (clk_i),
                                                        .Mem_read                       (Mem_read),
                                                        .Mem_write                      (Mem_write),
                                                        .Mem_addr                       (Mem_addr),
                                                        .Mem_write_data                 (Mem_write_data),
                                                        .Mem_out                        (Mem_out),
                                                        
                                                        // DM
                                                        .dm_Mem_rd_en_i                 (Mem_rd_en),
                                                        .dm_Mem_rd_address_i            (Mem_rd_address),
                                                        .dm_Mem_rd_wr_data_io           (rd_wr_data)
                                                        // Add connections for Data_Memory ports here
                                                        ); 
    
    
    
    
endmodule
