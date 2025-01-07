`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2024 03:29:14 PM
// Design Name: 
// Module Name: Core
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


module Core(
            input  logic                clk_i,
            input  logic                reset_i,
            
            
            // DM
            input   logic                dm_halt_req_i,
            output  logic                dm_halt_ack_o, 
            output  logic                dm_resume_ack_o,
            output  logic                dm_ebreak_o, 
            output  logic                dm_step_exec_o,
            output  logic [31:0]         dm_reg_rd_wr_data_io,
            input   logic                dm_reg_rd_wr_en_i, 
            input   logic                dm_reg_rd_wr_i,
            input   logic [15:0]         dm_reg_rd_wr_address_i,
            
  
            
            // Instruction Memory
            input   logic [31:0]         instruction,
            output  logic [31:0]         PC,
            
            
            // Data Memory
            
            output  logic                Mem_read,     
            output  logic                Mem_write,    
            output  logic [31:0]         Mem_addr,     
            output  logic [31:0]         Mem_write_data,   
            input   logic [31:0]         Mem_out      

    );
    
      //      logic [31:0] PC;
      //      logic [31:0] instruction;
            logic [31:0] data_rs1;
            logic [31:0] data_rs2;
            logic [31:0] data_rd;
            logic [4:0]  addr_rd;
            logic [4:0]  addr_rs1;
            logic [4:0]  addr_rs2;
            logic        reg_WEn;
            logic        halt_active;
            logic        reset_stages;
            logic        inst_comp;
          //  logic [31:0] mem_rd_data;
          //  logic        mem_read;
          //  logic        mem_write;
          //  logic [31:0] mem_address;
          //  logic [31:0] mem_write_data;
          
            // Debug Support signals
            logic reg_access;       // Debug CSR register access signal
            logic status_reset;     // Debug CSR status reset signal
            logic [1:0] cause_control; // Debug CSR cause control signal
            logic [31:0] dscratch_reg0; // Debug CSR dscratch register output
            logic dcsr_step;        // Debug CSR step output
            logic dcsr_ebreakm;     // Debug CSR ebreakm output
                
    
        // Instantiation of the Pipeline module
    Pipeline Pipeline_3_Stages                  (
                                                .clk_i(clk_i),
                                                .reset_i(reset_i),
                                        
                                                // Instruction Memory
                                                .inst_mem_PC_o(PC),
                                                .inst_mem_M_inst_i(instruction),
                                        
                                                // GPRs
                                                .gprs_data_rs1_i(data_rs1),
                                                .gprs_data_rs2_i(data_rs2),
                                                .gprs_data_rd_o(data_rd),
                                                .gprs_addr_rd_o(addr_rd),
                                                .gprs_addr_rs1_o(addr_rs1),
                                                .gprs_addr_rs2_o(addr_rs2),
                                                .gprs_reg_WEn_o(reg_WEn),

                                                // Debug Support
                                                .DSP_halt_active_i(halt_active),
                                                .DSP_reset_stages_i(reset_stages),
                                                .DSP_inst_comp_o(inst_comp),

                                                // Data Memory
                                                .Mem_rd_data_i(Mem_out),
                                                .Mem_read_o(Mem_read),
                                                .Mem_write_o(Mem_write),
                                                .Mem_address_o(Mem_addr),
                                                .Mem_write_data_o(Mem_write_data)
                                                );






        // Instantiation of the GPRs module
        GPRs GPRs                               (
                                                .clk_i(clk_i),
                                                .data_rs1(data_rs1),
                                                .data_rs2(data_rs2),
                                                .data_rd(data_rd),
                                                .addr_rd(addr_rd),
                                                .addr_rs1(addr_rs1),
                                                .addr_rs2(addr_rs2),
                                                .reg_WEn(reg_WEn),
                                                
                                                 // DM signals
                                                .dm_reg_rd_wr_en_i(dm_reg_rd_wr_en_i),    // Register read/write enable input
                                                .dm_reg_rd_wr_i(dm_reg_rd_wr_i),              // Register read/write signal
                                                .dm_reg_rd_wr_address_i(dm_reg_rd_wr_address_i), // Register read/write address
                                                .dm_reg_rd_wr_data_io(dm_reg_rd_wr_data_io),        // Register read/write data (inout)
                                                .DSP_reg_access_i(reg_access)
                                                );                                                
                                                
        // Instantiation of the CSRs module
   //     CSRs CSRs                               (
   //                                             .clk_i(clk_i),
   //                                             .reset_i(reset_i),
   //                                             .PC(PC)
   //                                             
   //                                             );                                         


        // Instantiation of the CSRs module
        CSRs CSRs                               (
                                                .clk_i(clk_i),                          // Clock signal
                                                .reset_i(reset_i),                      // Reset signal
                                                .Pipeline_PC_i(PC),                                // Program counter input
                                            
                                                // Debug Support signals
                                                .DSP_reg_access_i(reg_access),      // Debug CSR register access signal
                                                .DSP_status_reset_i(status_reset),  // Debug CSR status reset signal
                                                .DSP_cause_control_i(cause_control),// Debug CSR cause/control signal
                                                .DSP_dscratch_reg0_o(dscratch_reg0),  // Debug CSR dscratch register output
                                                .DSP_dcsr_step_o(dcsr_step),        // Debug CSR step output
                                                .DSP_dcsr_ebreakm_o(dcsr_ebreakm),  // Debug CSR ebreakm output
                                            
                                                // DM signals
                                                .dm_reg_rd_wr_en_i(dm_reg_rd_wr_en_i),    // Register read/write enable input
                                                .dm_reg_rd_wr_i(dm_reg_rd_wr_i),              // Register read/write signal
                                                .dm_reg_rd_wr_address_i(dm_reg_rd_wr_address_i), // Register read/write address
                                                .dm_reg_rd_wr_data_io(dm_reg_rd_wr_data_io)        // Register read/write data (inout)
                                                
                                                );
                                                                                              
 
        // Instantiation of the Debug_Support module
        Debug_Support Debug_Support             (
                                                .clk_i(clk_i),
                                                .reset_i(reset_i),
                                                
                                                // Pipeline
                                                .Pipeline_PC_i(PC),
                                                .Pipeline_halt_active_o(halt_active),
                                                .Pipeline_reset_stages_o(reset_stages),
                                                .Pipeline_inst_comp_i(inst_comp),
                                                
                                                // Debug CSR signals
                                                .CSRs_reg_access_o(reg_access),          // Debug CSR register access signal
                                                .CSRs_status_reset_o(status_reset),      // Debug CSR status reset signal
                                                .CSRs_cause_control_o(cause_control),    // Debug CSR cause/control signal
                                                .CSRs_dscratch_reg0_i(dscratch_reg0),      // Debug CSR dscratch register output
                                                .CSRs_dcsr_step_i(dcsr_step),            // Debug CSR step output
                                                .CSRs_dcsr_ebreakm_i(dcsr_ebreakm),      // Debug CSR ebreakm output
                                            
                                                // DM Interface signals
                                                .dm_halt_req_i(dm_halt_req_i),          // DM halt request input
                                                .dm_halt_ack_o(dm_halt_ack_o),          // DM halt acknowledge output
                                                .dm_resume_ack_o(dm_resume_ack_o),      // DM resume acknowledge output
                                                .dm_ebreak_o(dm_ebreak_o),              // DM ebreak signal output
                                                .dm_step_exec_o(dm_step_exec_o)         // DM step execute signal output
                                            );
endmodule
