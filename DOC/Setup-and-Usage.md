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

​	`sudo ntpd -qg` result: `ntpd: time set -36.999634s`. Seems NTP is also quite accurate (usually 1-5 ms). I'm using a wired ethernet with 5 ms ping to google.com. 

​	Check GPS status: `sudo gpsd /dev/ttyS4 -s 115200 && sudo cgps`. 

​	*Warning:* posting a CGPS screenshot might reveal accurate location. Even with Lat/Long info deleted, location might still be retrievable by the list of satellites Elev/Azim info. 

**d.** (need scope) Compare GNSS PPS and PHC PPS. These two should be very close (~10 ns on my setup) when stabilized. ZED-F9T used on Time Card specs a < 5 ns RMS, under clear sky. 

​	`echo OUT: PHC >> /sys/class/timecard/ocp0/sma1`

​	`echo OUT: GNSS1 >> /sys/class/timecard/ocp0/sma2`

​	Disconnect GPS antenna, GNSS1 PPS will disappear after a while. Connect back antenna, PPS signal will appear after a while, jumping near the PHC PPS a while, and become (relatively) stable again. When GPS signal is lost, PHC PPS is maintained by local OCXO or atomic clock (holdover). A good holdover is like 1.5-8 us per day, probably not on this setup. 

*Ref:* 

https://www.jeffgeerling.com/blog/2021/time-card-and-ptp-on-raspberry-pi-compute-module-4

https://github.com/Time-Appliances-Project/Time-Card/tree/master/TEST/TimeCardTests

*Reminder:* 

Be careful which /dev/ptpX is which! 

GNSS modules use active antenna. The SMA pin also sends power. Buy a real antenna as a makeshift wiring won't work. 

It's quite amazing that such a complicated GNSS is interfaced by only 3 pins, with 2 of them being slow UART. The other is PPS output with a sharp rising edge aligned to second boundary from atomic clocks flying on satellites -- this is where everything begins. 

Fun fact is Rubidium clocks are install on satellites, and they are synced with Caesium clocks on ground every day or two. So in case of apocalypse when GPS, etc. lost maintenance, accurate positioning might be gone in a few days. 

### 3. PTP time sync with Raspberry Pi 5 

**Time Card Server:** 

Copy Time Card PTP source to Ethernet card PTP sink

```
❯ sudo phc2sys -c /dev/ptp0 -s /dev/ptp5  -O0 -m
phc2sys[4606.672]: /dev/ptp0 phc offset 620257191 s0 freq      -0 delay  18272
phc2sys[4607.672]: /dev/ptp0 phc offset 620230204 s1 freq  -26978 delay  18256
phc2sys[4608.672]: /dev/ptp0 phc offset     -7602 s2 freq  -34580 delay  18272
phc2sys[4609.672]: /dev/ptp0 phc offset        94 s2 freq  -29165 delay  18353
phc2sys[4610.673]: /dev/ptp0 phc offset      2321 s2 freq  -26909 delay  18208
phc2sys[4611.673]: /dev/ptp0 phc offset      2291 s2 freq  -26243 delay  18289
phc2sys[4612.673]: /dev/ptp0 phc offset      1503 s2 freq  -26344 delay  18304
phc2sys[4613.674]: /dev/ptp0 phc offset       996 s2 freq  -26400 delay  18288
phc2sys[4614.674]: /dev/ptp0 phc offset       354 s2 freq  -26743 delay  18305
phc2sys[4615.674]: /dev/ptp0 phc offset       247 s2 freq  -26744 delay  18289
phc2sys[4616.675]: /dev/ptp0 phc offset        44 s2 freq  -26873 delay  18304
phc2sys[4617.675]: /dev/ptp0 phc offset        33 s2 freq  -26871 delay  18337
phc2sys[4618.675]: /dev/ptp0 phc offset       -67 s2 freq  -26961 delay  18320
phc2sys[4619.675]: /dev/ptp0 phc offset       -36 s2 freq  -26950 delay  18289
```

Launch PTP Server: 

```
❯ sudo ptp4l -i eno1 --masterOnly 1 -m --tx_timestamp_timeout 200  
option masterOnly is deprecated, please use serverOnly instead
ptp4l[4696.121]: selected /dev/ptp0 as PTP clock
ptp4l[4696.122]: port 1 (eno1): INITIALIZING to LISTENING on INIT_COMPLETE
ptp4l[4696.122]: port 0 (/var/run/ptp4l): INITIALIZING to LISTENING on INIT_COMPLETE
ptp4l[4696.123]: port 0 (/var/run/ptp4lro): INITIALIZING to LISTENING on INIT_COMPLETE
ptp4l[4696.123]: port 1 (eno1): link down
ptp4l[4696.123]: port 1 (eno1): LISTENING to FAULTY on FAULT_DETECTED (FT_UNSPECIFIED)
ptp4l[4696.123]: selected local clock xxxxxx.xxxx.xxxxxx as best master
ptp4l[4696.123]: port 1 (eno1): assuming the grand master role
```

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

```
❯ sudo ts2phc -c eno1 -m -s generic -l 7 -f ts2phc_i210.conf 
ts2phc[7527.535]: config item (null).sa_file is '(null)'
ts2phc[7527.535]: config item eno1.ts2phc.master is 0
ts2phc[7527.535]: config item eno1.ts2phc.pin_index is 1
ts2phc[7527.535]: config item eno1.ts2phc.channel is 0
ts2phc[7527.535]: config item eno1.ts2phc.extts_polarity is 6
ts2phc[7527.535]: config item eno1.ts2phc.extts_correction is 1
ts2phc[7527.535]: config item eno1.ts2phc.pulsewidth is 100000000
ts2phc[7527.535]: config item (null).clock_servo is 0
ts2phc[7527.535]: config item (null).pi_proportional_const is 0.000000
ts2phc[7527.535]: config item (null).pi_integral_const is 0.000000
ts2phc[7527.535]: config item (null).pi_proportional_scale is 0.000000
ts2phc[7527.535]: config item (null).pi_proportional_exponent is -0.300000
ts2phc[7527.535]: config item (null).pi_proportional_norm_max is 0.700000
ts2phc[7527.535]: config item (null).pi_integral_scale is 0.000000
ts2phc[7527.535]: config item (null).pi_integral_exponent is 0.400000
ts2phc[7527.535]: config item (null).pi_integral_norm_max is 0.300000
ts2phc[7527.535]: config item (null).step_threshold is 0.050000
ts2phc[7527.535]: config item (null).first_step_threshold is 0.000020
ts2phc[7527.535]: config item (null).max_frequency is 1000000
ts2phc[7527.535]: config item (null).servo_offset_threshold is 0
ts2phc[7527.535]: config item (null).servo_num_offset_values is 10
ts2phc[7527.535]: PI servo: sync interval 1.000 kp 0.700 ki 0.300000
ts2phc[7527.535]: config item (null).free_running is 0
ts2phc[7527.535]: PPS sink eno1 has ptp index 0
ts2phc[7527.535]: UTC-TAI offset not set in system! Trying to revert to leapfile
ts2phc[7527.535]: config item (null).leapfile is '/usr/share/zoneinfo/leap-seconds.list'
ts2phc[7527.535]: config item (null).ts2phc.holdover is 0
ts2phc[7527.572]: adding tstamp 1745856080.999997590 to clock /dev/ptp0
ts2phc[7527.572]: /dev/ptp0 offset      -2410 s0 freq  -26612
ts2phc[7528.073]: eno1 SKIP extts index 0 at 1745856081.499997735 src 1745856081.500412547
ts2phc[7528.573]: adding tstamp 1745856081.999997514 to clock /dev/ptp0
ts2phc[7528.573]: /dev/ptp0 offset      -2486 s2 freq  -26688
ts2phc[7529.073]: eno1 SKIP extts index 0 at 1745856082.499997696 src 1745856082.500454404
ts2phc[7529.573]: adding tstamp 1745856082.999997505 to clock /dev/ptp0
ts2phc[7529.573]: /dev/ptp0 offset      -2495 s2 freq  -29183
ts2phc[7530.073]: eno1 SKIP extts index 0 at 1745856083.499998933 src 1745856083.500597002
ts2phc[7530.573]: adding tstamp 1745856083.999999998 to clock /dev/ptp0
ts2phc[7530.573]: /dev/ptp0 offset         -2 s2 freq  -27439
ts2phc[7531.073]: eno1 SKIP extts index 0 at 1745856084.500000557 src 1745856084.500619077
ts2phc[7531.573]: adding tstamp 1745856085.000000741 to clock /dev/ptp0
ts2phc[7531.573]: /dev/ptp0 offset        741 s2 freq  -26696
ts2phc[7532.073]: eno1 SKIP extts index 0 at 1745856085.500000928 src 1745856085.500596467
```

Half of timestamps are SKIP-ed, somehow because i210 always stamps on both edges. 

Now, I can reach **~20 ns** between Time Card PPS and i210 on Raspberry Pi PPS, wired by a ordinary Ethernet cable. Probably, **PCIe PTM** is required for further accuracy. 

![](IMG/RPI5.png)

*Ref:* 

https://wiki.millerjs.org/pps2sdp

https://linuxptp.nwtime.org/documentation/configs/ts2phc-generic/

### 5. Using latest devices: Raspberry Pi CM5

Server setup is same as in **3.** or **4.**

It's similar with RPi 5, but we're using on-board Ethernet PHY. 

Kernel version 6.12 recommended by jclark: `Linux raspberrypicm5 6.12.15-v8-16k+ #1856 SMP PREEMPT Wed Feb 19 14:26:04 GMT 2025 aarch64 GNU/Linux`

PTP client, similarly: 

```
pi@raspberrypicm5:~ $ sudo ptp4l -i eth0 --slaveOnly 1 -m --tx_timestamp_timeout 200
ptp4l[103.132]: selected /dev/ptp0 as PTP clock
ptp4l[103.138]: port 1: INITIALIZING to LISTENING on INIT_COMPLETE
ptp4l[103.138]: port 0: INITIALIZING to LISTENING on INIT_COMPLETE
ptp4l[103.154]: port 1: new foreign master xxxxxx.xxxx.xxxxxx-1
ptp4l[107.155]: selected best master clock xxxxxx.xxxx.xxxxxx
ptp4l[107.155]: port 1: LISTENING to UNCALIBRATED on RS_SLAVE
ptp4l[109.180]: master offset -1745853334380728920 s0 freq      +0 path delay      4035
ptp4l[110.187]: master offset -1745853334380738871 s1 freq   -9945 path delay      4252
ptp4l[111.183]: master offset   -4792047 s2 freq -4801992 path delay      4252
ptp4l[111.183]: port 1: UNCALIBRATED to SLAVE on MASTER_CLOCK_SELECTED
ptp4l[112.183]: master offset      -1888 s2 freq -1449448 path delay      4252
ptp4l[113.184]: master offset    1441219 s2 freq   -6907 path delay      4035
ptp4l[114.184]: master offset    1441114 s2 freq +425354 path delay      2312
ptp4l[115.185]: master offset    1006014 s2 freq +422588 path delay      2312
ptp4l[116.185]: master offset     571645 s2 freq +290023 path delay      4035
ptp4l[117.186]: master offset     271054 s2 freq +160926 path delay      4469
ptp4l[118.186]: master offset      98853 s2 freq  +70041 path delay      5621
ptp4l[119.186]: master offset      19968 s2 freq  +20812 path delay      4469
ptp4l[120.187]: master offset     -11972 s2 freq   -5138 path delay      5621
ptp4l[121.188]: master offset     -16791 s2 freq  -13548 path delay      5621
ptp4l[122.188]: master offset     -12647 s2 freq  -14442 path delay      5081
ptp4l[123.189]: master offset      -8181 s2 freq  -13770 path delay      5081
ptp4l[124.189]: master offset      -4419 s2 freq  -12462 path delay      5081
```

PPS Out: 

```
pi@raspberrypicm5:~/testptp $ sudo ./testptp -d /dev/ptp0 -p 1000000000 -L 0,2 -w 4095
set pin function okay
periodic output request okay
```

The CM5 has a notoriously short ~4us pulse, during debug, I need to trigger using this pulse just to know it's there. 

*Ref:*

https://github.com/jclark/rpi-cm4-ptp-guide/issues/39

https://forums.raspberrypi.com/viewtopic.php?t=380887
