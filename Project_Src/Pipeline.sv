`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2024 11:41:52 AM
// Design Name: 
// Module Name: PLP_3_Stages
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


module Pipeline( input logic clk,reset,
                 output logic ht_inst_comp_o,
                 output logic [31:0] ht_pc_o,
                 input logic ht_halt_active_i,
                 input logic ht_reset_stages_i
                //  input logic ht_ebreak_i
                    // output logic [31:0] current_rd_data,
                    // output logic [31:0] current_mem_data

    );
    localparam logic [31:0] EBREAK = 32'h00000013;
    logic [31:0] pc_plus_4, ALU_result, ALU_result_3, pc_new, pc, instruction, IR, pc_2, pc_3, immediate, data_rd, data_rs1, data_rs2,  data_A, data_B, W_Data, IR_3, mem_out, pc_3_plus4;
    logic br_taken, reg_wrMW, sel_A, sel_B, Mem_read, Mem_write, Mem_R, Mem_W, reg_WEn;
    logic [4:0] addr_rs1,addr_rs2,addr_rd;
    logic [2:0] br_type;
    logic [3:0] ALU_op;
    logic [1:0] WB_sel_MW;  
    logic  For_A, For_B, Stall, Stall_MW, Flush;
    logic [31:0] d_rs1, d_rs2;
    /////////////////
    // for debgger //
    ////////////////

    logic [31:0] M_inst;
    assign instruction = ht_halt_active_i ? EBREAK : M_inst;
    
    logic stage_2, stage_3;
    assign stage_2 = ( ALU_op == 4'b1111);
    
    // assign stage_3 = (WB_sel_MW == 2'b11) & ( (!Mem_read) & (!Mem_write) ) ;
    logic no_mem_access;
    logic WB_mux_11_true;
    assign no_mem_access = (!Mem_read) & (!Mem_write);
    assign WB_mux_11_true = (WB_sel_MW == 2'b11);
    assign stage_3 = WB_mux_11_true & no_mem_access;

    
    assign ht_inst_comp_o = stage_2 & stage_3;

    
    
   
                                    
                                    
    logic [1:0] WB_sel;
    
    assign addr_rs1 = IR[19:15];
    assign addr_rs2 = IR[24:20];
    assign addr_rd = IR_3[11:7];
    ////////////////////////
    // related to debugger//
    ///////////////////////
    assign ht_pc_o = pc;
    
    ProgramCounter Program_Counter( .pc_new(pc_new),
                                    .clk(clk), 
                                    .reset(reset), 
                                    .pc(pc),
                                    .Stall(Stall),
                                    .halt_active(ht_halt_active_i),
                                    .reset_stages(ht_reset_stages_i)
                                    );
                                    
    Plus_4 Plus4_for_P_counter(     .in(pc),
                                    .out(pc_plus_4)
                                    );
                                    
    mux_2x1 Mux_PC(                 .select(br_taken),
                                    .data0(pc_plus_4),
                                    .data1(ALU_result),
                                    .out(pc_new)
                                    );
                                    
    Instruction_Memory Inst_Memory( .pc(pc),
                                    .instruction(M_inst)
                                    );   
    
    IR_2nd_stage IR_2nd_Stage(       .clk(clk),
                                     .in(instruction),
                                     .out(IR),
                                     .Flush(Flush),
                                     .Stall(Stall),
                                     .reset_stages(ht_reset_stages_i)
                                     );      
                                     
 /*   uncond_str_element IR_3rd_Stage( .clk(clk),
                                     .in(IR),
                                     .out(IR_3),
                                     .Stall(Stall_MW)
                                     );   */

    IR_3rd_stage IR_3rd_stage(       .clk(clk),
                                     .in(IR),
                                     .out(IR_3),
                                     .reset_stages(ht_reset_stages_i)
                                     
                                     );
   
   uncond_str_element PC_2nd_Stage(  .clk(clk),
                                     .in(pc),
                                     .out(pc_2),
                                     .Stall(Stall),
                                     .reset_stages(ht_reset_stages_i)
                                     );  
   
   imm_generator Imm_Generator(      .instruction(IR),
                                     .immediate(immediate)
                                     );  
                                     
   
   Reg_File Register_File(           .addr_rs1(addr_rs1),
                                     .addr_rs2(addr_rs2),
                                     .addr_rd(addr_rd),
                                     .reg_WEn(reg_wrMW),
                                     .clk(clk),
                                     .data_rd(data_rd),
                                     .data_rs1(d_rs1),
                                     .data_rs2(d_rs2)
                                   //  .current_rd_data(current_rd_data)
                                     );    
                                     
    mux_2x1 MUX_Data_A(              .select(sel_A),
                                     .data0(data_rs1),
                                     .data1(pc_2),
                                     .out(data_A)
                                     ); 
                                     
   mux_2x1 MUX_Data_B(              .select(sel_B),
                                     .data0(data_rs2),
                                     .data1(immediate),
                                     .out(data_B)
                                     );      
                                     
    branch_comp Branch_Comp(         .num1(data_rs1),
                                     .num2(data_rs2),
                                     .br_type(br_type),
                                     .br_taken(br_taken)
                                     );  
                                     
    ALU ALU(                         .ALU_op(ALU_op),
                                     .alu_data1(data_A),
                                     .alu_data2(data_B),
                                     .ALU_result(ALU_result)
                                     ); 
                                     
    uncond_str_element PC_3rd_Stage(  .clk(clk),
                                     .in(pc_2),
                                     .out(pc_3),
                                     .Stall(Stall),
                                     .reset_stages(ht_reset_stages_i)
                                     );    
                                     
    uncond_str_element ALU_3rd_Stage(  .clk(clk),
                                     .in(ALU_result),
                                     .out(ALU_result_3),
                                     .Stall(Stall),
                                     .reset_stages(ht_reset_stages_i)
                                     );                                                                    
                                         
    uncond_str_element WD_3rd_Stage(  .clk(clk),
                                     .in(data_rs2),
                                     .out(W_Data),
                                     .Stall(Stall),
                                     .reset_stages(ht_reset_stages_i)
                                     );   
                                     
                                     
    Data_Memory Data_Memory(         .clk(clk),
                                     .Mem_read(Mem_read),
                                     .Mem_write(Mem_write),
                                     .mem_addr(ALU_result_3),
                                     .write_data(W_Data),
                                     .mem_out(mem_out)
                                  //   .current_mem_data(current_mem_data)
                                     );    
                                     
    mux_3x1 WB_Mux(                  .select(WB_sel_MW),
                                     .data0(mem_out),
                                     .data1(ALU_result_3),
                                     .data2(pc_3_plus4),
                                     .out(data_rd)
                                     );  
                                     
    Plus_4 Plus4_for_WB(            .in(pc_3),
                                    .out(pc_3_plus4) 
                                    );    
                                    
    Control_Unit Control_Unit(      .instruction(IR),
                                    .ALU_op(ALU_op),
                                    .A_sel(sel_A),
                                    .B_sel(sel_B),
                                    .Br_type(br_type),
                                    .reg_WEn(reg_WEn),
                                    .Mem_R(Mem_R),
                                    .Mem_W(Mem_W),
                                    .WB_sel(WB_sel)
                                    );
                                        
                                        
     Control Control(               .reg_wrMW(reg_wrMW),
                                    .Mem_read(Mem_read),
                                    .Mem_write(Mem_write),
                                    .WB_sel_MW(WB_sel_MW),
                                    .reg_WEn(reg_WEn),
                                    .Mem_R(Mem_R),
                                    .Mem_W(Mem_W),
                                    .WB_sel(WB_sel),
                                    .clk(clk),
                                    .Stall(Stall),
                                    .reset_stages(ht_reset_stages_i)
                                    );  
    FSU Forward_Stall_Unit(         .IR(IR),
                                    .IR_3(IR_3),
                                    .reg_wrMW(reg_wrMW),
                                    .br_taken(br_taken),
                                    .Stall(Stall),
                                   // .Stall_MW(Stall_MW),
                                    .Flush(Flush),
                                    .For_A(For_A),
                                    .For_B(For_B)
                                   // .WB_sel(WB_sel_MW)
                                    ); 
                                    
    mux_2x1 MUX_For_A(               .select(For_A),
                                     .data0(d_rs1),
                                     .data1(ALU_result_3),
                                     .out(data_rs1)
                                     );  
    mux_2x1 MUX_For_B(               .select(For_B),
                                     .data0(d_rs2),
                                     .data1(ALU_result_3),
                                     .out(data_rs2)
                                     );                                                                    
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
endmodule
