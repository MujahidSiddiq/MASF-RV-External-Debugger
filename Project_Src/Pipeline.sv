`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2024 03:44:07 PM
// Design Name: 
// Module Name: Pipeline
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


module Pipeline(
            input  logic                clk_i,
            input  logic                reset_i,
            
            
            // Instruction Memory
            output  logic [31:0]         inst_mem_PC_o,
            input   logic [31:0]         inst_mem_M_inst_i,
            
            // GPRs
            input   logic [31:0]         gprs_data_rs1_i,
            input   logic [31:0]         gprs_data_rs2_i,
            output  logic [31:0]         gprs_data_rd_o,
            output  logic [4:0]          gprs_addr_rd_o,
            output  logic [4:0]          gprs_addr_rs1_o,
            output  logic [4:0]          gprs_addr_rs2_o,
            output  logic                gprs_reg_WEn_o,
            
            
            // CSRs
                 
            // Debug Support
            input   logic                DSP_halt_active_i,
            input   logic                DSP_reset_stages_i,
            output  logic                DSP_inst_comp_o,
  
            // Data Memory 
            input   logic [31:0]         Mem_rd_data_i,           // Mem_out
            output  logic                Mem_read_o,              // Mem_read
            output  logic                Mem_write_o,             // Mem_write
            output  logic [31:0]         Mem_address_o,           // Mem_address
            output  logic [31:0]         Mem_write_data_o         // write_data
   

    );
    
        localparam logic [31:0] EBREAK = 32'h00000013;
    logic [31:0] pc_plus_4, ALU_result, ALU_result_3, pc_new, pc, instruction, IR, pc_2, pc_3, immediate, data_rd, data_rs1, data_rs2,  data_A, data_B, W_Data, IR_3, mem_out, pc_3_plus4;
    logic br_taken, reg_wrMW, sel_A, sel_B, Mem_read, Mem_write, Mem_R, Mem_W, reg_WEn;
    //logic [4:0] addr_rs1,addr_rs2,addr_rd;
    logic [2:0] br_type;
    logic [3:0] ALU_op;
    logic [1:0] WB_sel_MW;  
    logic  For_A, For_B, Stall, Stall_MW, Flush;
    logic [31:0] d_rs1, d_rs2;
    /////////////////
    // for debgger //
    ////////////////

    assign inst_mem_PC_o = pc;
    //logic [31:0] M_inst;
    assign instruction = DSP_halt_active_i ? EBREAK : inst_mem_M_inst_i;
    
    logic stage_2, stage_3;
    assign stage_2 = ( ALU_op == 4'b1111);
    
    // assign stage_3 = (WB_sel_MW == 2'b11) & ( (!Mem_read) & (!Mem_write) ) ;
    logic no_mem_access;
    logic WB_mux_11_true;
    assign no_mem_access = (!Mem_read) & (!Mem_write);
    assign WB_mux_11_true = (WB_sel_MW == 2'b11);
    assign stage_3 = WB_mux_11_true & no_mem_access;

    
    assign DSP_inst_comp_o = stage_2 & stage_3;

    
    
   
                                    
                                    
    logic [1:0] WB_sel;
    
    assign gprs_addr_rs1_o = IR[19:15];
    assign gprs_addr_rs2_o = IR[24:20];
    assign gprs_addr_rd_o = IR_3[11:7];

    assign gprs_reg_WEn_o = reg_wrMW; 
    assign gprs_data_rd_o = data_rd;
    assign d_rs1 = gprs_data_rs1_i;
    assign d_rs2 = gprs_data_rs2_i;

    // Data Memory
    assign Mem_read_o = Mem_read;       
    assign Mem_write_o = Mem_write;     
    assign Mem_address_o = ALU_result_3;

    assign Mem_write_data_o = W_Data; 
    assign mem_out = Mem_rd_data_i;


    
        
    ////////////////////////
    // related to debugger//
    ///////////////////////
    assign inst_mem_PC_o = pc;
    
    ProgramCounter Program_Counter( .pc_new(pc_new),
                                    .clk(clk_i), 
                                    .reset(reset_i), 
                                    .pc(pc),
                                    .Stall(Stall),
                                    .halt_active(DSP_halt_active_i),
                                    .reset_stages(DSP_reset_stages_i)
                                    );
                                    
    Plus_4 Plus4_for_P_counter(     .in(pc),
                                    .out(pc_plus_4)
                                    );
                                    
    mux_2x1 Mux_PC(                 .select(br_taken),
                                    .data0(pc_plus_4),
                                    .data1(ALU_result),
                                    .out(pc_new)
                                    );
                                    
    
    
    // Instruction Memory
    
    IR_2nd_stage IR_2nd_Stage(   .clk(clk_i),
                                 .in(instruction),
                                 .out(IR),
                                 .Flush(Flush),
                                 .Stall(Stall),
                                 .reset_stages(DSP_reset_stages_i)
                                 ); 
    
       IR_3rd_stage IR_3rd_stage(       .clk(clk_i),
                                     .in(IR),
                                     .out(IR_3),
                                     .reset_stages(DSP_reset_stages_i)
                                     
                                     );
   
   uncond_str_element PC_2nd_Stage(  .clk(clk_i),
                                     .in(pc),
                                     .out(pc_2),
                                     .Stall(Stall),
                                     .reset_stages(DSP_reset_stages_i)
                                     );  
   
   imm_generator Imm_Generator(      .instruction(IR),
                                     .immediate(immediate)
                                     );   
    
    
   //  Register File GPRs
   
   
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
                                     
    uncond_str_element PC_3rd_Stage(  .clk(clk_i),
                                     .in(pc_2),
                                     .out(pc_3),
                                     .Stall(Stall),
                                     .reset_stages(DSP_reset_stages_i)
                                     );    
                                     
    uncond_str_element ALU_3rd_Stage(  .clk(clk_i),
                                     .in(ALU_result),
                                     .out(ALU_result_3),
                                     .Stall(Stall),
                                     .reset_stages(DSP_reset_stages_i)
                                     );                                                                    
                                         
    uncond_str_element WD_3rd_Stage(  .clk(clk_i),
                                     .in(data_rs2),
                                     .out(W_Data),
                                     .Stall(Stall),
                                     .reset_stages(DSP_reset_stages_i)
                                     );   
                                     
    // Data Memory
    
                                         
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
                                    .clk(clk_i),
                                    .Stall(Stall),
                                    .reset_stages(DSP_reset_stages_i)
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
