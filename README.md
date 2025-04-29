## Time-Card-Flex

Upstream and relevants: [Open Compute Project Time-Applicance-Project](https://github.com/opencomputeproject/Time-Appliance-Project)  [Forked](https://github.com/regymm/Time-Appliance-Project)
PTP gateware running on the OCP-TAP Time Card and more. PTP grandmaster clock at home. Aiming at a fully-open-source & affordable timing infrastructure! 

[TimeCard gateware all-verilog](FPGA/Targets/TimeCard_Verilog) -- this works with default Linux kernel ptp_ocp driver. 
[TimeCard gateware with no vendor (Xilinx) IPs](FPGA/Targets/TimeCard_NoVendIPs) -- recommended to start here! 

[Setup and Usage](DOC/Setup_and_Usage.md): full development flow from building firmware to comparing PPS edges. 

 ### Funding

 This project received funding through [NGI0 Entrust](https://nlnet.nl/entrust), a fund established by [NLnet](https://nlnet.nl) with financial support from the European Commission's [Next Generation Internet](https://ngi.eu) program. Learn more at the [NLnet project page](https://nlnet.nl/project/PTP-timingcard-gateware).

 [<img src="https://nlnet.nl/logo/banner.png" alt="NLnet foundation logo" width="20%" />](https://nlnet.nl) [<img src="https://nlnet.nl/image/logos/NGI0_tag.svg" alt="NGI Zero Logo" width="20%" />](https://nlnet.nl/entrust)
