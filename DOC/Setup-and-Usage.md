## Time-Card-Flex Setup and Usage

### 1. OCP-TAP Time Card bitstream and driver building

**a.** FPGA bitstream. Clone this repo. 

```
cd FPGA/Targets/TimeCard_NoVendIPs
source /opt/Xilinx/Vivado/2023.2/settings64.sh
vivado -mode batch -source TimeCard_NoVendIPs.tcl
```

​	Bitstream will be built at `TimeCard_NoVendIPs/TimeCard_NoVendIPs.runs/impl_1/TimeCardTop.bit` 

​	Program bitstream with Hardware Manager, OpenFPGALoader, or program it to QSPI Flash on board. 

**b.** Kernel driver. Clone the repo on target machine with Time Card installed. 

*Reminder:* 

Don't plug-and-play PCIe drivers. Reboot the machine instead. 

### 2.  Time Card standalone verification

**a.** Basic verification of the Time Card's GPS and SMA can be refered in [Verification Procedure given by OCP-TAP](./OCP-TAP/TimeCard_VerificationProcedure_8-24-2023.docx). The folder also contains firmware flashing guides for GNSS module and the TimeCard's FPGA. Output details will differ, but commands to run are the same. 

**b.** PCIe Memory-mapped AXI test using the ocp-tap-bar-mem.c: 

​	`sudo setpci -s 26:00.0 COMMAND=0x02`

​	`gcc ocp-tap-bar-mem.c && sudo ./a.out`

​	Check the AXI interconnects are working properly, and register contents of peripherals are correct. 

**c.** Sync to system clock, and verify with (low-accuracy) NTP. 

```
❯ sudo phc2sys -c CLOCK_REALTIME -s /dev/ptp5 -O0 -m  
phc2sys[161.411]: CLOCK_REALTIME phc offset 745346006 s0 freq      -0 delay   3143
phc2sys[162.412]: CLOCK_REALTIME phc offset 745346097 s1 freq     +91 delay   3133
phc2sys[163.413]: CLOCK_REALTIME phc offset        35 s2 freq    +126 delay   3123
phc2sys[164.413]: CLOCK_REALTIME phc offset       -30 s2 freq     +71 delay   3123
phc2sys[165.414]: CLOCK_REALTIME phc offset        24 s2 freq    +116 delay   3123
phc2sys[166.415]: CLOCK_REALTIME phc offset       -16 s2 freq     +84 delay   3113
phc2sys[167.416]: CLOCK_REALTIME phc offset        -9 s2 freq     +86 delay   3103
phc2sys[168.416]: CLOCK_REALTIME phc offset       -11 s2 freq     +81 delay   3083
phc2sys[169.417]: CLOCK_REALTIME phc offset        32 s2 freq    +121 delay   3113
```

​	This direct sync from /dev/ptpX is TAI time, differing 37s from UTC. As leap second is being deprecated, this 37s might never change again. Last leap second was in 2017. 懐かしいなぁ

​	`sudo ntpd -qg` result: `ntpd: time set -36.999634s`. Seems NTP is also quite accurate. I'm using a wired ethernet with 5ms ping to google.com. 

​	Check GPS status: `sudo gpsd /dev/ttyS4 -s 115200 && sudo cgps`. 

​	*Warning:* posting a CGPS screenshot might reveal accurate location. Even with Lat/Long info deleted, location might still be retrievable by the list of satellites Elev/Azim info. 

**d.** (need scope) Compare GNSS PPS and PHC PPS. These two should be very close (~10 ns on my setup) when stabilized. ZED-F9T used on Time Card specs a < 5 ns RMS, under clear sky.  

​	`echo OUT: PHC >> /sys/class/timecard/ocp0/sma1`

​	`echo OUT: GNSS1 >> /sys/class/timecard/ocp0/sma2`

​	Disconnect GPS antenna, GNSS1 PPS will disappear after a while. Connect back antenna, PPS signal will appear after a while, jumping near the PHC PPS a while, and become (relatively) stable again. When GPS signal is lost, PHC PPS is maintained by local OCXO or atomic clock (holdover). A good holdover is like 1.5-8 us per day. 

*Ref:* 

https://www.jeffgeerling.com/blog/2021/time-card-and-ptp-on-raspberry-pi-compute-module-4

https://github.com/Time-Appliances-Project/Time-Card/tree/master/TEST/TimeCardTests

*Reminder:* 

Be careful which /dev/ptpX is which! 

GNSS modules use active antenna. The SMA pin also sends power. Buy a real antenna as a makeshift wiring won't work. 

It's quite amazing that such a complicated GNSS is interfaced by only 3 pins, with 2 of them being slow UART. The other is PPS output with a sharp rising edge aligned to second boundary from atomic clocks flying on satellites -- this is where everything begins. 

Fun fact is Rubidium clocks are install on satellites, and they are synced with Caesium clocks on ground once a while. So in case of apocalypse when GPS, etc lost maintenance, accurate positioning might be gone in a few days. 

### 3. PTP time sync with Raspberry Pi 5 

**Time Card Server:** 

Copy Time Card PTP source to Ethernet card PTP sink: `sudo phc2sys -c /dev/ptp0 -s /dev/ptp5  -O0 -m`

Launch PTP Server: `sudo ptp4l -i eno1 --masterOnly 1 -m --tx_timestamp_timeout 200`

**RPi or other client:** 

Launch PTP client: `sudo ptp4l -i enp1s0 --slaveOnly 1 -m --tx_timestamp_timeout 200`

Sync from ethernet card PTP source to system clock: `sudo phc2sys -c CLOCK_REALTIME -s /dev/ptp0 -O-37 -m`

In case of Intel i210, PPS out on ethernet card can be turned on as: `sudo ./testptp -d /dev/ptp0 -L 1,2 -p 1000000000`

Card front view, Ground Pin: Left Top, SDP1 Pin: Right Middle. 

**Verify**

**a.** On RPi, a `sudo ntpd -qg` NTP sync shows millisecond-level correct time. 

**b.** Comparing falling edge of i210 on RPi, and PHC PPS from Time Card shows microsecond-level accuracy (~2 us in my setup). 

**c.** Where's the 2 us coming from? 

*Ref:*

https://www.jeffgeerling.com/blog/2022/ptp-and-ieee-1588-hardware-timestamping-on-raspberry-pi-cm4

https://www.erp5.com/rapidspace-Document.Blog.ORS.PPS.Experiment 

### 4. Nanosecond accuracy PTP grandmaster clock

Connect PHC PPS out to Intel i210 SPD1 input. This is the canonical way grandmaster clock servers. 

Instead of `phc2sys` coping between PTP clocks over PC software, use: 

`sudo ts2phc -c eno1 -m -s generic -l 7 -f ts2phc_i210.conf` to directly sync from Time Card to Ethernet card by PPS. Each Ethernet card has its own configuration, this is for i210. 

```
❯ cat ts2phc_i210.conf
[global]
use_syslog              0
verbose                 1
logging_level           6
ts2phc.pulsewidth       100000000
max_frequency           1000000
step_threshold          0.05
leapfile                /usr/share/zoneinfo/leap-seconds.list
[eno1]
ts2phc.extts_polarity   both
ts2phc.channel          0
ts2phc.pin_index        1
ts2phc.extts_correction 1
```



*Ref:* 

https://wiki.millerjs.org/pps2sdp

https://linuxptp.nwtime.org/documentation/configs/ts2phc-generic/

### 5. Using latest devices: Raspberry Pi CM5

*Ref:*

https://github.com/jclark/rpi-cm4-ptp-guide/issues/39

https://forums.raspberrypi.com/viewtopic.php?t=380887
