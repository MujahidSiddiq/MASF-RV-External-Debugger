`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2024 05:02:33 PM
// Design Name: 
// Module Name: DM
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
`include "DM_Header.svh"
module DM (
    input  logic clk_i,               // Clock signal
    input  logic reset_i,

    // DMI Req to DM signals
    input  logic [1:0]          dmi_req_op_i,
    input  logic [31:0]         dmi_req_data_i,
    input  logic [6:0]          dmi_req_address_i,
    input  logic                dmi_req_valid_i,

    // DM response to DMI signals
    output logic                dmi_req_ready_o, 
    output logic                dmi_rsp_valid_o,
    output logic [31:0]         dmi_rsp_data_o,
    output logic [1:0]          dmi_rsp_op_o,

    // Hardware-Thread
    input  logic                ht_halt_ack_i, 
    input  logic                ht_resume_ack_i,
    input  logic                ht_stepping_i, 
    input  logic                ht_first_step_exec_i,
    inout  logic [31:0]         ht_rd_wr_data_io,
    output logic                ht_halt_req_o,
    output logic                ht_rd_wr_en_o, 
    output logic                ht_rd_wr_o,
    output logic [15:0]         ht_rd_wr_address_o
    


    );

    parameter logic [1:0]           dmi_read        =   2'b01;
    parameter logic [1:0]           dmi_write       =   2'b10;

    type_dm_reg_dmcontrol_e         dmcontrol_reg;                  // Initiate dmcontrol_reg
    type_dm_reg_dmstatus_e          dmstatus_reg;                   // initiate dmstatus_reg
    type_dm_reg_abstractcs_e        abstractcs_reg;                 // initiate abstractcs_reg
    type_dm_reg_command_e           command_reg;                    // initiate command_reg
    type_states_hart_e              current_state, next_state;      // initiate states




    logic               halt_req;
    logic               all_halted;
    logic               all_running;
    logic               reset_dmcontrol;
    logic [31:0]        dmcontrol_reset_value; 
    logic [2:0]         abstractcs_cmderr;
    logic               abstractcs_busy;
    logic               wire_abstractcs_busy_cleared;
    logic               wire_dmi_req_valid_write;
    logic               wire_command_address_true;
    logic               request_for_command;
    logic               valid_command;
    logic               command_data_mux_sel;
    logic [31:0]        command_data_mux_out;
    logic               dmcontrol_data_mux_sel;
    logic [31:0]        dmcontrol_data_mux_out;
    logic [31:0]        dmcontrol_reset_value_mux_out;
    logic               wire_dmi_req_valid_read;
    logic               rsp_dmstatus_mux_sel;
    logic [31:0]        rsp_dmstatus_mux_out;
    logic               rsp_abstractcs_mux_sel;
    logic [31:0]        rsp_abstractcs_mux_out;
    logic               wire_dmi_address_access_data0;
    logic               rsp_data0_mux_sel;
    logic [31:0]        rsp_data0_mux_out;
    logic               dcsr_data0_mux_sel;
    logic [31:0]        dcsr_data0_mux_out;
    logic               dmi_data0_mux_sel;
    logic [31:0]        dmi_data0_mux_out;
    logic               resume_req;





    assign dmcontrol_reset_value                = {2'b0, dmcontrol_reg[29:0]}; 
    assign wire_abstractcs_busy_cleared         = !(abstractcs_reg.busy);
    assign wire_dmi_req_valid_write             = ( ( dmi_req_op_i == dmi_write ) & (dmi_req_valid_i)) ? 1 : 0;        
    assign wire_command_address_true            = dmi_req_address_i == Command;     ///////// *************    address of command checking
    assign request_for_command                  = wire_command_address_true & wire_dmi_req_valid_write;
    assign command_data_mux_sel                 = ( (wire_dmi_req_valid_write) & (wire_command_address_true) ) & (wire_abstractcs_busy_cleared) ;
    assign command_data_mux_out                 = command_data_mux_sel ? dmi_req_data_i : command_reg;
    assign dmcontrol_data_mux_sel               = (dmi_req_address_i == DMControl) & wire_dmi_req_valid_write;
    assign dmcontrol_data_mux_out               = dmcontrol_data_mux_sel ? dmi_req_data_i : dmcontrol_reg;
    assign dmcontrol_reset_value_mux_out        = reset_dmcontrol ? dmcontrol_reset_value : dmcontrol_data_mux_out;
    assign wire_dmi_req_valid_read              = ( dmi_req_op_i == dmi_read ) & dmi_req_valid_i ;
    assign rsp_dmstatus_mux_sel                 = ( wire_dmi_req_valid_read ) & ( dmi_req_address_i == DMStatus );
    assign rsp_dmstatus_mux_out                 = rsp_dmstatus_mux_sel ? dmstatus_reg : 32'd0 ;
    assign rsp_abstractcs_mux_sel               = ( wire_dmi_req_valid_read ) & ( dmi_req_address_i == AbstractCS );
    assign rsp_abstractcs_mux_out               = rsp_abstractcs_mux_sel ? abstractcs_reg : rsp_dmstatus_mux_out;
    assign wire_dmi_address_access_data0        = ( dmi_req_address_i == Data0 );
    assign rsp_data0_mux_sel                    = ( wire_dmi_req_valid_read & wire_dmi_address_access_data0 ) & (wire_abstractcs_busy_cleared) ;
    assign rsp_data0_mux_out                    = rsp_data0_mux_sel ? data_reg[0] : rsp_abstractcs_mux_out;
    assign dcsr_data0_mux_sel                   = ( (!command_reg.write)&(abstractcs_reg.busy) ) & (command_reg.transfer) ;
    assign dcsr_data0_mux_out                   = dcsr_data0_mux_sel ? ht_rd_wr_data_io : data_reg[0] ;
    assign dmi_data0_mux_sel                    = ( wire_dmi_address_access_data0 & wire_dmi_req_valid_write ) & (wire_abstractcs_busy_cleared);
    assign dmi_data0_mux_out                    = dmi_data0_mux_sel ? dmi_req_data_i : dcsr_data0_mux_out ;
    assign resume_req                           = ( dmcontrol_reg.haltreq & dmcontrol_reg.resumereq) ? 0 : dmcontrol_reg.resumereq;







    /////////////////////////////////////////////
    // **** inputs for state transitions **** //
    ///////////////////////////////////////////

    always_comb begin
        // Default next state is the current state
        next_state = current_state;

        case (current_state)
            NORMAL_EXECUTION: begin
                
                if (dmcontrol_reg.haltreq & dmcontrol_reg.dmactive) begin
                    next_state = HALTING; 
                end
            end

            HALTING: begin
            
            
                if (ht_halt_ack_i) begin
                    next_state = HALTED;
                end
            end

            HALTED: begin
                
                if (resume_req | ht_first_step_exec_i) begin
                    next_state = RESUMING; 
                end
                else if ((!command_reg.cmdtype) & (valid_command)) begin
                    next_state = COMMAND_START;
                end
            
            end


            RESUMING: begin
            
                if (ht_stepping_i | ht_first_step_exec_i) begin
                    next_state = HALTING;
                end
                else if ((!ht_stepping_i) & (!ht_first_step_exec_i) & (ht_resume_ack_i)) begin
                    next_state = NORMAL_EXECUTION;
                end
            end

            COMMAND_START: begin
                if (command_reg.transfer) begin
                    next_state = COMMAND_TRANSFER;
                end
                else if ((!command_reg.transfer) & (!command_reg.postexec)) begin
                    next_state = COMMAND_DONE;
                end
            end

            COMMAND_TRANSFER: begin
                if (!command_reg.postexec) begin
                    next_state = COMMAND_DONE;
                end
            end

            COMMAND_DONE: begin
                    next_state = HALTED;
            end
            default: begin
                    next_state = NORMAL_EXECUTION; // Default to normal execution
            end
        endcase
    end



    /////////////////////////////////////////////
    // Sequential logic to transition states  //
    ///////////////////////////////////////////

    always_ff @(posedge clk_i or negedge reset_i) begin
        if (!reset_i) begin
            current_state       <=      NORMAL_EXECUTION; 
        end
        else begin
            current_state       <=      next_state; 
        end
    end



    /////////////////////////////////////////////
    // ***  outputs for state transitions *** //
    ///////////////////////////////////////////

    always_comb begin
    
        case (current_state)
            NORMAL_EXECUTION: begin

                halt_req                = 0;
                all_halted              = 0;
                all_running             = 1;
                abstractcs_busy         = 0;
                abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
            
            end

            HALTING: begin
                halt_req                = 1;
                all_halted              = 0;
                all_running             = 1;
                abstractcs_busy         = 0;
                abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
            end

            HALTED: begin
                halt_req                = 1;
                all_halted              = 1;
                all_running             = 0;
                abstractcs_busy         = 0;
                abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
            
            end

            RESUMING: begin
                halt_req                = 0;
                all_halted              = 1;
                all_running             = 0;
                abstractcs_busy         = 0;
                abstractcs_cmderr       = 0;
                reset_dmcontrol         = 1;
            end

            COMMAND_START: begin
                halt_req                = 1;
                all_halted              = 1;
                all_running             = 0;
                abstractcs_busy         = 1;
                abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
            end

            COMMAND_TRANSFER: begin
                halt_req                = 1;
                all_halted              = 1;
                all_running             = 0;
                abstractcs_busy         = 1;
                abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
            end

            COMMAND_DONE: begin
                halt_req                = 1;
                all_halted              = 1;
                all_running             = 0;
                abstractcs_busy         = 1;
                abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
            end


            default: begin
                halt_req                = 0;
                all_halted              = 0;
                all_running             = 1;
                abstractcs_busy         = 0;
                abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
            end
        endcase
    end





    // updating Registers
    always @(posedge clk_i) begin
    
        dmstatus_reg.allhalted              <=      all_halted;
        dmstatus_reg.allrunning             <=      all_running;
        dmstatus_reg.allresumeack           <=      ht_resume_ack_i;
        abstractcs_reg.busy                 <=      abstractcs_busy;
        abstractcs_reg.cmderr               <=      abstractcs_cmderr;  
        valid_command                       <=      request_for_command;

    
    end





    // ***************** DMI Write ****************

    always @(posedge clk_i or negedge reset_i) begin
        if(!reset_i) begin
            dmcontrol_reg                   <=      0;
            command_reg                     <=      0;
            data_reg[0]                     <=      0;
        end
        else begin

            dmcontrol_reg                   <=      dmcontrol_reset_value_mux_out;
            command_reg                     <=      command_data_mux_out;
            data_reg[0]                     <=      dmi_data0_mux_out;

        end
    end


    /////////////////////////////////////////////
    // ************** Outputs *************** //
    ///////////////////////////////////////////

    assign dmi_rsp_op_o                     =       dmi_req_op_i;
    assign dmi_rsp_data_o                   =       rsp_data0_mux_out;
    assign dmi_rsp_valid_o                  =       rsp_dmstatus_mux_sel;
    assign dmi_req_ready_o                  =       !rsp_dmstatus_mux_sel;
    assign ht_rd_wr_o                       =       command_reg.write;
    assign ht_rd_wr_address_o               =       command_reg.regno[15:0];
    assign ht_rd_wr_data_io                 =       command_reg.write ? data_reg[0] : 32'bz;
    assign ht_rd_wr_en_o                    =       abstractcs_reg.busy & command_reg.transfer;
    assign ht_halt_req_o                    =       halt_req;

endmodule

