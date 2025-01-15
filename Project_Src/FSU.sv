`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 10:55:14 PM
// Design Name: 
// Module Name: FSU
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


module FSU( input logic [31:0] IR,IR_3,
            input logic [31:0] IR_3,
            input logic reg_wrMW,  br_taken,
            input logic br_taken,
            output logic  For_A, 
            output logic  For_B ,  
            output logic  Stall,   
            output logic  Flush 

    );
    //logic [4:0] rd_IR, rs1_IR_3, rs2_IR_3;
    logic [4:0] rd_IR_3, rs1_IR, rs2_IR;
    assign rd_IR = IR[11:7];
    assign rs1_IR_3 = IR_3[19:15];
    assign rs2_IR_3 = IR_3[24:20];
    assign rd_IR_3 = IR_3[11:7];
    assign rs1_IR = IR[19:15];
    assign rs2_IR = IR[24:20];
    // logic lw;
    
    initial begin
            
            Stall = 0;
          //  Stall_MW = 0;
            Flush = 0;
            For_A = 0;
            For_B = 0;
    
    end
    
    always @(*) begin
    
            if(rs1_IR == 5'b0000 || rs2_IR == 5'b00000)
                begin
                For_A = 0;
                For_B = 0;
                end
            
            else if( (rd_IR_3 == rs1_IR) && reg_wrMW && IR_3[6:0] != 7'b0000011)
                begin
                For_A = 1;
                For_B = 0;
                end
            
            else if( (rd_IR_3 == rs2_IR) && reg_wrMW && IR_3[6:0] != 7'b0000011 )
                begin
                For_A = 0;
                For_B = 1;
                end
            else 
                begin
                For_A = 0;
                For_B = 0;
                end
    
    
    end
    
    always @(*) begin
            
            if (((IR_3[6:0] == 7'b0000011) && ((rs1_IR == rd_IR_3) | (rs2_IR == rd_IR_3))) && ( (rs1_IR != 0) && (rs2_IR != 0) ) ) begin
                
                Stall = 1;
               // Stall_MW = 0;

            end
            else begin
                Stall = 0;
               // Stall_MW = 0;
            end
            
           // Stall = 0;
           // Stall_MW = 0;
            /*
            lw = (WB_sel == 2'b00) & ((rs1_IR == rd_IR_3) | (rs2_IR == rd_IR_3) );
            Stall = lw ;
            Stall_MW = lw ;
          //  Stall = 0;
          //  Stall_MW = 0;
    */
    end
    always @(*) begin
     Flush = br_taken;
  //  assign Flush = 0;
    
    end
endmodule
