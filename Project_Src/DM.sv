`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2024 03:18:07 PM
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
    input logic                 dmi_resp_ready_i,  // new no need to use again check it
    input logic                 dmi_hardreset_i, // new
   

    
    // DM response to DMI signals
    output logic                dmi_req_ready_o, 
    output logic                dmi_resp_valid_o,
    output logic [31:0]         dmi_resp_data_o,
  //  output logic [1:0]          dmi_rsp_op_o,
    output logic                dmi_resp_error_o,   // new  

    // Hardware-Thread
    input  logic                core_halt_ack_i, 
    input  logic                core_resume_ack_i,
    input  logic                core_ebreak_i, 
    input  logic                core_step_exec_i,
    inout  logic [31:0]         core_rd_wr_data_io,
    output logic                core_halt_req_o,
    output logic                core_rd_wr_en_o, 
    output logic                core_rd_wr_o,
    output logic [15:0]         core_rd_wr_address_o,
    
    
    
    // Data Memory
    output logic                Mem_rd_en_o,
    output logic [31:0]         Mem_rd_address_o
    


    );

    parameter logic [1:0]           dmi_read        =   2'b01;
    parameter logic [1:0]           dmi_write       =   2'b10;

    type_dm_reg_dmcontrol_e         dmcontrol_reg;                  // Initiate dmcontrol_reg
    type_dm_reg_dmstatus_e          dmstatus_reg;                   // initiate dmstatus_reg
    type_dm_reg_abstractcs_e        abstractcs_reg;                 // initiate abstractcs_reg
    type_dm_reg_command_e           command;                    // initiate command_reg
    type_states_hart_e              current_state, next_state;      // initiate states




    logic               halt_req;
    logic               all_halted;
    logic               all_running;
    logic               reset_dmcontrol;
    logic               reset_abstractcs_busy;
    logic [31:0]        dmcontrol_reset_value; 
    // logic [2:0]         abstractcs_cmderr;
  //  logic               abstractcs_busy;
    logic               wire_abstractcs_busy_cleared;
  //  logic               wire_dmi_req_valid_write;
    logic               wire_command_address_true;
    logic               wire_dmcontrol_address_true;    
    logic               request_for_command;
    logic               valid_command;
    logic               command_data_mux_sel;
    logic [31:0]        command_data_mux_out;
    logic               dmcontrol_data_mux_sel;
    logic [31:0]        dmcontrol_data_mux_out;
    logic [31:0]        dmcontrol_reset_value_mux_out;
  //  logic               wire_dmi_req_valid_read;
    logic               wire_dmstatus_address_true;
    logic               wire_abstractcs_address_true;
    logic               rsp_dmstatus_mux_sel;
    logic [31:0]        rsp_dmstatus_mux_out;
    logic               rsp_abstractcs_mux_sel;
    logic [31:0]        rsp_abstractcs_mux_out;
    logic               wire_dmi_address_access_data0;
    logic               wire_dmi_address_access_data1;
    logic               rsp_data0_mux_sel;
    logic [31:0]        rsp_data0_mux_out;
    logic               reg_data0_mux_sel;
    logic [31:0]        reg_data0_mux_out;
    logic               dmi_data0_mux_sel;
    logic [31:0]        dmi_data0_mux_out;
    logic               resume_req;
    logic               rd_wr_en;
    logic               Mem_rd_en;
    logic [31:0]        Mem_rd_data0_mux_out;
    logic [31:0]        dmi_data1_mux_out;
    logic               dmi_data1_mux_sel;
    logic               command_written;
    logic               abstractcs_busy;
    logic               dm_reg_write;
    logic [31:0]        resp_data;

    // signals for DMI_RRC


    logic               valid_reg_access_write;
    logic               access_dm_reg_write;
    logic               write_done_reg;
    logic               valid_reg_access_read;
    logic               read_done_reg;
    logic               writing_enable;
    logic               reset_write_done_reg;
    logic               reading_enable;
    logic               reset_read_done_reg;
    
    
    logic               write_done_reg_mux_out;
    logic               read_done_reg_mux_out;
    







    assign dmcontrol_reset_value                = {2'b0, dmcontrol_reg[29:0]}; 
    assign wire_abstractcs_busy_cleared         = !(abstractcs_reg.busy);
  //  assign wire_dmi_req_valid_write             = ( ( dmi_req_op_i == dmi_write ) & (dmi_req_valid_i)) ? 1 : 0;        
    assign wire_command_address_true            = dmi_req_address_i == Command;     ///////// *************    address of command checking
    assign wire_dmcontrol_address_true          = dmi_req_address_i == DMControl;
  //  assign request_for_command                  = wire_command_address_true & wire_dmi_req_valid_write;
    assign command_data_mux_sel                 = writing_enable & wire_command_address_true;
    assign command_data_mux_out                 = command_data_mux_sel ? dmi_req_data_i : command;
    assign dmcontrol_data_mux_sel               = (wire_dmcontrol_address_true) & writing_enable;
    assign dmcontrol_data_mux_out               = dmcontrol_data_mux_sel ? dmi_req_data_i : dmcontrol_reg;
    assign dmcontrol_reset_value_mux_out        = reset_dmcontrol ? dmcontrol_reset_value : dmcontrol_data_mux_out;
  //  assign wire_dmi_req_valid_read              = ( dmi_req_op_i == dmi_read ) & dmi_req_valid_i ;
    assign wire_dmstatus_address_true           = dmi_req_address_i == DMStatus;
    assign rsp_dmstatus_mux_sel                 = ( reading_enable ) & ( wire_dmstatus_address_true );
    assign rsp_dmstatus_mux_out                 = rsp_dmstatus_mux_sel ? dmstatus_reg : 32'd0 ;
    
    assign wire_abstractcs_address_true         = dmi_req_address_i == AbstractCS;
    assign rsp_abstractcs_mux_sel               = ( reading_enable ) & ( wire_abstractcs_address_true );
    assign rsp_abstractcs_mux_out               = rsp_abstractcs_mux_sel ? abstractcs_reg : rsp_dmstatus_mux_out;
    assign wire_dmi_address_access_data0        = ( dmi_req_address_i == Data0 );
    assign rsp_data0_mux_sel                    = reading_enable & wire_dmi_address_access_data0;
    assign rsp_data0_mux_out                    = rsp_data0_mux_sel ? data_reg[0] : rsp_abstractcs_mux_out;
    
    
    
    assign reg_data0_mux_sel                   = ( (!command.control.access_reg.write)&(abstractcs_reg.busy) ) & (command.control.access_reg.transfer) ;
    assign reg_data0_mux_out                   = reg_data0_mux_sel ? core_rd_wr_data_io : data_reg[0] ;
    assign dmi_data0_mux_sel                    = wire_dmi_address_access_data0 & writing_enable ;
    assign dmi_data0_mux_out                    = dmi_data0_mux_sel ? dmi_req_data_i : reg_data0_mux_out ;
    assign Mem_rd_data0_mux_out                = Mem_rd_en ? core_rd_wr_data_io : dmi_data0_mux_out;
    assign resume_req                           = ( dmcontrol_reg.haltreq & dmcontrol_reg.resumereq) ? 0 : dmcontrol_reg.resumereq;    
    assign wire_dmi_address_access_data1        = dmi_req_address_i == Data0;
    assign dmi_data1_mux_sel                    =  ( wire_dmi_address_access_data1 ) & ( writing_enable ) ;    
    assign dmi_data1_mux_out                    = dmi_data1_mux_sel ? dmi_req_data_i : data_reg[1];



    assign command_written                      = wire_command_address_true & write_done_reg;
    assign valid_command                        = command_written;
    
    assign abstractcs_busy                      = reset_abstractcs_busy ? 1'b0 : ( command_written ? 1'b1 : abstractcs_reg.busy );
    assign write_done_reg_mux_out               = reset_write_done_reg ? 1'b0 : ( writing_enable ? 1'b1 : write_done_reg );
    assign read_done_reg_mux_out               = reset_read_done_reg ? 1'b0 : ( reading_enable ? 1'b1 : read_done_reg );
    assign valid_reg_access_write               = wire_dmcontrol_address_true | wire_command_address_true | wire_dmi_address_access_data0 | wire_dmi_address_access_data1;
    assign valid_reg_access_read               = wire_dmstatus_address_true | wire_abstractcs_address_true | wire_dmi_address_access_data0;
    assign access_dm_reg_write                  = ( wire_dmi_address_access_data0 | wire_dmi_address_access_data1 ) ? ( current_state == HALTED ) : dm_reg_write;
    
    
    
    
    

    /////////////////////////////////////////////
    // **** inputs for state transitions **** //
    ///////////////////////////////////////////

    always_comb begin
        // Default next state is the current state
        next_state = current_state;

        case (current_state)
            NORMAL_EXECUTION: begin
                
                if ( (dmcontrol_reg.haltreq | core_ebreak_i ) & (dmcontrol_reg.dmactive) ) begin
                    next_state = HALTING; 
                end
            end

            HALTING: begin
            
            
                if (core_halt_ack_i) begin
                    next_state = HALTED;
                end
            end

            HALTED: begin
                
                if (resume_req | core_step_exec_i) begin
                    next_state = RESUMING; 
                end
                else if ((!command.cmdtype) & (valid_command)) begin
                    next_state = COMMAND_START;
                end
                else if (command.cmdtype == 8'h02) begin
                
                    next_state = ACCESS_MEM;     
                end
            end
            
            ACCESS_MEM: begin
            
                if (command.control.access_mem.write) begin          
                    next_state = COMMAND_DONE;           
                end
                
                else begin                   
                    next_state = READING_MEM;            
                end
            end

            READING_MEM: begin
                next_state = COMMAND_DONE;
            end
            RESUMING: begin
            
                if (core_step_exec_i) begin
                    next_state = HALTING;
                end
                else if ( (!core_step_exec_i) & (core_resume_ack_i)) begin
                    next_state = NORMAL_EXECUTION;
                end
            end

            COMMAND_START: begin
                if (command.control.access_reg.transfer) begin
                    next_state = COMMAND_TRANSFER;
                end
                else if ((!command.control.access_reg.transfer) & (!command.control.access_reg.postexec)) begin
                    next_state = COMMAND_DONE;
                end
            end

            COMMAND_TRANSFER: begin
                if (!command.control.access_reg.postexec) begin
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

    always_ff @(posedge clk_i or negedge reset_i or posedge dmi_hardreset_i) begin
        if (!reset_i) begin
            current_state       <=      NORMAL_EXECUTION; 
        end
        else if (dmi_hardreset_i) begin
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
           //     abstractcs_busy         = 0;
                // abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
                reset_abstractcs_busy   = 0;
                rd_wr_en                = 0;
                Mem_rd_en               = 0;
                dm_reg_write            = 1;
            
            end

            HALTING: begin
                halt_req                = 1;
                all_halted              = 0;
                all_running             = 0;
           //     abstractcs_busy         = 0;
                // abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
                reset_abstractcs_busy   = 0;
                rd_wr_en                = 0;
                Mem_rd_en               = 0;
                dm_reg_write            = 0;

            end

            HALTED: begin
                halt_req                = 1;
                all_halted              = 1;
                all_running             = 0;
           //     abstractcs_busy         = 0;
                // abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
                reset_abstractcs_busy   = 0;
                rd_wr_en                = 0;
                Mem_rd_en               = 0;
                dm_reg_write            = 1;
            
            end

            RESUMING: begin
                halt_req                = 0;
                all_halted              = 1;
                all_running             = 0;
           //     abstractcs_busy         = 0;
                // abstractcs_cmderr       = 0;
                reset_dmcontrol         = 1;
                reset_abstractcs_busy   = 0;
                rd_wr_en                = 0;
                Mem_rd_en               = 0;
                dm_reg_write            = 0;
            end

            COMMAND_START: begin
                halt_req                = 1;
                all_halted              = 1;
                all_running             = 0;
          //      abstractcs_busy         = 1;
                // abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
                reset_abstractcs_busy   = 0;
                rd_wr_en                = 0;
                Mem_rd_en               = 0;
                dm_reg_write            = 0;
            end

            COMMAND_TRANSFER: begin
                halt_req                = 1;
                all_halted              = 1;
                all_running             = 0;
          //      abstractcs_busy         = 1;
                // abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
                reset_abstractcs_busy   = 0;
                rd_wr_en                = 1;
                Mem_rd_en               = 0;
                dm_reg_write            = 0;
            end

            COMMAND_DONE: begin
                halt_req                = 1;
                all_halted              = 1;
                all_running             = 0;
         //       abstractcs_busy         = 1;
                // abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
                reset_abstractcs_busy   = 1;
                rd_wr_en                = 0;
                Mem_rd_en               = 0;
                dm_reg_write            = 0;
            end
            
            
            ACCESS_MEM: begin
                halt_req                = 1;
                all_halted              = 1;
                all_running             = 0;
          //      abstractcs_busy         = 1;
                // abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
                reset_abstractcs_busy   = 0;
                rd_wr_en                = 0;
                Mem_rd_en               = 0;
                dm_reg_write            = 0;
            end
            
            READING_MEM: begin
                halt_req                = 1;
                all_halted              = 1;
                all_running             = 0;
           //     abstractcs_busy         = 1;
                // abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
                reset_abstractcs_busy   = 0;
                rd_wr_en                = 0;
                Mem_rd_en               = 1;
                dm_reg_write            = 0;
            end


            default: begin
                halt_req                = 0;
                all_halted              = 0;
                all_running             = 1;
            //    abstractcs_busy         = 0;
                // abstractcs_cmderr       = 0;
                reset_dmcontrol         = 0;
                reset_abstractcs_busy   = 0;
                rd_wr_en                = 0;
                Mem_rd_en               = 0;
                dm_reg_write            = 0;
            end
        endcase
    end



// logic [31:0] concet_for_abstractcs;
// assign concet_for_abstractcs = 


    // updating Registers
    always @(posedge clk_i or negedge reset_i or posedge dmi_hardreset_i) begin

        if(!reset_i) begin 
            dmstatus_reg <= 0;
            abstractcs_reg <= 0;

        end
        else if(dmi_hardreset_i) begin 
            dmstatus_reg <= 0;
            abstractcs_reg <= 0;

        end
        else begin
    
            dmstatus_reg.allhalted              <=      all_halted;
            dmstatus_reg.allrunning             <=      all_running;
            dmstatus_reg.allresumeack           <=      core_resume_ack_i;
            abstractcs_reg.busy                 <=      abstractcs_busy;
            // abstractcs_reg.cmderr               <=      abstractcs_cmderr;  
            
            

        end

    
    end





    // ***************** DMI Write ****************

    always @(posedge clk_i or negedge reset_i or posedge dmi_hardreset_i) begin
        if(!reset_i) begin
            dmcontrol_reg                   <=      0;
            command                         <=      0;
            data_reg[0]                     <=      0;
            data_reg[1]                     <=      0;
            write_done_reg                  <=      0;
            read_done_reg                   <=      0;
            resp_data                       <=      0;
        end
        else if(dmi_hardreset_i) begin
            dmcontrol_reg                   <=      0;
            command                         <=      0;
            data_reg[0]                     <=      0;
            data_reg[1]                     <=      0;
            write_done_reg                  <=      0;
            read_done_reg                   <=      0;
            resp_data                       <=      0;
        end
        else begin

            dmcontrol_reg                   <=      dmcontrol_reset_value_mux_out;
            command                         <=      command_data_mux_out;
            data_reg[0]                     <=      Mem_rd_data0_mux_out ;
            data_reg[1]                     <=      dmi_data1_mux_out;  
            write_done_reg                  <=      write_done_reg_mux_out;
            read_done_reg                   <=      read_done_reg_mux_out;
            resp_data                       <=      rsp_data0_mux_out;

        end
    end




    // Instantiate DMI_RRC
    DMI_RRC dmi_rrc_inst        (
                                .clk_i                              (clk_i),
                                .reset_i                            (reset_i),
                                .dmi_req_valid_i                    (dmi_req_valid_i),
                                .dmi_req_op_i                       (dmi_req_op_i),
                                .dmi_hardreset_i                    (dmi_hardreset_i),
                                .valid_reg_access_write_i           (valid_reg_access_write),
                                .access_dm_reg_write_i              (access_dm_reg_write),
                                .write_done_reg_i                   (write_done_reg),
                                .valid_reg_access_read_i            (valid_reg_access_read),
                                .read_done_reg_i                    (read_done_reg),
                                .writing_enable_o                   (writing_enable),
                                .dmi_resp_valid_o                   (dmi_resp_valid_o),
                                .reset_write_done_reg_o             (reset_write_done_reg),
                                .dmi_resp_error_o                   (dmi_resp_error_o),
                                .reading_enable_o                   (reading_enable),
                                .reset_read_done_reg_o              (reset_read_done_reg),
                                .dmi_req_ready_o                    (dmi_req_ready_o)
                                );

    /////////////////////////////////////////////
    // ************** Outputs *************** //
    ///////////////////////////////////////////

    assign dmi_resp_data_o                   =       resp_data;
  //  assign dmi_resp_valid_o                  =   dmi_resp_valid   ;
  //  assign dmi_req_ready_o                  =    dmi_req_ready   ;
    assign core_rd_wr_o                       =       command.control.access_reg.write;
    assign core_rd_wr_address_o               =       command.control.access_reg.regno[15:0];
    assign core_rd_wr_data_io                 =       command.control.access_reg.write ? data_reg[0] : 32'bz;
    assign core_rd_wr_en_o                    =       rd_wr_en & command.control.access_reg.transfer;
    assign core_halt_req_o                    =       halt_req;
    assign Mem_rd_en_o                      =      Mem_rd_en;
    assign Mem_rd_address_o                 =       Mem_rd_en ? data_reg[1] : 32'bz;

endmodule
