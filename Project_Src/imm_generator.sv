`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2024 01:39:48 PM
// Design Name: 
// Module Name: imm_generator
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

module imm_generator(

    input  logic [31:0]             instruction, // 32-bit instruction input
    output logic [31:0]             immediate   // Output immediate value
    
    
    );

    ///////////////////////////////////////////////
    // **** Define an enum for opcode types **** //
    ///////////////////////////////////////////////

    typedef enum logic [6:0] {
        LOAD            =           7'b0000011,
        ALU_I           =           7'b0010011,
        STORE           =           7'b0100011,
        LUI             =           7'b0110111,
        AUIPC           =           7'b0010111,
        BRANCH          =           7'b1100011,
        JAL             =           7'b1101111,
        JALR            =           7'b1100111
    } OpcodeType;

    ///////////////////////////////////////////////
    // **** Extract opcode from instruction **** //
    ///////////////////////////////////////////////

        logic [6:0]                 opcode;
        assign opcode   =           instruction[6:0];

    
    /////////////////////////////////////////////////////////////////////////////
    // **** Generate immediate based on opcode using an always_comb block **** //
    /////////////////////////////////////////////////////////////////////////////

    always_comb begin

        case (opcode)

            // I-type instructions and jalr
            LOAD, ALU_I, JALR: immediate     =     {{20{instruction[31]}}, instruction[31:20]};

            // S-type instructions
            STORE: immediate                 =     {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

            // U-type instructions
            LUI, AUIPC: immediate            =     {instruction[31:12], 12'h000};

            // Branch instructions
            BRANCH: immediate                =     {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};

            // JAL instruction
            JAL: immediate                   =     {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};

            default: immediate               =     32'b0; // Default immediate

        endcase

    end
    

endmodule