# 🛠️ Digital Systems Design - Laboratory Assignments (VHDL)

## 📌 Overview
This repository contains the implementations two laboratory assignments of the "Digital Systems Design" course of
the National and Kapodistrian University of Athens. The projects focus on designing combinational and sequential circuits, as well as memory interfacing, using **VHDL** and the **Xilinx Vivado** Design Suite.

---

## Reports and Documentation
In each assignment there is a report in PDF format that explains the design process, implementation details, and verification results and timings. Also there are the assignments' instructions in PDF format.

## 📂 Project Contents

### 1. 32-bit Arithmetic Logic Unit (ALU)
Design and implementation of a parameterized 32-bit ALU that executes arithmetic and logical operations in parallel across four 8-bit numbers simultaneously.

**Technical Features:**
* **Supported Operations:** `ADD`, `SUB` (A-B), `AND`, `XOR`, `MAX`, `SAT_ADD` (Saturating Addition), `LSL` (Logical Shift Left), and `ASR` (Arithmetic Shift Right).
* **Sign Modes:** Support for both Signed and Unsigned arithmetic via the `Signed_mode` input control.
* **Status Flags:** Accurate computation of status flags for each of the four 8-bit parallel operations:
    * **Z (Zero):** Indicates if the result is zero.
    * **N (Negative):** Indicates a negative result (in signed mode).
    * **C (Carry):** Unsigned overflow indicator.
    * **V (Overflow):** Signed overflow indicator.
    * **S (Saturation):** Indicates boundary limit excess during `SAT_ADD` operations.

### 2. Sequence Detector & Bubble Sort Accelerator
This assignment is divided into two distinct parts focusing on Finite State Machines (FSM) and in-memory data processing.

**Part A: Sequence Detector (Seq_Det)**
* Implementation of a Finite State Machine (FSM) that processes a serial input bitstream.
* **Functionality:** The circuit monitors the input and asserts the `ERR` output to '1' upon detecting the specific sequence `"111"`, indicating a transmission error.

**Part B: Bubble Sort Hardware Accelerator**
* Hardware-level implementation of the classic **Bubble Sort** algorithm.
* **Memory Management:** Unsorted data is read directly from a **ROM** module. After the hardware sorting process is complete, the data is written in strictly ascending order to a **RAM** module.
* **Parameterization:** Extensive use of `generics` to easily scale the address width (`AWIDTH`) and data word length (`DWIDTH`).

---

## ⚙️ Tools & Verification Process
* **Hardware Description Language:** VHDL
* **EDA Tool:** Xilinx Vivado IDE
* **Verification & Testing:** * Behavioral Simulation using custom Testbenches to validate logic correctness.
    * Post-Synthesis Timing Simulation for accurate timing and critical path analysis.
    * RTL and Synthesis Schematic evaluations.
* **Implementation Metrics:** Resource Utilization Reports and Delay Analysis (Propagation/Contamination Delay).