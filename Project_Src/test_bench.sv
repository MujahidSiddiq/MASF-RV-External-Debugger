`timescale 1ns / 1ps

module test_bench();

  // Declare testbench signals
  logic             clk;
  logic             reset;
  
  // DMI signals
  logic             dmi_req_valid_i;
  logic [1:0]       dmi_req_op_i;
  logic [6:0]       dmi_req_address_i;
  logic [31:0]      dmi_req_data_i;

  logic             dmi_req_ready_o;
  logic             dmi_rsp_valid_o;
  logic [1:0]       dmi_rsp_op_o;
  logic [31:0]      dmi_rsp_data_o;

  // Core signals
  
  logic             core_inst_comp_i;
  logic [31:0]      core_pc_to_dpc_i;
  logic             core_resuming_o;
  logic             core_halt_o;
  logic [31:0]      core_dpc_for_pc_o;

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100 MHz clock period
  end

  // Reset sequence
  initial begin
    reset = 0;
    #15 reset = 1;  // Assert reset for 15 ns
  end





  // Initialize all inputs to zero
  initial begin
    dmi_req_valid_i         = 0;
    dmi_req_op_i            = 2'b00;
    dmi_req_address_i       = 7'b0000000;
    dmi_req_data_i          = 32'h00000000;
    core_inst_comp_i        = 0;
    core_pc_to_dpc_i        = 32'h00000000;
  end



  // Instantiate the top module (Device Under Test)
  top_module dut (
                    .clk                        (clk),
                    .reset                      (reset),
                    .dmi_req_valid_i            (dmi_req_valid_i),
                    .dmi_req_op_i               (dmi_req_op_i),
                    .dmi_req_address_i          (dmi_req_address_i),
                    .dmi_req_data_i             (dmi_req_data_i),
                    .dmi_req_ready_o            (dmi_req_ready_o),
                    .dmi_rsp_valid_o            (dmi_rsp_valid_o),
                    .dmi_rsp_op_o               (dmi_rsp_op_o),
                    .dmi_rsp_data_o             (dmi_rsp_data_o),
                    // .core_halt_ack_i(core_halt_ack_i),
                    .core_halt_o                (core_halt_o),
                    .core_resuming_o            (core_resuming_o),
                    .core_pc_to_dpc_i           (core_pc_to_dpc_i),
                    .core_dpc_for_pc_o          (core_dpc_for_pc_o),
                    .core_inst_comp_i           (core_inst_comp_i)
  );




  // Test scenario execution
  initial begin
    // Scenario: DMI commands to manipulate DM control and DCSR
    test_dmi_commands();

    // End simulation
    #1000 $finish;
  end
 // wait for one clock cycle is #10
  // Task: Execute DMI commands
  task test_dmi_commands();
    begin
      $display("Starting DMI command sequence...");

      // Step 1: Store hexadecimal value for halt_req in dmcontrol
      store_halt_req_in_dmcontrol(32'h80000001);  // Example halt_req value
      #10; 
      core_dpc_i          = 32'h00000008;
      // Step 2: Wait 3 cycles and check core instruction complete
      #30;  // Wait for 3 clock cycles
      core_inst_comp_i    = 1;  // Simulate core acknowledgment
      #50;
      core_inst_comp_i    = 0;
      // Step 3: Store hexadecimal value for DCSR with step bit set to 1 in data0
      store_dcsr_with_step(32'h00000002);  // Example DCSR value
      #20;

      // Step 4: Store command for access register command (write to DCSR)
      store_access_register_command(32'h000307b0);  // Example command for access register
      #50; // wait for 10 clock cycles
      core_inst_comp_i    = 1;
      #50;
      core_inst_comp_i    = 0;


      // Step 5: Set resume_req in DM control for stepping
      set_resume_req_in_dmcontrol(32'h40000001);  // Example value for resume_req
      #50; // wait for 5 cycles
      core_inst_comp_i    = 1;
      #20;
      core_inst_comp_i    = 0;
      repeat (3) begin  // Repeat for 3-4 steps
        #60;  // Wait for 6 clock cycles before issuing the next resume request
        set_resume_req_in_dmcontrol(32'h40000001);
        #50; // wait for 5 cycles
        core_inst_comp_i  = 1;
        #20;
        core_inst_comp_i  = 0;
      end
      


      // Step 6: Reset step bit in DCSR
      //  Store hexadecimal value for DCSR with step bit set to 1 in data0
      store_dcsr_with_step(32'h00000000);  
      #20;
      // Store command for access register command (write to DCSR)
      store_access_register_command(32'h000307b0);  // Example command for access register
      #100; // wait for 10 clock cycles


      // Step 7: Set resume_req in DM control again
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
      // @(posedge dmi_req_ready_o);  // Wait for DMI request ready
      #50; // wait for one clock cycle
      dmi_req_valid_i         = 0;
      // $display("Stored halt_req in dmcontrol: %h", value);
    end
  endtask

  // Task to store DCSR with step bit set
  task store_dcsr_with_step(logic [31:0] value);
    begin
      dmi_req_valid_i         = 1;
      dmi_req_op_i            = 2'b10;  // Write operation
      dmi_req_address_i       = 7'h04;  // Address for Data0
      dmi_req_data_i          = value;
      // @(posedge dmi_req_ready_o);  // Wait for DMI request ready
      #10; // wait for one clock cycle
      dmi_req_valid_i         = 0;
      // $display("Stored DCSR with step bit set: %h", value);
    end
  endtask

  // Task to store access register command
  task store_access_register_command(logic [31:0] value);
    begin
      dmi_req_valid_i         = 1;
      dmi_req_op_i            = 2'b10;  // Write operation
      dmi_req_address_i       = 7'h17;  // Address for command register
      dmi_req_data_i          = value;
      // @(posedge dmi_req_ready_o);  // Wait for DMI request ready
      #10;
      dmi_req_valid_i         = 0;
      // $display("Stored access register command: %h", value);
    end
  endtask

  // Task to set resume_req in DM control
  task set_resume_req_in_dmcontrol(logic [31:0] value);
    begin
      dmi_req_valid_i         = 1;
      dmi_req_op_i            = 2'b10;  // Write operation
      dmi_req_address_i       = 7'h10;  // Address for dmcontrol
      dmi_req_data_i          = value;  // Example value
      // @(posedge dmi_req_ready_o);  // Wait for DMI request ready
      #10;
      dmi_req_valid_i         = 0;
      // $display("Set resume_req in dmcontrol: %h", value);
    end
  endtask





endmodule
