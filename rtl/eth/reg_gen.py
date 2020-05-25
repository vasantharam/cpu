import csv
import sys
import pdb
import re
import os
from itertools import islice

def csv_to_dict(csv_file_path):
    csvfile = open(csv_file_path, "r")
    csv_reader = csv.reader (csvfile, skipinitialspace=True)
    csv_iter = iter(csv_reader)# islice(csv_reader, 1)
    head = next(csv_iter)
    new_head = head[:-1]
    for col in head:
        res = re.search("(.*)([0-9]+)\.\.([0-9]+)", col) 
        if (res != None):
            for i in range(int(res.group(2)), int(res.group(3))):
                new_head.append( "%s_%d" %( res.group(1), i ))

    return csv.DictReader(csvfile, new_head, skipinitialspace=True)

def get_field_shift_and_mask(register):
    separator_mask = int (register['field_separator_mask'], 0)

    bit_pos = 0
    prev_bit_pos = 0
    ret = []
    for field in range(0, int(register['num_of_fields'])):
        d = dict()
        d['field_name'] = register["field_name_%d" % field]
        while (separator_mask & 1 != 1):
            separator_mask = separator_mask >> 1
            bit_pos = bit_pos + 1
        d['shift'] = bit_pos
        d['mask'] = (1 << (bit_pos+1  - prev_bit_pos) - 1) << bit_pos
        prev_bit_pos = bit_pos
        ret.append(d)
    return ret
    

   
def write_c_headers(registers, name):
    f = open("%s.h" % name, "w")
    print ("#ifndef __REG_%s__" % name, file=f)
    print ("#define __REG_%s__" % name, file=f)
    print ("", file=f)
    for i in registers:
        print ("/* Reigster REG_%s_%s */" %(name, i['name']), file=f)
        print ("#define REG_%s_%s %s" % (name, i['name'], i['offset']), file=f)

        fields = get_field_shift_and_mask(i)
        for field in fields:
            print ('#define REG_%s_%s_%s_NAME "%s"' % (name, i['name'], field['field_name'], field['field_name']), file=f)
            print ('#define REG_%s_%s_%s_SHIFT "%s"' % (name, i['name'], field['field_name'], field['shift']), file=f)
            print ('#define REG_%s_%s_%s_MASK "%s"' % (name, i['name'], field['field_name'], field['mask']), file=f)
            print ("", file=f)
       
    print ("#endif", file=f)
     
def reg_gen(csv_file_path):
    registers = csv_to_dict(csv_file_path)
    write_c_headers(registers, os.path.basename(csv_file_path).rsplit('.')[0]) 
    

def main():
    if (len(sys.argv) != 2):
        print("Usage: %s <register_spec_file.csv>", sys.argv[0])
    reg_gen(sys.argv[1])

if (__name__ == "__main__"):
    sys.exit(main())
