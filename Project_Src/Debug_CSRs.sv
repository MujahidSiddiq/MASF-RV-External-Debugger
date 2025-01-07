`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2024 09:32:54 AM
// Design Name: 
// Module Name: Debug_CSRs
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
// Include the header file
`include "Debug_CSRs_Header.svh"

module Debug_CSRs(
                    input logic clk_i,
                    input logic reset_i,
                    input logic [31:0] Pipeline_PC_i,
                    
                    
                    // Debug Support
                    input logic DSP_reg_access_i,
                    input logic DSP_status_reset_i,
                    input logic [1:0] DSP_cause_control_i,
                    output logic [31:0] DSP_dscratch_reg0_o,
                    output logic DSP_dcsr_step_o,
                    output logic DSP_dcsr_ebreakm_o,
                    
                    // DM
                    input logic dm_reg_rd_wr_en_i,
                    input logic dm_reg_rd_wr_i,
                    input logic [15:0] dm_reg_rd_wr_address_i,
                    inout logic [31:0] dm_reg_rd_wr_data_io
    );
    
    
    
    
    
    
    
    
    
    
    
    // Define the writable mask 
    localparam logic [31:0] WRITABLE_MASK_DCSR = 32'h0005DF37;  
    // Define the fixed-zero mask 
    localparam logic [31:0] FIXED_ZERO_MASK_DCSR = 32'h08F44000; 

    localparam logic [31:0] RESET_VALUE_OF_DCSR = 32'h00000003;


  //  type_states_dmode_e current_state, next_state; // initiate states
    type_dmode_reg_dcsr_e dcsr_reg;  // initiate dcsr register
    logic [31:0] dpc_reg, dscratch0_reg;



    logic [31:0]            dpc_mux_out;
    logic                   read_dpc;
    logic                   dscratch0_mux_sel;
    logic [31:0]            dscratch0_mux_out;
    logic                   wire_address_dcsr_en;
    logic [31:0]            dcsr_mux_out;
    logic                   dcsr_mux_sel;
    logic [31:0]            dcsr_mux_input_1;
    logic [31:0]            dcsr_mux_input_0;
    logic                   read_dcsr;
    logic [31:0]            reset_control_of_dcsr;
    logic [2:0]             cause;
    
    
    // address for CSRs
    logic                   access_CSRs;

    assign access_CSRs               = dm_reg_rd_wr_address_i[15:12] == 0;
    assign dpc_mux_out               = (DSP_reg_access_i) ? Pipeline_PC_i : dpc_reg; 
    assign read_dpc                  = (DSP_reg_access_i) & ( (dm_reg_rd_wr_address_i[11:0] == Dpc ) & (!dm_reg_rd_wr_i) ) & (access_CSRs);
    assign dscratch0_mux_sel         = (DSP_reg_access_i) & ( ((dm_reg_rd_wr_address_i[11:0] == Dscratch0) & (dm_reg_rd_wr_en_i)) & (dm_reg_rd_wr_i) ) & (access_CSRs);
    assign dscratch0_mux_out         = dscratch0_mux_sel ? dm_reg_rd_wr_data_io : dscratch0_reg;
    assign wire_address_dcsr_en      = ( dm_reg_rd_wr_address_i[11:0] == Dcsr ) & (dm_reg_rd_wr_en_i);
    assign dcsr_mux_sel              = ( wire_address_dcsr_en & dm_reg_rd_wr_i ) & (DSP_reg_access_i) & (access_CSRs);  
    assign read_dcsr                 = (DSP_reg_access_i) & ( (!dm_reg_rd_wr_i)&(wire_address_dcsr_en) ) & (access_CSRs);  
    assign dcsr_mux_input_1          = ( dcsr_reg & (~WRITABLE_MASK_DCSR) 
                                                  & (~FIXED_ZERO_MASK_DCSR) )
                                                  | (dm_reg_rd_wr_data_io & WRITABLE_MASK_DCSR) ;  
    assign cause                     = (DSP_cause_control_i == 2'b00) ? dcsr_reg.cause :
                                       (DSP_cause_control_i == 2'b01) ? 3'b100 :
                                       (DSP_cause_control_i == 2'b10) ? 3'b011 : 3'b001;
    assign reset_control_of_dcsr     = (dcsr_reg) & (~WRITABLE_MASK_DCSR)
                                                  | ( (32'(cause) << 6) & (FIXED_ZERO_MASK_DCSR) );
    assign dcsr_mux_input_0          = DSP_status_reset_i ? RESET_VALUE_OF_DCSR : reset_control_of_dcsr;                                       
    assign dcsr_mux_out              = dcsr_mux_sel ? dcsr_mux_input_1 : dcsr_mux_input_0;








    // updating and writing in dcsr Register
    always @(posedge clk_i or negedge reset_i) begin
        if(!reset_i) begin
            dcsr_reg            <=  RESET_VALUE_OF_DCSR; 
            dpc_reg             <=  0;
            dscratch0_reg       <=  0;
        end
        else begin
            dcsr_reg            <=  dcsr_mux_out; 
            dpc_reg             <=  dpc_mux_out;
            dscratch0_reg       <=  dscratch0_mux_out;
        end
    
    end





    /////////////////////////////////////////////
    // ************** Outputs *************** //
    ///////////////////////////////////////////


    assign DSP_dcsr_step_o              = dcsr_reg.step;
    assign DSP_dscratch_reg0_o           = dscratch0_reg;
    assign DSP_dcsr_ebreakm_o           = dcsr_reg.ebreakm;
    assign dm_reg_rd_wr_data_io         = read_dpc ? dpc_reg : 
                                          read_dcsr ? dcsr_reg : 
                                          32'bz;

endmodule
