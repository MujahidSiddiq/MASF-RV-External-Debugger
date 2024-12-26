`timescale 1ns / 1ps

module test_bench();


  logic             clk;
  logic             reset;
  

  logic             dmi_req_valid_i;
  logic [1:0]       dmi_req_op_i;
  logic [6:0]       dmi_req_address_i;
  logic [31:0]      dmi_req_data_i;

  logic             dmi_req_ready_o;
  logic             dmi_rsp_valid_o;
  logic [1:0]       dmi_rsp_op_o;
  logic [31:0]      dmi_rsp_data_o;


  

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  
  end

  // Reset sequence
  initial begin
    reset = 0;
    #5 reset = 1;  
    #14.5 reset = 0;
    #5 reset = 1;
  end





  // Initialize all inputs to zero
  initial begin
    dmi_req_valid_i         = 0;
    dmi_req_op_i            = 2'b00;
    dmi_req_address_i       = 7'b0000000;
    dmi_req_data_i          = 32'h00000000;
  end



  // Instantiate the top module (Device Under Test)
  Top_Module dut (
                    .clk                        (clk),
                    .reset                      (reset),
                    .dmi_req_valid_i            (dmi_req_valid_i),
                    .dmi_req_op_i               (dmi_req_op_i),
                    .dmi_req_address_i          (dmi_req_address_i),
                    .dmi_req_data_i             (dmi_req_data_i),
                    .dmi_req_ready_o            (dmi_req_ready_o),
                    .dmi_rsp_valid_o            (dmi_rsp_valid_o),
                    .dmi_rsp_op_o               (dmi_rsp_op_o),
                    .dmi_rsp_data_o             (dmi_rsp_data_o)

  );




  // Test scenario execution
  initial begin

    test_dmi_commands();

    // End simulation
    #5000 $finish;
  end

  task test_dmi_commands();
    begin
      $display("Starting DMI command sequence...");
      #50;

      store_halt_req_in_dmcontrol(32'h80000001);

      // storing pc at which we want to set a breakpoint
      #50;
      store_in_data_0(32'h00000024);
      #20;
      store_access_register_command(32'h000307b2); 

      /// setting ebreakm
      #50;
      store_in_data_0(32'h00008000);
      #20;
      store_access_register_command(32'h000307b0); 
      #20;
      set_resume_req_in_dmcontrol(32'h40000001);

      #200;

      /////////////////////////////////
      //////////// 1st step ///////////
      ////////////////////////////////
      #50;
      store_in_data_0(32'h00000004);
      #20;
      store_access_register_command(32'h000307b0); 
      #100;


      /////////////////////////////////
      //////////// 2nd step ///////////
      ////////////////////////////////
      store_in_data_0(32'h00000004);
      #20;
      store_access_register_command(32'h000307b0); 
      #100;


      /////////////////////////////////
      //////////// 3rd step ///////////
      ////////////////////////////////
      store_in_data_0(32'h00000004);
      #20;
      store_access_register_command(32'h000307b0);       
      #100; 

      ///////////////////////////////////////
      /////// Exiting From Debugging /////////
      //////////////////////////////////////
      set_resume_req_in_dmcontrol(32'h40000001);  // Final resume request


    end
  endtask

  // Task to store halt_req in dmcontrol
  task store_halt_req_in_dmcontrol(logic [31:0] value);
    begin
      dmi_req_valid_i         = 1;
      dmi_req_op_i            = 2'b10;  // Write operation
      dmi_req_address_i       = 7'h10;  // Address for dmcontrol
      dmi_req_data_i          = value;
      #50; 
      dmi_req_valid_i         = 0;

    end
  endtask


  task store_in_data_0(logic [31:0] value);
    begin
      dmi_req_valid_i         = 1;
      dmi_req_op_i            = 2'b10;  // Write operation
      dmi_req_address_i       = 7'h04;  // Address for Data0
      dmi_req_data_i          = value;

      #10; 
      dmi_req_valid_i         = 0;

    end
  endtask

  // Task to store access register command
  task store_access_register_command(logic [31:0] value);
    begin
      dmi_req_valid_i         = 1;
      dmi_req_op_i            = 2'b10;  // Write operation
      dmi_req_address_i       = 7'h17;  // Address for command register
      dmi_req_data_i          = value;

      #10;
      dmi_req_valid_i         = 0;

    end
  endtask

  // Task to set resume_req in DM control
  task set_resume_req_in_dmcontrol(logic [31:0] value);
    begin
      dmi_req_valid_i         = 1;
      dmi_req_op_i            = 2'b10;  // Write operation
      dmi_req_address_i       = 7'h10;  // Address for dmcontrol
      dmi_req_data_i          = value;  
 
      #10;
      dmi_req_valid_i         = 0;

    end
  endtask





endmodule
