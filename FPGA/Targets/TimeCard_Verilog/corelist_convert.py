#!/usr/bin/env python3
import sys
import math
import struct

def text_to_hex_ascii(text):
    hex_list = []
    # Convert each character to its ASCII hex equivalent
    for char in text:
        hex_list.append(f"{ord(char):02x}")
    # Group the characters in sets of 4 to fit into 32-bit entries (4 bytes per entry)
    grouped_hex = [''.join(hex_list[i:i+4]) for i in range(0, len(hex_list), 4)]
    # Ensure the last entry is padded to 8 digits
    grouped_hex[-1] += '0' * (8 - len(grouped_hex[-1]))
    
    # Ensure there are exactly 9 entries, pad with zero if necessary
    while len(grouped_hex) < 9:
        grouped_hex.append('00000000')
    
    # Crop if too long
    return grouped_hex[:9]

def convert_to_dat(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        corelistsize = 0
        for line in infile:
            if len(line) < 63 or line[0] == '/':
                continue
            parts = line.split()
            
            # Write the first 7 columns as 32-bit hexadecimal entries
            # CoreTypeNr CoreInstNr VersionNr AddressRangeLow AddressRangeHigh InterruptNr Sensitivity
            for data in parts[:7]:
                outfile.write(f"{int(data, 16):08x}\n")  # Pack as big-endian 32-bit unsigned integers
            
            # Convert the text part to hexadecimal ASCII
            # MagicWord
            hex_ascii = text_to_hex_ascii(''.join(parts[7:]))
            # print(hex_ascii)
            
            # Write the text part as 32-bit entries
            for hex_value in hex_ascii:
                # print(hex_value)
                outfile.write(f"{int(hex_value, 16):08x}\n")  # Pack as big-endian 32-bit
            corelistsize += 1
    return corelistsize

if __name__ == "__main__":
    input_filename = sys.argv[1]
    output_filename = input_filename.replace('.txt', '.dat')
    hexperline = 7
    textwordwidth = 9
    wordsperline = hexperline + textwordwidth
    bytesperline = 4 * wordsperline
    corelistsize = convert_to_dat(input_filename, output_filename)
    print('CoreListBytes: ', corelistsize * bytesperline)
    print('RomAddrWidth: ', math.ceil(math.log2(corelistsize * wordsperline)))
