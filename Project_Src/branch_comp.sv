`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2024 02:50:36 PM
// Design Name: 
// Module Name: branch_comp
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


module branch_comp(
    input logic [31:0] num1,     // First input number
    input logic [31:0] num2,     // Second input number
    input logic [2:0] br_type,   // Branch type control (0: beq, 1: bne, 2: blt, 3: bge, 4: bltu, 5: bgeu)
    output logic br_taken        // Output bit for branch taken
);

    // Enum declaration for branch types
    typedef enum logic [2:0] {
        BEQ = 3'b000,   // Branch if equal (unsigned)
        BNE = 3'b001,   // Branch if not equal (unsigned)
        BLT = 3'b010,   // Branch if less than (signed)
        BGE = 3'b011,   // Branch if greater or equal (signed)
        BLTU = 3'b100,  // Branch if less than (unsigned)
        BGEU = 3'b101,   // Branch if greater or equal (unsigned)
        Br_Taken = 3'b110,
        Br_not_taken = 3'b111
    } branch_type_t;

    // Signed comparison
    logic eq_signed, lt_signed;
    assign eq_signed = (num1 == num2);
    assign lt_signed = ($signed(num1) < $signed(num2));

    // Unsigned comparison      
    logic eq_unsigned, lt_unsigned;
    assign eq_unsigned = (num1 == num2);
    assign lt_unsigned = (num1 < num2);

    // Perform the branch comparison based on br_type
    always_comb begin
        case (br_type)
            BEQ: br_taken = eq_unsigned;                       // beq (unsigned)
            BNE: br_taken = ~eq_unsigned;                      // bne (unsigned)
            BLT: br_taken = lt_signed;                         // blt (signed)
            BGE: br_taken = ~lt_signed;                        // bge (signed)
            BLTU: br_taken = lt_unsigned;                      // bltu (unsigned)
            BGEU: br_taken = ~lt_unsigned;                     // bgeu (unsigned)
            Br_Taken: br_taken = 1;
            Br_not_taken: br_taken = 0;
            //default: br_taken = 1'b0; // Default to not taken
        endcase
    end

endmodule

