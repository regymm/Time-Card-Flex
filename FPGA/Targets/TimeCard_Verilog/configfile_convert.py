#!/usr/bin/env python3
import sys
import math
import struct

def convert_to_dat(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        configlistsize = 0
        for line in infile:
            if len(line) != 36 or line[0] == '/':
                continue
            for num in line.replace('\n', '').split(' ')[::-1]:
                outfile.write(num)
            outfile.write('\n')
            configlistsize += 1
    return configlistsize

if __name__ == "__main__":
    input_filename = sys.argv[1]
    output_filename = input_filename.replace('.txt', '.dat')
    wordsperline = 4 * 4
    configlistsize = convert_to_dat(input_filename, output_filename)
    print('CoreListSize: ', configlistsize)
    print('RomAddrWidth: ', math.ceil(math.log2(configlistsize)))
