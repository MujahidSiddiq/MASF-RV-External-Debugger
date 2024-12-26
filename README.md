# MASF-RV-External-Debugger

**"MASF-RV-External-Debugger"** project follows the **RISC-V Debug Specification**, version **0.13.2**. This document explains how to implement debugging features for RISC-V systems.

You can view the complete specification [here](https://riscv.org/wp-content/uploads/2024/12/riscv-debug-release.pdf).

## Table of Contents

1. [Project Goals](#1-project-goals)
2. [Implemented Features](#2-implemented-features)
3. [Block Diagram](#3-block-diagram)
4. [State Machines](#4-state-machines)
   - [Debug Module State Machine](#41-debug-module-state-machine)
   - [Debug Support State Machine](#42-debug-support-state-machine)
5. [Simulation Results](#5-simulation-results)
6. [Challenges Faced](#6-challenges-faced)
7. [Team](#7-team)

## 1. Project Goals

The project focuses on implementing critical debugging operations that help developers manage and inspect RISC-V processors during code execution. The core features targeted for this project are **Halt**, which pauses the execution; **Resume**, to continue execution from a halted state; **Step**, allowing execution of one instruction at a time; and **Breakpoints**, enabling to execute instructions at a specific point. Additionally, the project includes functionalities to **Access Registers**, such as CSRs and GPRs, and **Access Data Memory**. 

*-More features can be added as per project requirements...*

## 2. Implemented Features

Currently, the following debugging features have been successfully integrated into the **Debug Module (DM)**:

- **Halt**: When halting, whatever the current instruction is executing, halting will shift the execution flow through the PC to the start of the first instruction and stop at that point.
- **Resume**: Restarts the processor from the current instruction, regardless of where it is halted.
- **Step**: Executes one instruction at a time to allow detailed inspection of the execution flow.
- **Breakpoints**: Allows dynamic insertion of breakpoints during execution, enabling the processor to halt when a specific condition or address is met.
- **Access Registers**: Provides read access for CSR and GPR registers, and write access for Debug CSR registers only.
- **Access Data Memory**: Allows reading data from data memory during execution.

## 3. Block Diagram

The block diagram shows the interaction between the **Debug Module (DM)**, the **core**, and **data memory**. Requests from the **DMI** are sent to the **DM**, which processes them by controlling the **core** (e.g., halting or resuming execution or access registers) and accessing **data memory** for read operations. Responses are then sent back to the **DMI** after the requested operation is completed.

**Debug CSRs (Control and Status Registers)** are responsible for controlling operations like **step** and **breakpoints** during debugging. The **Debug Support** acts as a controller that processes operations coming from the **DM**, such as halt and resume, and performs operations like step and breakpoints according to the control signals coming from the **Debug CSRs**.

![Block Diagram](https://github.com/kingsflicker/MASF-RV-External-Debugger/blob/main/Project_Diagrams/Block_Diagram.png)

## 4. State Machines

- ### 4.1 Debug Module State Machine

  The main states are:

  - **Non-Debug States**: DM is waiting for a halt command.
  - **Halt/Resume**: These states are used for halting and resuming processor execution. They are also triggered when a set breakpoint is detected, and step operations occur in these states as well.
  - **Access Register Abstract Command**: These states are used to access registers with abstract commands. For example:
    - The **dcsr register** is accessed for Stepping and handling Break_Point.
    - The **dscratch0 register** is accessed to store the PC value where a breakpoint is set.
    - The **dpc register** is accessed to monitor the current value of the PC during Debug Operations.
  ![DM State Machine](https://github.com/kingsflicker/MASF-RV-External-Debugger/blob/main/Project_Diagrams/DM_FSM.png)

- ### 4.2 Debug Support State Machine

  The main states are:

  - **Non-Debug States**: Debug Support Module is waiting for a halt request.
  - **Halt/Resume**: These states are using for Halting to enter in Debug Mode, and Resuming.
  - **Step**: These states are responsible for single step execution in Debug Mode.
  - **Ebreak**: These states are responsible for Break_Point.


  ![HART State Machine](https://github.com/kingsflicker/MASF-RV-External-Debugger/blob/main/Project_Diagrams/HART_FSM.png)

## 5. Simulation Results

We have made significant advancements in the implementation of halt, stepping, and resuming functionality in both the **Debug Module (DM)** and **Hart**. Below is a summary of our simulation results:

1. **Halt Request**: Setting the `haltreq` in `dmcontrol` successfully transitioned the Hart to a halted state and into Debug Mode, as anticipated.

2. **Breakpoint**:Setting a breakpoint involves two steps:
      - Storing PC=32'h00000024 in the `dscratch0` register using `data0` and the access register command (32'h000307b2).
      - Writing 32'h00008000 (set `ebreakm`) into the `dcsr` register using `data0` and the access register command (32'h000307b0), ensuring proper breakpoint handling.


3. **Stepping Sequence**: The Hart executed three consecutive steps by storing 32'h00000004 in the dcsr register via data0 and the access register command (32'h000307b0) for each step, successfully progressing through instructions one at a time.

4. **Exiting Debugging Mode**: The `resumereq` command (32'h40000001) resumed normal processor execution, and the Hart exited Debug Mode without issues.


Overall, the simulation is functioning as intended, aligning perfectly with the described flow.

## 6. Challenges Faced

During the development of **MASF-RV-External-Debugger**, we identified some problems in the **Debug Module (DM)**, especially with how it interacts with the **Debug Module Interface (DMI)**. These issues will be fixed in the future after the completion of the DM functionality:

- **DMI Response Handling**: The **DM** currently doesn’t have a proper controller to manage DMI response ports, which can lead to unpredictable behavior. A dedicated controller will be added to ensure correct response handling.

- **DMI Request Handling**: Right now, **DMI requests** are handled using combinational logic, which may cause bugs when DMI inputs change. We plan to implement a state machine for DMI requests to ensure more reliable and consistent operation.

Once these issues are resolved, it will improve the DM functionality and allow us to add more debugging features.

## 7. Team

- **Project Leader: M. Mujahid Siddiq**  
  Contact: kingsflicker@gmail.com

- **Team Members:**
  - **Umm-e-Ammara**  
    Contact: queensflicker@gmail.com
  - **Sufyan Ahmad Basra**  
    Contact: abc@example.com
  - **M. Faiq**  
    Contact: abc@example.com
