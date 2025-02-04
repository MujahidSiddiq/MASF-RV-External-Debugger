# MASF-RV-External-Debugger

**"MASF-RV-External-Debugger"** project follows the **RISC-V Debug Specification**, version **0.13.2**. This document explains how to implement debugging features for RISC-V systems.

You can view the complete specification [here](https://riscv.org/wp-content/uploads/2024/12/riscv-debug-release.pdf).

## Table of Contents

1. [Project Goals](#1-project-goals)
2. [Implemented Features](#2-implemented-features)
3. [Block Diagram](#3-block-diagram)
4. [Team](#4-team)

## 1. Project Goals

The project focuses on implementing critical debugging operations that help developers manage and inspect RISC-V processors during code execution. The core features targeted for this project are **Halt**, which pauses the execution; **Resume**, to continue execution from a halted state; **Step**, allowing execution of one instruction at a time; and **Breakpoints**, enabling to execute instructions at a specific point. Additionally, the project includes functionalities to **Access Registers**, such as CSRs and GPRs, and **Access Data Memory**. 

*-More features can be added as per project requirements...*

## 2. Implemented Features

Currently, the following debugging features have been successfully integrated into the **Debug Module (DM)**:

- **Halt**: When halting, whatever the current instruction is executing, halting will shift the execution flow through the PC to the start of the first instruction and stop at that point.
- **Resume**: Restarts the processor from the current instruction, regardless of where it is halted.
- **Step**: Executes one instruction at a time to allow detailed inspection of the execution flow.
- **Breakpoints**: Allows dynamic insertion of breakpoints during execution, enabling the processor to halt when a specific condition or address is met.
- **Access Registers**: Provides Read Access for CSR and GPR registers, and write access for Debug CSR registers only.
- **Access Data Memory**: Allows reading data from data memory during execution.

## 3. Block Diagram

The block diagram shows the interaction between the **Debug Module (DM)**, the **core**, and **data memory**. Requests from the **DMI** are sent to the **DM**, which processes them by controlling the **core** (e.g., halting or resuming execution or access registers) and accessing **data memory** for read operations. Responses are then sent back to the **DMI** after the requested operation is completed.

**Debug CSRs (Control and Status Registers)** are responsible for controlling operations like **step** and **breakpoints** during debugging. The **Debug Support** acts as a controller that processes operations coming from the **DM**, such as halt and resume, and performs operations like step and breakpoints according to the control signals coming from the **Debug CSRs**.

![Block Diagram](https://github.com/kingsflicker/MASF-RV-External-Debugger/blob/main/Project_Diagrams/Block_Diagram.png)


## 4. Team

- **Project Leader: M. Mujahid Siddiq**  
  Contact: muhammadmujahidsiddiq@gmail.com

- **Team Members:**
  - **Umm-e-Ammara**  
    Contact: ummeammaraofficial@gmail.com
  - **Sufyan Ahmad Basra**  
    Contact: sufyanahmadbasra@gmail.com
  - **M. Faiq**  
    Contact: muhammadfaiq850@gmail.com
