

# UART, DMA controller and Memory, all interconnected using APB
An RTL design project using verilog. It aims to model an SoC subsystem mainly including UART, DMA controller and memory interfaced with APB.\
\
NB : *The documentation and directories are not complete. They are updated as the project developes.*

# Project progress : 30%

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

### Basic Block Diagram
<img width="1095" height="792" alt="UART DMA block diagram" src="https://github.com/user-attachments/assets/306b294f-bb98-4c94-a931-55bd096fde3a" alt="Basic block diagram"/>


### Detailed Architecture Diagram
<img width="1968" height="1865" alt="UART DMA Detailed Architecture" src="https://github.com/user-attachments/assets/deb42bb2-00c8-4cef-a26a-8cebd0b6e40a" alt="Detailed architecture diagram"/>




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
  - **DMA_enable** : Enables DMA controller. The DMA should be enabled only after TE and RE are enabled.

#### Configuration registers
  - **timerInitVal** : the value in this register determines baud rate. Baud rate = Fosc/(32 x (256-timerInitVal))
  - **Memory_buff_strt_addr** : Starting address of the buffer allocated for TX or RX.
  - **Memory_buff_offset** : Size of the buffer allocated for TX or RX.

#### Control signals *or also internal register*
  - **TI** : Transmission completed Interrupt signal. Driven by UART TX.
  - **TI_in** : signal driven by DMA controller to clear TI
  - **RI** : Reception completed interrupt driven by UART RX.
  - **RI_in** : signal driven by DMA controller to clear RI.
  - **TXI** : Driven by DMA. Signals the external system that all the bytes from allocated memory buffer has been transmitted (transmission complete).
  - **RXI** : Driven by DMA. Signals the external system that the allocated buffer for reception is full.

### Design and Dataflow
The system is designed to operate at a clock frequency of 11.0592MHz. This frequency makes it easy to produce standard baud rates after divisions.\
The CLK_DIVIDER divides clock frequency by 32 and the divided clock functions as the clock of UART-TIMER. The real-time value of UART-TIMER (timerCurrentVal) is given to the RX and TX shift registers to recieve and transmit data with respect to the baud rate.\
\
Baud rate = Fosc/(32 x (256-timerInitVal))\
\
The external system follows these steps in order
- Writes values to the configuration registers according to the need.
- Enables RE and TE
- Enables the DMA controller through DMA_enable

After this the DMA controller takes over the handling of data transfer to and from UART.\
In case of TX, the DMA controller starts to read the bytes from Memory_buff_strt_addr and write to the TXbuff(*internal buffer of UART to write the byte to transmit*). From there the TX of UART moves this byte to an internal shift register, adds start and stop bits to create UART frame. The shift register shifts according to the baud rate provided from UART-TIMER. After 1 byte is transferred, the UART TX pulls up the TI, on the positive edge of this TI, the DMA controller increments the internal address pointer register that stores the address of memory to be transmitted. DMA reads the byte from this memory address, writes to UART TXbuff and pulls down TI through TI_in and continues this process until all the bytes in memory buffer for TX is transmitted.\
In case of RX, when RX pin recieves a start-bit, the time to sample RX is calculated from value of timer at that instant and the timerInitVal. The shift register then samples and shifts RX on this time. The timer value to sample RX is calculated such that the sampling is done at the middle of the bit. On completing one full byte, the UART RX writes the byte to RXbuff and pulls up the RI. The DMA controller reads the byte from RXbuff, writes to the memory buffer for RX by incrementing internal address pointer register. It then pulls down the RI through RI_in to resume reception.\
The data transfer between DMA controller, UART and memory are carried out via AMBA APB interface.

The DMA controller signals the external system when\
- RX memory buffer is full (RXI)
- All bytes in TX memory buffer is finished transmitting. (TXI).

This helps the external system to update the memory buffer to continue data transfer.

## Module Descriptions
### UART
To be updated
### DMA Controller
To be updated
### Memory
To be updated
### APB Interface
To be updated

## Directory Structure
```
UART-DMAcontroller-Memory-pipelined-with-APB/
│   README.md
│
└───UART/
    │   README.md
    │
    ├───modules/
    │   │   clk_divider.v
    │   │   README.md
    │   │   UARTtop.v
    │   │   uart_timer.v
    │   │
    │   ├───RX/
    │   │       RXshift.v
    │   │       RXtop.v
    │   │
    │   └───TX/
    │           TXshift.v
    │           TXtop.v
    │
    ├───testbenches/
    │   │   clk_divider_tb.v
    │   │   UART_tb.v
    │   │   uart_timer_tb.v
    │   │
    │   ├───RX/
    │   │       RXshift_tb.v
    │   │       RXtop_tb.v
    │   │
    │   └───TX/
    │           TXshift_tb.v
    │           TXtop_tb.v
    │
    └───VCD/
        │   clk_divider.vcd
        │   uart.vcd
        │   uart_timer.vcd
        │
        ├───RX/
        │       RXshift.vcd
        │       RXtop.vcd
        │
        └───TX/
                TXshift.vcd
                TXtop.vcd
```
## Verification
To be updated

## Simulation Results
To be updated

## LinkedIn Series
