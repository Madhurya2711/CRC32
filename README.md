## 1. **Project Title**
High-Speed CRC and Parallel CRC Accelerator for Reliable Network Protocols on Microwatt
## 2. Motivation and Problem Statement
In modern network communication, error detection is essential to ensure data integrity. Cyclic Redundancy Check (CRC) is a widely used mechanism for detecting errors in transmitted data. However, traditional CRC implementations can become a performance bottleneck in high-speed systems, especially when implemented purely in software.

The goal of this project is to design and integrate a **hardware-accelerated CRC unit** (including parallel CRC computation support) with the open-source Microwatt CPU core. This accelerator will significantly reduce latency and increase throughput for error detection in network protocol applications.

## 3. Objectives
- Implement a **CRC computation accelerator** in Verilog/VHDL.  
- Support **parallel CRC calculation** for multiple bytes per clock cycle.  
- Integrate the accelerator as a **memory-mapped peripheral** to Microwatt.  
- Demonstrate performance improvements compared to software-only CRC.  
- Provide testbenches and simulation results.  

## 4. High-Level Block Diagrams

### ASCII Block Diagram (simple, easy to include in README)
```
+-----------------+              +-----------------------+             +------------------+
|   Microwatt     |<--busctrl--->|  Memory-mapped Bus    |<--AXI/Wishbone->| Packet Buffer   |
|   CPU (SW)      |              |  (e.g., Wishbone/AXI) |             | (DDR/SRAM or TB) |
+-----------------+              +-----------------------+             +------------------+
        |                                 |
        | memory-mapped registers         | memory-mapped data region (packet buffer)
        |                                 |
        v                                 v
+----------------------+          +----------------------------+
| CRC Accelerator      |<-------->| Control & Status Registers |
| + Parallel CRC Unit  |          | - CMD_START                |
| + Header Parser FSM  |          | - STATUS_DONE              |
| + Data FIFO / DMA    |          | - CRC_OUT (32-bit)        |
+----------------------+          +----------------------------+
        ^
        | (reads packet buffer, or CPU writes stream)
        |
   Packet stream or bus bursts
```



## 5. Methodology
1. **Literature Review**: Study CRC algorithms and parallel computation methods.  
2. **Hardware Design**: Implement CRC accelerator (serial + parallel) in Verilog/VHDL and header parser FSM.  
3. **Integration**: Connect accelerator to Microwatt via memory-mapped registers (Wishbone or AXI-lite style). API: input buffer pointer, length, start, status, CRC_OUT, parsed fields.  
4. **Software Support**: Write driver in C for Microwatt that:
   - Allocates/points to packet buffer
   - Writes commands to registers
   - Polls/handles interrupt on completion
   - Compares hardware CRC with software CRC for validation
5. **Testing**: Unit test with known CRC vectors; end-to-end test in Microwatt simulation.  
6. **Evaluation**: Measure throughput, latency, cycles consumed by CPU for software vs hardware path.

## 6. Timeline (20 Days)
- **Days 1–3**: Literature review, finalize CRC polynomial and parallelization factor (bytes per cycle).  
- **Days 4–10**: Implement CRC unit (serial + parallel), unit test CRC.  
- **Days 11–14**: Implement header parser FSM and memory-mapped register interface.  
- **Days 15–17**: Integrate with Microwatt simulation, write C driver and test programs.  
- **Days 18–19**: Run benchmarks comparing hardware vs software CRC; collect results.  
- **Day 20**: Finalize documentation, prepare submission package.

## 7. Example Memory-Mapped Register Map (suggested)
- `0x00` CMD_START (write: 1=start)  
- `0x04` STATUS (read: bit0=done, bit1=error)  
- `0x08` BUF_ADDR (write: base address of packet buffer)  
- `0x0C` BUF_LEN  (write: length in bytes)  
- `0x10` CRC_OUT  (read: 32-bit CRC result)  
- `0x14` PARSED_IP_SRC (read: 32-bit)  
- `0x18` PARSED_IP_DST (read: 32-bit)  
- `0x1C` PARSED_PROTOCOL (read: 8-bit)

## 8. Deliverables
- Verilog/VHDL source for CRC & parser (synthesizable).  
- Testbenches and sample packet traces.  
- Microwatt integration wrapper (bus interface).  
- C driver + example applications.  
- README, design notes, and performance report.  

## 9. References
- Koopman, P. (2002). *32-bit Cyclic Redundancy Codes for Internet Applications.* DSN.  
- Zhang, X., & Prasanna, V. (2003). *High-Throughput and Resource-Efficient CRC Implementation.* FCCM.  
- OpenCores — CRC IP cores.  
- Microwatt — https://github.com/antonblanchard/microwatt

