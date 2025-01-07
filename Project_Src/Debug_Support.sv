`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2024 09:38:22 AM
// Design Name: 
// Module Name: Debug_Support
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
`include "Debug_Support_Header.svh"

module Debug_Support(
                        input logic clk_i,
                        input logic reset_i,
                        
                        // Pipeline
                        input logic [31:0] Pipeline_PC_i,
                        input logic Pipeline_inst_comp_i,
                        output logic Pipeline_halt_active_o,
                        output logic Pipeline_reset_stages_o,
                        
                        // Debug CSR signals
                        output logic CSRs_reg_access_o,            // Debug CSR register access signal
                        output logic CSRs_status_reset_o,          // Debug CSR status reset signal
                        output logic [1:0] CSRs_cause_control_o,   // Debug CSR cause/control signal
                        input logic [31:0] CSRs_dscratch_reg0_i, // Debug CSR dscratch register output
                        input logic CSRs_dcsr_step_i,             // Debug CSR step output
                        input logic CSRs_dcsr_ebreakm_i,          // Debug CSR ebreakm output

                        // DM Interface signals
                        input  logic dm_halt_req_i,                 // DM halt request input
                        output logic dm_halt_ack_o,                // DM halt acknowledge output
                        output logic dm_resume_ack_o,              // DM resume acknowledge output
                        output logic dm_ebreak_o,                  // DM ebreak signal output
                        output logic dm_step_exec_o                // DM step execute signal output
                    

);





    type_states_dmode_e current_state, next_state; // initiate states




    logic                   step_exec;
    logic                   reg_access;
    logic [2:0]             cause_control;
    logic                   status_reset;
    logic                   ebreak_op_en;
    logic                   reset_stages;
    logic                   pc_at_ebreak_detect;
    logic                   resume_ack;
 //   logic [31:0]            dpc_mux_out;
  //  logic                   read_dpc;
    logic                   ebreak;
    logic                   halt_active;
    logic                   halt_ack;
 //   logic                   dscratch0_mux_sel;
 //   logic [31:0]            dscratch0_mux_out;
 //   logic                   wire_address_dcsr_en;
 //   logic [31:0]            dcsr_mux_out;
 //   logic                   dcsr_mux_sel;
 //   logic [31:0]            dcsr_mux_input_1;
 //   logic [31:0]            dcsr_mux_input_0;
 //   logic                   read_dcsr;
 //   logic [31:0]            reset_control_of_dcsr;
 //   logic [2:0]             cause;


    assign pc_at_ebreak_detect       = (Pipeline_PC_i == CSRs_dscratch_reg0_i);
    assign ebreak                    = pc_at_ebreak_detect & ebreak_op_en;
    assign halt_active               = ebreak | dm_halt_req_i;
    assign halt_ack                  = (reset_stages) | ( Pipeline_inst_comp_i & halt_active);








    /////////////////////////////////////////////
    // **** inputs for state transitions **** //
    ///////////////////////////////////////////

    always_comb begin
        // Default next state is the current state
        next_state = current_state;

        case (current_state)
            NORMAL_EXEC: begin
                
                if (dm_halt_req_i) begin
                    next_state = WAIT_FOR_ACK; 
                end
            end

            WAIT_FOR_ACK: begin
                
                if (halt_ack) begin
                    next_state = DEBUG_MODE; 
                end
            end

            DEBUG_MODE: begin
              
            
                if (!dm_halt_req_i) begin
                    next_state = PPL_RESUMING;
                end
                else if (CSRs_dcsr_step_i) begin
                    next_state = STEP_EXEC;
                end
                else if (CSRs_dcsr_ebreakm_i) begin
                    next_state = EBREAK;
                end
            end

            PPL_RESUMING: begin
                    next_state = NORMAL_EXEC;
            end

            STEP_EXEC: begin    
                    next_state = WAIT_FOR_I_COMP; 
            end


            WAIT_FOR_I_COMP: begin

                if (halt_ack) begin
                    next_state = DEBUG_MODE;
                end
            
            end

            EBREAK: begin

                if (!dm_halt_req_i) begin
                    next_state = RES_FOR_EBREAK;
                end
            
            end

            RES_FOR_EBREAK: begin

                if (pc_at_ebreak_detect & halt_ack) begin
                    next_state = DEBUG_MODE;
                end
            
            end

            default: begin
                    next_state = NORMAL_EXEC; // Default to normal execution
            end
        endcase
    end



    /////////////////////////////////////////////
    // Sequential logic to transition states  //
    ///////////////////////////////////////////

    always_ff @(posedge clk_i or negedge reset_i) begin
        if (!reset_i) begin
            current_state <= NORMAL_EXEC; // Start in Normal Execution state after reset
        end
        else begin
            current_state <= next_state; // Move to the next state
        end
    end



    /////////////////////////////////////////////
    // ***  outputs for state transitions *** //
    ///////////////////////////////////////////

    always_comb begin
    
        case (current_state)
            NORMAL_EXEC: begin
                step_exec           = 0;
                cause_control       = 2'b00;
                reg_access          = 0;
                resume_ack          = 0;
                status_reset        = 0;
                ebreak_op_en        = 0;
                reset_stages        = 0; 
            
            end

            WAIT_FOR_ACK: begin
                step_exec           = 0;
                cause_control       = 2'b10;
                reg_access          = 0;
                resume_ack          = 0;
                status_reset        = 0;
                ebreak_op_en        = 0;
                reset_stages        = 1; 
            
            end

            DEBUG_MODE: begin
                step_exec           = 0;
                cause_control       = 2'b00;
                reg_access          = 1;
                resume_ack          = 0;
                status_reset        = 0;
                ebreak_op_en        = 0;
                reset_stages        = 0; 

            end

            PPL_RESUMING: begin
                step_exec           = 0;
                cause_control       = 2'b00;
                reg_access          = 0;
                resume_ack          = 1;
                status_reset        = 1;
                ebreak_op_en        = 0;
                reset_stages        = 0;
            end


            STEP_EXEC: begin
                step_exec           = 1;
                cause_control       = 2'b01;
                reg_access          = 0;
                resume_ack          = 0;
                status_reset        = 0;
                ebreak_op_en        = 0;
                reset_stages        = 0;
            
            end

            WAIT_FOR_I_COMP: begin
                step_exec           = 1;
                cause_control       = 2'b01;
                reg_access          = 0;
                resume_ack          = 0;
                status_reset        = 0;
                ebreak_op_en        = 0;
                reset_stages        = 0;
            end

            EBREAK: begin
                step_exec           = 0;
                cause_control       = 2'b11;
                reg_access          = 0;
                resume_ack          = 0;
                status_reset        = 0;
                ebreak_op_en        = 1;
                reset_stages        = 0;
            end 

            RES_FOR_EBREAK: begin
                step_exec           = 0;
                cause_control       = 2'b11;
                reg_access          = 0;
                resume_ack          = 1;
                status_reset        = 0;
                ebreak_op_en        = 1;
                reset_stages        = 0;
            end

            default: begin
                step_exec           = 0;
                cause_control       = 2'b00;
                reg_access          = 0;
                resume_ack          = 0;
                status_reset        = 0;
                ebreak_op_en        = 0;
                reset_stages        = 0; 
            
            end
        endcase
    end






    /////////////////////////////////////////////
    // ************** Outputs *************** //
    ///////////////////////////////////////////



    assign dm_ebreak_o              = ebreak;
    assign dm_step_exec_o           = step_exec;
    assign Pipeline_reset_stages_o  = reset_stages;
    assign dm_resume_ack_o          = resume_ack;
    assign Pipeline_halt_active_o   = halt_active;
    assign dm_halt_ack_o            = halt_ack;
    assign CSRs_reg_access_o        = reg_access;
    assign CSRs_status_reset_o      = status_reset;
    assign CSRs_cause_control_o     = cause_control;




endmodule
