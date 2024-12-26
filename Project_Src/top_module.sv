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


module Top_Module(

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
        output  logic [31:0]     dmi_rsp_data_o
        
      
    );
    
                logic             ht_halt_ack;
                logic             ht_resume_ack;
                logic             ht_halt_req;
                logic             ht_rd_wr_en;
                logic             ht_rd_wr;
                logic [15:0]      ht_rd_wr_address;
                wire  [31:0]      ht_rd_wr_data;
                logic             ht_ebreak;
                logic             ht_step_exec;

                //pipeline
                logic             pipeline_inst_comp;
                logic [31:0]      pipeline_pc;
                logic             pipeline_halt_active;
                logic             pipeline_reset_stages;


    
    DM Debug_Module                                     (
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
                                                        .ht_resume_ack_i                (ht_resume_ack),
                                                        .ht_ebreak_i                    (ht_ebreak),
                                                        .ht_step_exec_i                 (ht_step_exec)
                                                        );
                        
                        
                        
    HART Hardware_Thread                                (
                                                        .clk_i                          (clk),
                                                        .reset_i                        (reset),
                                                        .dm_halt_ack_o                  (ht_halt_ack),
                                                        .dm_resume_ack_o                (ht_resume_ack),
                                                        .dm_halt_req_i                  (ht_halt_req),                
                                                        .dm_rd_wr_en_i                  (ht_rd_wr_en),
                                                        .dm_rd_wr_i                     (ht_rd_wr),
                                                        .dm_rd_wr_address_i             (ht_rd_wr_address),
                                                        .dm_rd_wr_data_io               (ht_rd_wr_data),
                                                        .dm_ebreak_o                    (ht_ebreak),
                                                        .dm_step_exec_o                 (ht_step_exec),
                                                        .pipeline_inst_comp_i           (pipeline_inst_comp),
                                                        .pipeline_pc_i                  (pipeline_pc),
                                                        .pipeline_halt_active_o         (pipeline_halt_active),
                                                        .pipeline_reset_stages_o        (pipeline_reset_stages)                  
                                                        );



    Pipeline Pipeline_3_stages                          (
                                                        .clk                            (clk),
                                                        .reset                          (reset),
                                                        .ht_inst_comp_o                 (pipeline_inst_comp),
                                                        .ht_pc_o                        (pipeline_pc),
                                                        .ht_halt_active_i               (pipeline_halt_active),
                                                        .ht_reset_stages_i              (pipeline_reset_stages)
                                                        // .ht_ebreak_i                    (ht_ebreak)
                                                        );                    
                    
endmodule
