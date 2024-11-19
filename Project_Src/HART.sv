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

    // Pipeline
    input  logic            pipeline_inst_comp_i,    
    input  logic [31:0]     pipeline_pc_i,
    output logic            pipeline_halt_active_o, 
    output logic            pipeline_reset_stages_o,    


    // DM
    input  logic            dm_halt_req_i,
    input  logic            dm_rd_wr_en_i, 
    input  logic            dm_rd_wr_i,
    input  logic [15:0]     dm_rd_wr_address_i,
    inout  logic [31:0]     dm_rd_wr_data_io,
    output logic            dm_ebreak_o, 
    output logic            dm_step_exec_o,
    output logic            dm_halt_ack_o, 
    output logic            dm_resume_ack_o
    );

    // Define the writable mask 
    localparam logic [31:0] WRITABLE_MASK_DCSR = 32'h0005DF37;  
    // Define the fixed-zero mask 
    localparam logic [31:0] FIXED_ZERO_MASK_DCSR = 32'h08F44000; 

    localparam logic [31:0] RESET_VALUE_OF_DCSR = 32'h00000003;


    type_states_dmode_e current_state, next_state; // initiate states
    type_dmode_reg_dcsr_e dcsr_reg;  // initiate dcsr register
    logic [31:0] dpc_reg, dscratch0_reg;



    logic                   step_exec;
    logic                   reg_access;
    logic [2:0]             cause_control;
    logic                   status_reset;
    logic                   ebreak_op_en;
    logic                   reset_stages;
    logic                   pc_at_ebreak_detect;
    logic                   resume_ack;
    logic [31:0]            dpc_mux_out;
    logic                   read_dpc;
    logic                   ebreak;
    logic                   halt_active;
    logic                   halt_ack;
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



    assign dpc_mux_out               = (reg_access) ? pipeline_pc_i : dpc_reg; 
    assign read_dpc                  = (reg_access) & ( (dm_rd_wr_address_i[11:0] == Dpc ) & (!dm_rd_wr_i) );
    assign pc_at_ebreak_detect       = (pipeline_pc_i == dscratch0_reg);
    assign ebreak                    = pc_at_ebreak_detect & ebreak_op_en;
    assign halt_active               = ebreak | dm_halt_req_i;
    assign halt_ack                  = (reset_stages) | ( pipeline_inst_comp_i & halt_active);
    assign dscratch0_mux_sel         = (reg_access) & ( ((dm_rd_wr_address_i[11:0] == Dscratch0) & (dm_rd_wr_en_i)) & (dm_rd_wr_i) );
    assign dscratch0_mux_out         = dscratch0_mux_sel ? dm_rd_wr_data_io : dscratch0_reg;
    assign wire_address_dcsr_en      = ( dm_rd_wr_address_i[11:0] == Dcsr ) & (dm_rd_wr_en_i);
    assign dcsr_mux_sel              = ( wire_address_dcsr_en & dm_rd_wr_i ) & (reg_access);
    assign read_dcsr                 = (reg_access) & ( (!dm_rd_wr_i)&(wire_address_dcsr_en) );
    assign dcsr_mux_input_1          = ( dcsr_reg & (~WRITABLE_MASK_DCSR) 
                                                  & (~FIXED_ZERO_MASK_DCSR) )
                                                  | (dm_rd_wr_data_io & WRITABLE_MASK_DCSR) ;  
    assign cause                     = (cause_control == 2'b00) ? dcsr_reg.cause :
                                       (cause_control == 2'b01) ? 3'b100 :
                                       (cause_control == 2'b10) ? 3'b011 : 3'b001;
    assign reset_control_of_dcsr     = (dcsr_reg) & (~WRITABLE_MASK_DCSR)
                                                  | ( (32'(cause) << 6) & (FIXED_ZERO_MASK_DCSR) );
    assign dcsr_mux_input_0          = status_reset ? RESET_VALUE_OF_DCSR : reset_control_of_dcsr;                                       
    assign dcsr_mux_out              = dcsr_mux_sel ? dcsr_mux_input_1 : dcsr_mux_input_0;






    /////////////////////////////////////////////
    // **** inputs for state transitions **** //
    ///////////////////////////////////////////

    always_comb begin
        // Default next state is the current state
        next_state = current_state;

        case (current_state)
            NORMAL_EXEC: begin
                
                if (dm_halt_req_i) begin
                    next_state = WAITING_FOR_ACK; 
                end
            end

            WAITING_FOR_ACK: begin
                
                if (halt_ack) begin
                    next_state = DEBUG_MODE; 
                end
            end

            DEBUG_MODE: begin
              
            
                if (!dm_halt_req_i) begin
                    next_state = HART_RESUMING;
                end
                else if (dcsr_reg.step) begin
                    next_state = STEP_EXEC;
                end
                else if (dcsr_reg.ebreakm) begin
                    next_state = EBREAK;
                end
            end

            HART_RESUMING: begin
                    next_state = NORMAL_EXEC;
            end

            STEP_EXEC: begin    
                    next_state = WAITING_FOR_I_COMP; 
            end


            WAITING_FOR_I_COMP: begin

                if (halt_ack) begin
                    next_state = DEBUG_MODE;
                end
            
            end

            EBREAK: begin

                if (!dm_halt_req_i) begin
                    next_state = RESUME_FOR_EBREAK;
                end
            
            end

            RESUME_FOR_EBREAK: begin

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

            WAITING_FOR_ACK: begin
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

            HART_RESUMING: begin
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

            WAITING_FOR_I_COMP: begin
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

            RESUME_FOR_EBREAK: begin
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



    assign dm_ebreak_o     = ebreak;
    assign dm_step_exec_o           = step_exec;
    assign pipeline_reset_stages_o  = reset_stages;
    assign dm_resume_ack_o          = resume_ack;
    assign pipeline_halt_active_o   = halt_active;
    assign dm_halt_ack_o            = halt_ack;
    assign dm_rd_wr_data_io         = read_dpc ? dpc_reg : 
                                      read_dcsr ? dcsr_reg : 
                                      32'bz;


endmodule

