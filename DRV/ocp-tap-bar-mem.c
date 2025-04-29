#include "stdio.h"
#include "stdlib.h"
#include "sys/stat.h"
#include "sys/types.h"
#include "sys/mman.h"
#include "fcntl.h"

int main()
{
	int fd = open("/sys/bus/pci/devices/0000:25:00.0/resource0", O_RDWR | O_SYNC);
	if (fd < 0) {
		perror ("Opening of BAR not possible!");
		return -1;
	}
	void* base_address = (void*)0xfa000000;
	size_t size = 32 * 1024 * 1024; // 32 M
	void* void_memory = mmap(0,
				 size,
				 PROT_READ | PROT_WRITE,
				 MAP_SHARED,
				 fd,
				 0);
	if (void_memory == MAP_FAILED) {
		perror("mmapping BAR failed!");
	}

	int* memory_ver = (int*)(void_memory + 0x00020000);
	printf("Ver: %08x\n", *memory_ver);

	int* memory_todslave= (int*)(void_memory + 0x01050000);
	/*memory_todslave[0x20/4] = 0x6;*/
	/*memory_todslave[0x0/4] = 0x0;*/
	/*memory_todslave[0x0/4] = 0x1;*/
	printf("todslave: enablecontrol: %08x\n", memory_todslave[0x0/4]);
	printf("todslave: errorstatus: %08x\n", memory_todslave[0x4/4]);
	printf("todslave: uartpolarity: %08x\n", memory_todslave[0x8/4]);
	printf("todslave: version: %08x\n", memory_todslave[0xC/4]);
	printf("todslave: correction: %08x\n", memory_todslave[0x10/4]);
	printf("todslave: uartbaudrate: %08x\n", memory_todslave[0x20/4]);
	printf("todslave: utcstatus: %08x\n", memory_todslave[0x30/4]);
	printf("todslave: timetoleap: %08x\n", memory_todslave[0x34/4]);
	printf("todslave: attennastatus: %08x\n", memory_todslave[0x40/4]);
	printf("todslave: satellitenumber: %08x\n", memory_todslave[0x44/4]);
	/*return 0;*/
	int* memory_1 = (int*)(void_memory + 0x001a0000);
	printf("axi_uart16550_ext: %08x\n", memory_1[0]);
	printf("axi_uart16550_ext: %08x\n", memory_1[1]);
	printf("axi_uart16550_ext: %08x\n", memory_1[2]);
	printf("axi_uart16550_ext: %08x\n", memory_1[3]);
	int* memory_2 = (int*)(void_memory + 0x00100000);
	printf("axi_gpio_ext: %08x\n", memory_2[0]);
	printf("axi_gpio_ext: %08x\n", memory_2[1]);
	printf("axi_gpio_ext: %08x\n", memory_2[2]);
	printf("axi_gpio_ext: %08x\n", memory_2[3]);
	int* memory_3 = (int*)(void_memory + 0x00110000);
	printf("axi_gpio_gnss_mac: %08x\n", memory_3[0]);
	printf("axi_gpio_gnss_mac: %08x\n", memory_3[1]);
	printf("axi_gpio_gnss_mac: %08x\n", memory_3[2]);
	printf("axi_gpio_gnss_mac: %08x\n", memory_3[3]);
	int* memory_dummy0 = (int*)(void_memory + 0x01070000);
	int* memory_dummy1 = (int*)(void_memory + 0x01080000);
	int i;
	for (i = 0; i < 0x10; i++) {
		memory_dummy0[i] = 0xabcd1234;
	}
	for (i = 0; i < 0x10; i++) {
		printf("%08x\n", memory_dummy0[i]);
	}
	for (i = 0; i < 0x10; i++) {
		memory_dummy1[i] = 0x98982323;
	}
	for (i = 0; i < 0x10; i++) {
		printf("%08x\n", memory_dummy1[i]);
	}
	int* memory_freqcounter1= (int*)(void_memory + 0x01200000);
	int* memory_freqcounter2= (int*)(void_memory + 0x01210000);
	int* memory_freqcounter3= (int*)(void_memory + 0x01220000);
	int* memory_freqcounter4= (int*)(void_memory + 0x01230000);
	memory_freqcounter1[0] = 1 + (10<<8);
	memory_freqcounter2[0] = 1 + (10<<8);
	memory_freqcounter3[0] = 1 + (10<<8);
	memory_freqcounter4[0] = 1 + (10<<8);
	printf("freqcounter1: freq: %08x\n", memory_freqcounter1[0x4/4]);
	printf("freqcounter2: freq: %08x\n", memory_freqcounter2[0x4/4]);
	printf("freqcounter3: freq: %08x\n", memory_freqcounter3[0x4/4]);
	printf("freqcounter4: freq: %08x\n", memory_freqcounter4[0x4/4]);

	int* memory_corelist = (int*)(void_memory + 0x01300000);
	for (int i = 0; i < 50; i++) {
		if (memory_corelist[(i*0x40 + 0)/4] == 0) break;
		printf("Core %d: \n", i+1);
		printf("\tType Nr\t: %08x\n", memory_corelist[(i*0x40 + 0)/4]);
		printf("\tInstance Nr\t: %08x\n", memory_corelist[(i*0x40 + 4)/4]);
		printf("\tVersion Nr\t: %08x\n", memory_corelist[(i*0x40 + 8)/4]);
		printf("\tLow addr range\t: %08x\n", memory_corelist[(i*0x40 + 12)/4]);
		printf("\tHigh addr range\t: %08x\n", memory_corelist[(i*0x40 + 16)/4]);
		printf("\tInterrupt Mask\t: %08x\n", memory_corelist[(i*0x40 + 20)/4]);
		printf("\tSensitivity Mask\t: %08x\n", memory_corelist[(i*0x40 + 24)/4]);
		printf("\tASCII 1\t: %08x\n", memory_corelist[(i*0x40 + 28)/4]);
		printf("\tASCII 2\t: %08x\n", memory_corelist[(i*0x40 + 32)/4]);
		printf("\tASCII 3\t: %08x\n", memory_corelist[(i*0x40 + 36)/4]);
		printf("\tASCII 4\t: %08x\n", memory_corelist[(i*0x40 + 40)/4]);
		printf("\tASCII 5\t: %08x\n", memory_corelist[(i*0x40 + 44)/4]);
		printf("\tASCII 6\t: %08x\n", memory_corelist[(i*0x40 + 48)/4]);
		printf("\tASCII 7\t: %08x\n", memory_corelist[(i*0x40 + 52)/4]);
		printf("\tASCII 8\t: %08x\n", memory_corelist[(i*0x40 + 56)/4]);
		printf("\tASCII 9\t: %08x\n", memory_corelist[(i*0x40 + 60)/4]);
	}

	int* memory_ppsslave = (int*)(void_memory + 0x01040000);
	printf("ppsslave: enable: %08x\n", memory_ppsslave[0x0/4]);
	printf("ppsslave: error status: %08x\n", memory_ppsslave[0x4/4]);
	printf("ppsslave: polarity: %08x\n", memory_ppsslave[0x8/4]);
	printf("ppsslave: version: %08x\n", memory_ppsslave[0xC/4]);
	printf("ppsslave: pulse width: %08x\n", memory_ppsslave[0x10/4]);
	printf("ppsslave: cable delay: %08x\n", memory_ppsslave[0x20/4]);

	int* memory_smaselector_1 = (int*)(void_memory + 0x00140000);
	int* memory_smaselector_2 = (int*)(void_memory + 0x00220000);
	printf("smaselector 1: Input Select: %08x\n", memory_smaselector_1[0x0/4]);
	printf("smaselector 1: Output Select: %08x\n", memory_smaselector_1[0x8/4]);
	printf("smaselector 1: Version: %08x\n", memory_smaselector_1[0x10/4]);
	printf("smaselector 1: Input Stat: %08x\n", memory_smaselector_1[0x2000/4]);
	printf("smaselector 2: Input Select: %08x\n", memory_smaselector_2[0x0/4]);
	printf("smaselector 2: Output Select: %08x\n", memory_smaselector_2[0x8/4]);
	printf("smaselector 2: Version: %08x\n", memory_smaselector_2[0x10/4]);

	int* memory_signal_generator_1 = (int*)(void_memory + 0x010D0000);
	int* memory_signal_generator_2 = (int*)(void_memory + 0x010E0000);
	int* memory_signal_generator_3 = (int*)(void_memory + 0x010F0000);
	int* memory_signal_generator_4 = (int*)(void_memory + 0x01100000);
	printf("signal_generator_r1: valid and enable control: %08x\n", memory_signal_generator_1[0x0/4]);
	printf("signal_generator_r2: valid and enable control: %08x\n", memory_signal_generator_2[0x0/4]);
	printf("signal_generator_r3: valid and enable control: %08x\n", memory_signal_generator_3[0x0/4]);
	printf("signal_generator_r4: valid and enable control: %08x\n", memory_signal_generator_4[0x0/4]);
	printf("signal_generator_r1: version: %08x\n", memory_signal_generator_1[0xC/4]);
	printf("signal_generator_r2: version: %08x\n", memory_signal_generator_2[0xC/4]);
	printf("signal_generator_r3: version: %08x\n", memory_signal_generator_3[0xC/4]);
	printf("signal_generator_r4: version: %08x\n", memory_signal_generator_4[0xC/4]);
	
	int* memory_adjustable_clk = (int*)(void_memory + 0x01000000);
	printf("adjustable clk: control: %08x\n", memory_adjustable_clk[0x0/4]);
	printf("adjustable clk: status: %08x\n", memory_adjustable_clk[0x4/4]);
	printf("adjustable clk: adj multiplexer sel: %08x\n", memory_adjustable_clk[0x8/4]);
	printf("adjustable clk: version: %08x\n", memory_adjustable_clk[0xC/4]);
	printf("adjustable clk: current time ns: %08x\n", memory_adjustable_clk[0x10/4]);
	printf("adjustable clk: current time s: %08x\n", memory_adjustable_clk[0x14/4]);
	printf("adjustable clk: adjust time ns: %08x\n", memory_adjustable_clk[0x20/4]);
	printf("adjustable clk: adjust time s: %08x\n", memory_adjustable_clk[0x24/4]);
	printf("adjustable clk: adjust offset ns: %08x\n", memory_adjustable_clk[0x30/4]);
	printf("adjustable clk: adjust offset interval ns s: %08x\n", memory_adjustable_clk[0x34/4]);
	printf("adjustable clk: adjust drift ns: %08x\n", memory_adjustable_clk[0x40/4]);
	printf("adjustable clk: adjust drift interval ns s: %08x\n", memory_adjustable_clk[0x44/4]);
	printf("adjustable clk: in sync threshold: %08x\n", memory_adjustable_clk[0x50/4]);
	printf("adjustable clk: Offset P: %08x\n", memory_adjustable_clk[0x60/4]);
	printf("adjustable clk: Offset I: %08x\n", memory_adjustable_clk[0x64/4]);
	printf("adjustable clk: Drift  P: %08x\n", memory_adjustable_clk[0x68/4]);
	printf("adjustable clk: Drift  I: %08x\n", memory_adjustable_clk[0x6C/4]);
	printf("adjustable clk: corrected offset: %08x\n", memory_adjustable_clk[0x70/4]);
	printf("adjustable clk: corrected drift: %08x\n", memory_adjustable_clk[0x74/4]);

	int* memory_signal_timestamper_gnss1 = (int*)(void_memory + 0x01010000);
	printf("timestamper_gnss1pps: valid and enable control: %08x\n", memory_signal_timestamper_gnss1[0x0/4]);
	printf("timestamper_gnss1pps: version: %08x\n", memory_signal_timestamper_gnss1[0xC/4]);
	printf("timestamper_gnss1pps: event counter: %08x\n", memory_signal_timestamper_gnss1[0x38/4]);
	printf("timestamper_gnss1pps: count: %08x\n", memory_signal_timestamper_gnss1[0x40/4]);
	printf("timestamper_gnss1pps: timestamp nanosec: %08x\n", memory_signal_timestamper_gnss1[0x44/4]);
	printf("timestamper_gnss1pps: timestamp sec: %08x\n", memory_signal_timestamper_gnss1[0x48/4]);
	printf("timestamper_gnss1pps: datawidth: %08x\n", memory_signal_timestamper_gnss1[0x4C/4]);
	int* memory_signal_timestamper_1 = (int*)(void_memory + 0x01010000);
	printf("timestamper_1: valid and enable control: %08x\n", memory_signal_timestamper_1[0x0/4]);
	printf("timestamper_1: version: %08x\n", memory_signal_timestamper_1[0xC/4]);
	printf("timestamper_1: event counter: %08x\n", memory_signal_timestamper_1[0x38/4]);
	printf("timestamper_1: count: %08x\n", memory_signal_timestamper_1[0x40/4]);
	printf("timestamper_1: timestamp nanosec: %08x\n", memory_signal_timestamper_1[0x44/4]);
	printf("timestamper_1: timestamp sec: %08x\n", memory_signal_timestamper_1[0x48/4]);
	printf("timestamper_1: datawidth: %08x\n", memory_signal_timestamper_1[0x4C/4]);
	int* memory_signal_timestamper_fpga = (int*)(void_memory + 0x010C0000);
	printf("timestamper_fpgapps: valid and enable control: %08x\n", memory_signal_timestamper_fpga[0x0/4]);
	printf("timestamper_fpgapps: version: %08x\n", memory_signal_timestamper_fpga[0xC/4]);
	printf("timestamper_fpgapps: event counter: %08x\n", memory_signal_timestamper_fpga[0x38/4]);
	printf("timestamper_fpgapps: count: %08x\n", memory_signal_timestamper_fpga[0x40/4]);
	printf("timestamper_fpgapps: timestamp nanosec: %08x\n", memory_signal_timestamper_fpga[0x44/4]);
	printf("timestamper_fpgapps: timestamp sec: %08x\n", memory_signal_timestamper_fpga[0x48/4]);
	printf("timestamper_fpgapps: datawidth: %08x\n", memory_signal_timestamper_fpga[0x4C/4]);

	return 0;
}

