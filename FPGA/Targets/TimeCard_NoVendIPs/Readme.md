# Open Source Timecard Design Description

## No Vendor IP Release

This is a no vendor IP release of the Timecard project. No Xilinx proprietary IP is used. Open-source alternatives are used. The block design is got rid of, and a python-based bus wiring helper is WIP. 

Upstream repo: [Time-Card](https://github.com/Time-Appliances-Project/Time-Card). AXI interconnects that just work: [ZipCPU](https://github.com/ZipCPU/wb2axip/)

The `CreateProject.tcl` can be run to create the project, and run synthesis/implementation to generate bitstream. The bitstream was tested on the [OCP-TAP Time Card](https://www.makerfabs.com/ocp-tap-time-card.html). 

This work is kindly sponsored by the [NGI ZERO Entrust fund](https://nlnet.nl/project/PTP-timingcard-gateware/). 

One future plan of this project is to integrate an on-board 10/100/1000M ethernet PHY (or 10 Gbps requires no external PHY), and implement PTP-capable ethernet MAC, as a standalone PTP grandmaster clock. Seems NetTimeLogic [has PMOD ethernet module support in progress](https://www.linkedin.com/posts/nettimelogic-gmbh_fpga-vhdl-embeddedsystems-activity-7318288811707318272-zVQb). 

## Contents

[1. Design Overview](#1-design-overview)

[2. Address Mapping](#2-address-mapping)

[3. Interrupt Mapping](#3-interrupt-mapping)

[4. SMA Connectors](#4-sma-connectors)

[5. Status LEDs](#5-status-leds)

[6. Default Configuration](#6-default-configuration)

[7. Core List](#7-core-list)

[8. Create FPGA project and binaries](#8-create-fpga-project-and-binaries)

[9. Program FPGA and SPI Flash](#9-program-fpga-and-spi-flash)

## 1. Design Overview

The original Open Source Timecard design includes open-source IP cores from [NetTimeLogic](https://www.nettimelogic.com/) and free-to-use IP cores from [Xilinx](https://www.xilinx.com/).
The following cores are used in the Open Source Timecard design.

|Core|Vendor|Description|
|----|:----:|-----------|
|[pcie_7x](https://github.com/regymm/pcie_7x) |regymm|Interface between the AXI4 Lite interface and the Gen2 PCI Express (PCIe) silicon hard core|
|[AXI GPIO](https://www.xilinx.com/products/intellectual-property/axi_gpio.html) |regymm|General purpose input/output interface to AXI4-Lite|
|[AXI UART 16550](../../IPs_3rdParty/Axi16550)|regymm|Interface between AXI4-Lite and UART interface|
|[AXI Odds and Ends](https://github.com/ZipCPU/wb2axip/) |ZipCPU|AXI Crossbar, AXI clock domain crossing|
|[MMCM](../../IPs_3rdParty/Xc7Mmcm) |regymm|Configuration of a clock circuit to user requirements|
|[Processor System Reset](../../IPs_3rdParty/PSReset) |regymm|Setting certain parameters to enable/disable features|
|[TC Adj. Clock](../../../Ips/AdjustableClock/)|NetTimeLogic|A timer clock in the Second and Nanosecond format that can be frequency and phase adjusted|
|[TC Signal Timestamper](../../../Ips/SignalTimestamper)|NetTimeLogic|Timestamping of an event signal of configurable polarity and generate interrupts|
|[TC PPS Generator](../../../Ips/PpsGenerator)|NetTimeLogic|Generation of a Pulse Per Second (PPS) of configurable polarity and aligned to the local clock's new second|
|[TC Signal Generator](../../../Ips/SignalGenerator)|NetTimeLogic|Generation of pulse width modulated (PWM) signals of configurable polarity and aligned to the local clock|
|[TC PPS Slave](../../../Ips/PpsSlave)|NetTimeLogic|Calculation of the offset and drift corrections to be applied to the Adjustable Clock, in order to synchronize to a PPS input|
|[TC ToD Slave](../../../Ips/TodSlave)|NetTimeLogic|Reception of GNSS receiver's messages over UART and synchronization to the Time of Day|
|[TC Frequency Counter](../../../Ips/FrequencyCounter)| NetTimeLogic|Measuring of the frequency of an input signal of range 1 - 10'000'000 Hz|
|[TC CoreList](../../../Ips/CoreList)|NetTimeLogic|A list of the current FPGA core instantiations which are accessible by an AXI4-Lite interface|
|[TC Conf Master](../../../Ips/ConfMaster)|NetTimeLogic|A default configuration which is provided to the AXI4-Lite slaves during startup, without the support of a CPU|
|[TC MsiIrq](../../../Ips/MsiIrq)|NetTimeLogic|Forwarding single interrupts as Message-Signaled Interrupts the [AXI-PCIe bridge](https://www.xilinx.com/products/intellectual-property/axi_pcie.html)|
|[TC Clock Detector](../../../Ips/ClockDetector)|NetTimeLogic|Detection of the available clock sources and selection of the clocks to be used, according to a priority scheme and a configuration|
|[TC SMA Selector](../../../Ips/SmaSelector)|NetTimeLogic|Select the mapping of the inputs and the outputs of the 4 SMA connectors of the [Timecard](https://github.com/opencomputeproject/Time-Appliance-Project/tree/master/Time-Card)|
|[TC PPS Selector](../../../Ips/PpsSourceSelector)|NetTimeLogic|Detection of the available PPS sources and selection of the PPS source to be used, according to a priority scheme and a configuration|
|[TC Communication Selector](../../../Ips/CommunicationSelector)|NetTimeLogic|Selection of the clock's communication interface (UART or I<sup>2</sup>C)|
|[TC Dummy Axi Slave](../../../Ips/DummyAxiSlave)|NetTimeLogic|AXI4L slave that is used as a placeholder of an address range|
|[TC FPGA Version](../../../Ips/FpgaVersion)|NetTimeLogic|AXI register that stores the design's version numbers|

The TimeCard runs partially from the 200MHz SOM oscillator. 
The NetTimeLogic cores with all the high precision parts are running based on the selected clock by the Clock Detector (10 MHz from MAC, SMA, etc.).

## 2. Address Mapping
The design's cores are accessible via AXI4 Light Memory Mapped slave interfaces for configuration and reporting. 
The AXI slave interfaces are accessed via the AXI interconnect by 2 AXI masters:
- [TC ConfMaster](../../../Ips/ConfMaster) provides a default configuration to the cores after a reset. The default configuration can be changed at compilation time.
- [AXI PCIe](https://www.xilinx.com/products/intellectual-property/axi_pcie.html) provides full bridge functionality between the AXI4 architecture and the PCIe network. 
Typically, a CPU is connected to the timecard via this PCIe interface. 

The AXI Slave interfaces have the following addresses:

|Slave|AXI Slave interface|Offset Address|High Address|
|-----|-------------------|--------------|------------|
|TC FPGA Version|axi4l_slave|0x0002_0000|0x0002_0FFF|
|AXI GPIO Ext|S_AXI|0x0010_0000|0x0010_0FFF|
|AXI GPIO GNSS/MAC|S_AXI|0x0011_0000|0x0011_0FFF|
|TC Clock Detector|axi4l_slave|0x0013_0000|0x0013_0FFF|
|TC SMA Selector|axi4l_slave1|0x0014_0000|0x0014_3FFF|
|AXI UART 16550 GNSS1|S_AXI|0x0016_0000|0x0016_FFFF|
|AXI UART 16550 GNSS2|S_AXI|0x0017_0000|0x0017_FFFF|
|AXI UART 16550 MAC|S_AXI|0x0018_0000|0x0018_FFFF|
|AXI UART 16550 ΕΧΤ|S_AXI|0x001Α_0000|0x001Α_FFFF|
|TC SMA Selector|axi4l_slave2|0x0022_0000|0x0022_3FFF|
|TC Adj. Clock|axi4l_slave|0x0100_0000|0x0100_FFFF|
|TC Signal TS GNSS1 PPS|axi4l_slave|0x0101_0000|0x0101_FFFF|
|TC Signal TS1|axi4l_slave|0x0102_0000|0x0102_FFFF|
|TC PPS Generator|axi4l_slave|0x0103_0000|0x0103_FFFF|
|TC PPS Slave|axi4l_slave|0x0104_0000|0x0104_FFFF|
|TC ToD Slave|axi4l_slave|0x0105_0000|0x0105_FFFF|
|TC Signal TS2|axi4l_slave|0x0106_0000|0x0106_FFFF|
|TC Dummy Axi Slave1|axi4l_slave|0x0107_0000|0x0107_FFFF|
|TC Dummy Axi Slave2|axi4l_slave|0x0108_0000|0x0108_FFFF|
|TC Dummy Axi Slave3|axi4l_slave|0x0109_0000|0x0109_FFFF|
|TC Dummy Axi Slave4|axi4l_slave|0x010A_0000|0x010A_FFFF|
|TC Dummy Axi Slave5|axi4l_slave|0x010B_0000|0x010B_FFFF|
|TC Signal TS FPGA PPS|axi4l_slave|0x010C_0000|0x010C_FFFF|
|TC Signal Generator1|axi4l_slave|0x010D_0000|0x010D_FFFF|
|TC Signal Generator2|axi4l_slave|0x010E_0000|0x010E_FFFF|
|TC Signal Generator3|axi4l_slave|0x010F_0000|0x010F_FFFF|
|TC Signal Generator4|axi4l_slave|0x0110_0000|0x0110_FFFF|
|TC Signal TS3|axi4l_slave|0x0111_0000|0x0111_FFFF|
|TC Signal TS4|axi4l_slave|0x0112_0000|0x0112_FFFF|
|TC Frequency Counter 1|axi4l_slave|0x0120_0000|0x0120_FFFF|
|TC Frequency Counter 2|axi4l_slave|0x0121_0000|0x0121_FFFF|
|TC Frequency Counter 3|axi4l_slave|0x0122_0000|0x0122_FFFF|
|TC Frequency Counter 4|axi4l_slave|0x0123_0000|0x0123_FFFF|
|TC CoreList|axi4l_slave|0x0130_0000|0x0130_FFFF|

The detailed register description of each instance is available at the corresponding core description document (see links at [Chapter 1](#1-design-overview)). Mostly, 0x00xx_xxxx peripherals runs in system 50 MHz clock domain, and 0x01xx_xxxx peripherals runs in the PTP 50 MHz clock domain. 

### 2.1 FPGA Version Register

The Version Slave has one single 32-Bit Register. 
The upper 16 Bits show the version number of the golden image and the lower 16 Bits the version number of the regular image.
E.g.:

- Register 0x0200_0000 of the Golden image shows: 0x0001_0000
- Register 0x0200_0000 of the Regular image shows: 0x0000_0003

If the lower 16 Bits are 0x0000 the Golden image has booted.

This No Vendor IP release has version 0x0000000a. 

### 2.2 AXI GPIO Registers

The implementation uses two instantiations of the [AXI GPIO](https://www.xilinx.com/products/intellectual-property/axi_gpio.html) IP. 

The mapping of the AXI GPIO Ext is as below

![AXI_GPIO_Ext](Additional%20Files/AXI_GPIO_Ext.png)

The mapping of the AXI GPIO GNSS/MAC is as below

![AXI_GPIO_GNSS_MAC](Additional%20Files/AXI_GPIO_GNSS_MAC.png)

## 3. Interrupt Mapping
The interrupts in the design are connected to the MSI Vector of the AXI Memory Mapped to PCI Express Core via a MSI controller. 
The PCI Express Core needs to set the MSI_enable to ‘1’. 
The MSI controller sends INTX_MSI Request with the MSI_Vector_Num to the PCI Express Core and with the INTX_MSI_Grant the interrupt is acknowledged. 
If there are several interrupts pending, the messages are sent with the round-robin principle. 
Level interrupts (e.g. AXI UART 16550) are taking at least one round for the next interrupt.

|MSI Number|Interrupt Source|
|----------|----------------|
|0|TC Signal TS FPGA PPS|
|1|TC Signal TS GNSS1 PPS|
|2|TC Signal TS1|
|3|AXI UART 16550 GNSS1|
|4|AXI UART 16550 GNSS2|
|5|AXI UART 16550 MAC or AXI I<sup>2</sup>C OSC|
|6|TC Signal TS2|
|7| Reserved                                     |
|8| Reserved                                     |
|9|AXI Quad SPI Flash|
|10|Reserved|
|11|TC Signal Generator1|
|12|TC Signal Generator2|
|13|TC Signal Generator3|
|14|TC Signal Generator4|
|15|TC Signal TS3|
|16|TC Signal TS4|
|17|Reserved|
|18|Reserved|
|19|AXI UART 16550 Ext|

## 4. SMA Connectors
The [Timecard](https://github.com/opencomputeproject/Time-Appliance-Project/tree/master/Time-Card) has currently 4 SMA Connectors of configurable input/output and an additional GNSS Antenna SMA input.
The default configuration of the SMA connectors is shown below.

<p align="left"> <img src="Additional%20Files/SmaConnectors.png" alt="Sublime's custom image"/> </p>

This default mapping and the direction can be changed via the 2 AXI slaves of the [TC SMA Selector](../../../Ips/SmaSelector) IP core. 

## 5. Status LEDs
At the current design, the Status LEDs are not connected to the AXI GPIO Ext and they are used directly by the FPGA.

- LED1: Alive LED of the FPGA internal Clock (50MHz)
- LED2: Alive LED of the PCIe clocking part (62.5MHz)
- LED3: PPS of the FPGA (Time of the Local Clock via PPS Master)
- LED4: PPS of the MAC (differential inputs from the MAC via diff-buffer)

## 6. Default Configuration 

The default configuration is provided by the [TC ConfMaster](../../../Ips/ConfMaster) and can be edited by updating the [DefaultConfigFile.txt](DefaultConfigFile.txt).
Currently, the following cores are configured at startup by the default configuration file. 

|Core Instance|Configuration|
|-------------|-------------|
|Adjustable Clock|Enable with synchronization source 1 (ToD+PPS)|
|PPS Generator|Enable with high polarity of the output pulse|
|PPS Slave|Enable with high polarity of the input pulse|
|ToD Slave|Enable with high polarity of the UART input|
|SMA Selector|Set the FPGA PPS (SMA3) and GNSS PPS (SMA4) as SMA outputs|


## 7. Core List 
The list of the configurable cores (via AXI) is provided by the [TC CoreList](../../../Ips/CoreList) and can be edited by updating the [CoreListFile.txt](CoreListFile.txt).
