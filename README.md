
# UART, DMA controller and Memory, all interconnected using APB
An RTL design project using verilog. It aims to model an SoC subsystem mainly including UART, DMA controller and memory interfaced with APB. 
  NB : *The documentation and directories are not complete. They are updated as the project developes.*
## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Module Descriptions](#module-descriptions)
  - [UART](#uart)
  - [DMA Controller](#dma-controller)
  - [Memory](#memory)
  - [APB Interface](#apb-interface)
- [Directory Structure](#directory-structure)
- [Verification](#verification)
- [Simulation Results](#simulation-results)
- [LinkedIn Series](#linkedin-series)



## Overview

This project is an RTL implementation of an SoC subsystem featuring a UART, DMA Controller, and Memory Module, all interconnected through the AMBA APB (Advanced Peripheral Bus) protocol. The design focuses on scalable modular architecture, clean RTL coding practices, and subsystem-level integration concepts commonly used in digital IC design.

The key objective of this project is to showcase my independent design and engineering process. **The system architecture, pipelining, RTL implementation, debugging, verification strategy, and problem-solving decisions were developed manually WITHOUT following any tutorial or using ANY AI-assisted coding or design tools.** This repository reflects my personal understanding, research, and hands-on learning throughout the development cycle.

## System Architecture

### Overview
The system consist of a UART module, dual channel DMA controller, memory module all of these interconnected with AMBA APB interface. The system is designed to significantly lower the unwanted CPU attention during the use of UART. The CPU just have to do an initial configuration to UART module and DMA controller; the rest of the data transfer through UART will be handled by DMA controller autonomously.

### Components
- **APB master and slave interfaces** : serves the purpose of data transfer between external system, DMA controller, UART and memory.

- **UART** : Universal Asynchronous Serial Transmitter core implementation.
    - **CLK DIVIDER** : Divides external clock by 32.
    - **UART-TIMER** : 8-bit timer, used to produce baud rate. baud rate is fixed according to the value initialized to this timer through timerInitVal[8-bit].
    - **TX** : contains TX FSM and shift register.
    - **RX** : contains RX FSM and shift register.

- **DMA CONTROLLER** : Direct Memory Access controller handles data transfer between UART and memory.
    - **TX CHANNEL** : It handles data transfer from memory buffer allocated for transmission to TX of UART.
    - **RX CHANNEL** : It handles data transfer from RX of UART to memory buffer allocated to store the recieved data.

- **MEMORY** : Represents the main memory of the external system. The buffers for TX and RX are allocated within this memory.

### Registers
#### Control registers
  - **TE** : Enables transmission through UART.
  - **RE** : Enables reception through UART.
  -  **DMA_enable** : Enables DMA controller. The DMA should be enabled only after TE and RE are enabled.

#### Configuration registers
  - **timerInitVal** : the value in this register determines baud rate. Baud rate = Fosc/(32 x (256-timerInitVal))
  - **Memory_buff_strt_addr** : Starting address of the buffer allocated for TX or RX.
  - **Memory_buff_offset** : Size of the buffer allocated for TX or RX.

#### Control signals *or also internal register*
  - **TI** : Transmission completed Interrupt signal. Driven by UART TX.
  - **TI_in** : signal driven by DMA controller to clear TI
  - **RI** : Reception completed interrupt driven by UART RX.
  - **RI_in** : signal driven by DMA controller to clear RI.









### Configuration of DMA controller
Each channel of DMA has 2 registers.
- **Memory_buff_strt_addr [8-bit]** : Start address of (TX or RX) buffer in memory.
- **Memory_buff_offset [8-bit]** : Size of (TX or RX) buffer.

The external system writes the configuration data to these 3 registers in accordance with their description. The start address and size of the data buffer allocated to transmit will be written to Memory_buff_strt_addr and Memory_buff_offset of TX channnel respectively. Similarly, the start address and size of the buffer allocated to store the byte streams recieved through RX is written to Memory_buff_strt_addr and Memory_buff_offset of RX channel respectively. The peripheral addresses of TX and RX are hardcoded to internal registers in DMA controller, because making them externally configurable cost additional clock cycles to the external system.

### Configuration of UART
UART has 3 registers
- **TE** : TX Enable
- **RE** : RX Enable
- **timerInitVal [8-bit]**: Initial value to be loaded to the uart-timer, this value determines the baud rate.

The enabling of TE and RE starts the listening in TX and RX pins.


#### Design and Working
The system is designed to operate at a clock frequency of 11.0592MHz. This frequency makes it easy to produce standard baud rates after divisionstd 
