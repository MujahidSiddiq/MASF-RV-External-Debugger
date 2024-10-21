`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2024 05:04:35 PM
// Design Name: 
// Module Name: HART
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
`include "HART_Header.svh"


module HART (
    input  logic clk_i,            
    input  logic reset_i,

    // Core
    input  logic            core_inst_comp_i,    
    input  logic [31:0]     core_pc_to_dpc_i,
    output logic [31:0]     core_dpc_for_pc_o,
    output logic            core_halt_o,     
    output logic            core_resuming_o,

    // DM
    input  logic            dm_halt_req_i,
    input  logic            dm_rd_wr_en_i, 
    input  logic            dm_rd_wr_i,
    input  logic [15:0]     dm_rd_wr_address_i,
    inout  logic [31:0]     dm_rd_wr_data_io,
    output logic            dm_stepping_o, 
    output logic            dm_first_step_exec_o,
    output logic            dm_halt_ack_o, 
    output logic            dm_resume_ack_o
    );


    type_states_dmode_e current_state, next_state; // initiate states
    type_dmode_reg_dcsr_e dcsr_reg;  // initiate dcsr register

    // logic [31:0] core_dpc_io;


    logic                   stepping;
    logic                   first_step_exec;
    logic                   reg_access;
    logic [2:0]             cause;
    logic                   wire_address_dcsr_en;
    logic                   dcsr_data_mux_sel;
    logic [31:0]            dcsr_data_mux_out;
    logic                   resuming;
    logic                   resume_ack;
    logic                   halt_ack;
    logic                   dpc_en;
    logic [31:0]            dpc_mux_o;




    assign wire_address_dcsr_en      = ( dm_rd_wr_address_i == Dcsr ) & (dm_rd_wr_en_i);
    assign dcsr_data_mux_sel         = ( wire_address_dcsr_en & dm_rd_wr_i ) & (reg_access);
    assign dcsr_data_mux_out         = dcsr_data_mux_sel ? dm_rd_wr_data_io : ( ( {23'd0, cause, 6'd0} ) | (dcsr_reg) );
    assign halt_ack                  = dm_halt_req_i & core_inst_comp_i;
    assign dpc_mux_o                 = (dm_halt_req_i & dpc_en) ? core_pc_to_dpc_i : dpc_reg; 


    // value for updating dpc
    // dpc_mux_o

    



    /////////////////////////////////////////////
    // **** inputs for state transitions **** //
    ///////////////////////////////////////////

    always_comb begin
        // Default next state is the current state
        next_state = current_state;

        case (current_state)
            NORMAL_EXEC: begin
                
                if (halt_ack) begin
                    next_state = DEBUG_MODE; 
                end
            end

            DEBUG_MODE: begin
              
            
                if (!dm_halt_req_i) begin
                    next_state = HART_RESUMING;
                end
                else if (dcsr_reg.step) begin
                    next_state = FIRST_STEP_EXEC;
                end
            end

            HART_RESUMING: begin
                    next_state = NORMAL_EXEC;
            end

            FIRST_STEP_EXEC: begin    
                    next_state = WAITING_FOR_I_COMP; 
            end


            WAITING_FOR_I_COMP: begin

                if (halt_ack) begin
                    next_state = STEPPING;
                end
            
            end

            STEPPING: begin
                if (!dcsr_reg.step) begin
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
                stepping            = 0;
                first_step_exec     = 0;
                cause               = 0;
                reg_access          = 0;
                resuming            = 0;
                resume_ack          = 0;
                dpc_en              = 1;
            
            end

            DEBUG_MODE: begin
                stepping            = 0;
                first_step_exec     = 0;
                cause               = 3;
                reg_access          = 1;
                resuming            = 0;
                resume_ack          = 0;
                dpc_en              = 0;

            end

            HART_RESUMING: begin
                stepping            = 0;
                first_step_exec     = 0;
                cause               = 3;
                reg_access          = 1;
                resuming            = 1;
                resume_ack          = 1;
                dpc_en              = 0;
            end


            FIRST_STEP_EXEC: begin
                stepping            = 0;
                first_step_exec     = 1;
                cause               = 4;
                reg_access          = 0;
                resuming            = 0;
                resume_ack          = 0;
                dpc_en              = 0;
            
            end

            WAITING_FOR_I_COMP: begin
                stepping            = 0;
                first_step_exec     = 1;
                cause               = 4;
                reg_access          = 0;
                resuming            = 0;
                resume_ack          = 0;
                dpc_en              = 0;
            end

            STEPPING: begin
                stepping            = 1;
                first_step_exec     = 0;
                cause               = 4;
                reg_access          = 1;
                resuming            = 0;
                resume_ack          = 0;
                dpc_en              = 0;
            end

            default: begin
                stepping            = 0;
                first_step_exec     = 0;
                cause               = 0;
                reg_access          = 0;
                resuming            = 0;
                resume_ack          = 0;
                dpc_en              = 1;
            
            end
        endcase
    end


    // updating and writing in dcsr Register
    always @(posedge clk_i) begin
    
        dcsr_reg    <=  dcsr_data_mux_out; 
        dpc_reg     <=  dpc_mux_o;
    
    end

    /////////////////////////////////////////////
    // ************** Outputs *************** //
    ///////////////////////////////////////////

    assign dm_first_step_exec_o     = first_step_exec;
    assign dm_stepping_o            = stepping;
    assign dm_rd_wr_data_io         = ( ((!dm_rd_wr_i)&(wire_address_dcsr_en)) & (reg_access) ) ? dcsr_reg : 32'bz ;
    assign dm_halt_ack_o            = halt_ack;
    assign dm_resume_ack_o          = resume_ack;
    assign core_resuming_o          = resuming;
    assign core_halt_o              = dm_halt_req_i;
    assign core_dpc_for_pc_o        = resuming ? dpc_reg : 32'bz;  // value outgoing from dpc

endmodule

