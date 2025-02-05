`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2024 05:54:37 PM
// Design Name: 
// Module Name: Control_Unit
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



module Control_Unit (

     //Instruction memory
    input  logic [31:0]           instruction,
  
     //Control signals
    output logic                  reg_WEn, 
    output logic                  Mem_W,
    output logic                  Mem_R, 
    output logic                  B_sel, 
    output logic [1:0]            WB_sel, 
    output logic [3:0]            ALU_op,
    output logic                  A_sel,
    output logic [2:0]            Br_type
 
    );

    // Internal signals to decode the instruction

           logic [6:0]            opcode;
           logic [2:0]            funct_3;
           logic [6:0]            funct_7;


    // Control signals
           logic                  r_type;
           logic                  Nop;
           logic                  j_type; 
           logic                  u_type;
           logic                  b_type;
           logic                  s_type;
           logic                  i_type;


    //////////////////////////////////////////////////////
    // **** Decode the opcode from the instruction **** //
    /////////////////////////////////////////////////////

           assign opcode          =        instruction [6:0];
           assign funct_3         =        instruction [14:12];
           assign funct_7         =        instruction [31:25];

    /////////////////////////////////////////////////
    // **** Determine the type of instruction **** //
    /////////////////////////////////////////////////

           assign r_type          =        (opcode == 7'b0110011);
           assign i_type          =        ((opcode == 7'b0010011) || (opcode == 7'b0000011) || (opcode == 7'b1100111)) && (instruction != 32'h00000013);
           assign s_type          =        (opcode == 7'b0100011);
           assign b_type          =        (opcode == 7'b1100011);
           assign u_type          =        ((opcode == 7'b0010111) || (opcode == 7'b0110111));
           assign j_type          =        (opcode == 7'b1101111);
           assign Nop             =        (instruction == 32'h00000013);

    /////////////////////////////////////////////////////////////////////
    // ****Generate control signals based on the instruction type **** //
    /////////////////////////////////////////////////////////////////////

    always_comb begin
    
            // For R-type instructions
           
            if (r_type) begin
                reg_WEn           =        1'b1; // Write back to register file
                B_sel             =        1'b0;
                Mem_R             =        1'b0;
                Mem_W             =        1'b0;
                WB_sel            =        2'b01;
                A_sel             =        0;
                Br_type           =        3'b111;
                

                case ({funct_3, funct_7})
                    // ADD
                    {3'b000, 7'b0000000}:  ALU_op = 4'b0000; // Add
                
                    // SUB
                    {3'b000, 7'b0100000}:  ALU_op = 4'b0001; // Subtract
                    
                    // SLL
                    {3'b001, 7'b0000000}:  ALU_op = 4'b0010; // Shift Left Logical
                    
                    // SLT
                    {3'b010, 7'b0000000}:  ALU_op = 4'b0011; // Set Less Than
                
                    // SLTU
                    {3'b011, 7'b0000000}:  ALU_op = 4'b0100; // Set Less Than Unsigned
                    
                    // XOR
                    {3'b100, 7'b0000000}:  ALU_op = 4'b0101; // Bitwise XOR
                
                    // SRL
                    {3'b101, 7'b0000000}:  ALU_op = 4'b0110; // Shift Right Logical
                    
                    // SRA
                    {3'b101, 7'b0100000}:  ALU_op = 4'b0111; // Shift Right Arithmetic
                    
                    // OR
                    {3'b110, 7'b0000000}:  ALU_op = 4'b1000; // Bitwise OR
                
                    // AND
                    {3'b111, 7'b0000000}:  ALU_op = 4'b1001; // Bitwise AND
                
                    default:               ALU_op = 4'b0000; // Default: no operation
            
                endcase

            end 

            else if (i_type) begin
                B_sel             =        1;
                A_sel             =        0;
                reg_WEn           =        1'b1; // Write back to register file
                Mem_W             =        1'b0;
            
                if (opcode == 7'b0010011) begin  // no mem read,  so wb sel = 1
                    Mem_R         =        1'b0;
                    WB_sel        =        2'b01;
                    Br_type       =        3'b111;

                    case (funct_3)   //, instruction[31:25]}

                        // ADDI
                        3'b000: ALU_op            = 4'b0000; // ADDI (Add Immediate)
                
                        // SLTI
                        3'b010: ALU_op            = 4'b0011; // SLTI (Set Less Than Immediate)
                        
                        // SLTIU 
                        3'b011: ALU_op             = 4'b0100; // SLTIU (Set Less Than Immediate Unsigned)
                    
                        // XORI
                        3'b100: ALU_op             = 4'b0101; // XORI (XOR Immediate)
                    
                        // ORI
                        3'b110: ALU_op             = 4'b1000; // ORI (OR Immediate)
                    
                        // ANDI
                        3'b111: ALU_op             = 4'b1001; // ANDI (AND Immediate)
        
                        // SLLI
                        3'b001: ALU_op             = 4'b0010; // SLLI (Shift Left Logical Immediate)
                

                        3'b101: 
                            case(funct_7)

                                // SRLI
                                7'b0000000: 
                                ALU_op             = 4'b0110; // SRLI (Shift Right Logical Immediate)
                    
                                // SRAI
                                7'b0100000: 
                                ALU_op             = 4'b0111; // SRAI (Shift Right Arithmetic Immediate)
                        
                                default:  ALU_op   = 4'b0000; // Default: no operation

                            endcase
                
                        default: ALU_op            = 4'b0000; // Default: no operation
            
                    endcase
                end

                else if(opcode == 7'b000011) begin
                        Mem_R       =      1'b1;
                        WB_sel      =      2'b00;
                        Br_type     =      3'b111;

                    case (funct_3)
                    
                        // LW (Load Word)

                        3'b010: ALU_op =   4'b0000; // ADDI (Address Calculation)
                        
                        // LBU (Load Byte Unsigned)
                        //3'b100: ALU_op = 4'b0000; // ADDI (Address Calculation)
                        // LHU (Load Half Unsigned)
                        //3'b101: ALU_op = 4'b0000; // ADDI (Address Calculation)
                        
                        default: ALU_op =  4'b0000; // Default: no operation
                
                    endcase

                end

                else if(opcode == 7'b1100111) begin    // Jalr
                        
                    case (funct_3)
                    
                        3'b000: begin 
                            ALU_op  =      4'b0000; 
                            Mem_R   =      1'b0;
                            WB_sel  =      2'b10;
                            Br_type =      3'b110;
                        end
                        
                        default: begin 
                            ALU_op  =      4'b0000; // Default: no operation
                            Mem_R   =      1'b0;
                            WB_sel  =      2'b00;
                            Br_type =      3'b111;
                        end

                    endcase

                end

                else begin 
                        Mem_R       =      1'b0;
                        WB_sel      =      2'b00;
                        ALU_op      =      4'b0000;
                end


            
            end
            
            
            else if (s_type) begin
                Br_type             =      3'b111;

                case (funct_3)

                //   3'b000: store byte
                //   3'b001: store half word

                        3'b010:begin // store word
                            
                            ALU_op  =      4'b0000; 
                            B_sel   =      1'b1;
                            Mem_R   =      1'b0;
                            Mem_W   =      1'b1;
                            WB_sel  =      2'b00;
                            reg_WEn =      1'b0; 
                            A_sel   =      0;
                            
                                
                        end

                        default: begin

                            ALU_op  =      4'b0000; // Default: no operation
                            B_sel   =      0;
                            Mem_R   =      0;
                            Mem_W   =      0;
                            WB_sel  =      0;
                            reg_WEn =      0; 
                            A_sel   =      0;
                            
                        end
                
                endcase
                // Example: Store operations
                // Set appropriate control signals
            end 
            
            else if (b_type) begin
                ALU_op              =      4'b0000;
                A_sel               =      1; // selecting pc
                B_sel               =      1; // selecting imm
                WB_sel              =      0;
                Mem_R               =      0;
                Mem_W               =      0;
                reg_WEn             =      0;
            
                case (funct_3)

                    // Branch if equal (beq)
                    3'b000: Br_type  = 3'b000;

                    // Branch if not equal (bne)
                    3'b001: Br_type  = 3'b001;

                    // Branch if less than (blt)
                    3'b100: Br_type  = 3'b010;

                    // Branch if greater than or equal (bge)
                    3'b101: Br_type  = 3'b011;

                    // Branch if less than, unsigned (bltu)
                    3'b110: Br_type  = 3'b100;

                    // Branch if greater than or equal, unsigned (bgeu)
                    3'b111: Br_type  = 3'b101;

                    default: Br_type = 3'b111;
                    
                endcase
        
            end
        
            else if(u_type) begin

                B_sel               =      1'b1;
                reg_WEn             =      1'b1; // Write back to register file
                Mem_R               =      1'b0;
                Mem_W               =      1'b0;
                WB_sel              =      2'b01;
                A_sel               =      1;    // pc selecting
                Br_type             =      3'b111;
                
                case(opcode)

                7'b0010111: ALU_op  =      4'b0000; // AUIPC
                7'b0110111: ALU_op  =      4'b1010; // LUI

                default:    ALU_op  =      0;
                endcase
            
            end

            else if(j_type) begin

                reg_WEn             =      1'b1;   // Write back to register file
                B_sel               =      1'b1;   // selecting imm
                Mem_R               =      1'b0;
                Mem_W               =      1'b0;
                WB_sel              =      2'b10;  //  selecting pc + 4
                ALU_op              =      4'b0000;
                A_sel               =      1;      // pc selecting
                Br_type             =      3'b110; // branch taken = 1 , selecting offset not pc+4
                    
            end

            else if(Nop) begin
                    
                reg_WEn             =      1'b0;  // Write back to register file
                B_sel               =      1'b0;
                Mem_R               =      1'b0;
                Mem_W               =      1'b0;
                WB_sel              =      2'b11; // used for instruction complete signal picked from 3rd stage
                ALU_op              =      4'b1111;
                A_sel               =      0;
                Br_type             =      3'b111; 
            end
            
            else begin
            
                reg_WEn             =      1'b0; // Write back to register file
                B_sel               =      1'b0;
                Mem_R               =      1'b0;
                Mem_W               =      1'b0;
                WB_sel              =      2'b00;
                ALU_op              =      0;
                A_sel               =      0;
                Br_type             =      3'b111;
        
            end


        end
        

endmodule

