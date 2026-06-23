# DMA controller
The DMA controller has two channels partially hardwired for RX and TX of UART. Each channel has an 8 state FSM that handles the data transfer on RX and TX interrupts.
The addr_mng module for each channel is instantiated inside RX/TXchannel. This module handles the address from which data needs to be read/written. This circuit is controlled
by the channel module.
