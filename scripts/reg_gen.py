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
    print (new_head)
    return csv.DictReader(csvfile, new_head, skipinitialspace=True)

def get_field_shift_and_mask(register):
    separator_mask = int (register['field_separator_mask'], 0)
    field_write_permissions = int (register['field_write_permissions'], 0)
    bit_pos = 0
    prev_bit_pos = 0
    ret = []
    for field in range(0, int(register['num_of_fields'])):
        d = dict()
        d['field_name'] = register["field_name_%d" % field]
        while (separator_mask & 1 != 1):
            separator_mask = separator_mask >> 1
            bit_pos = bit_pos + 1
        else: separator_mask = separator_mask >> 1
        print ("sp, bp")
        print (separator_mask, bit_pos)
        d['shift'] = bit_pos
        d['mask'] = (1 << (bit_pos+1  - prev_bit_pos) - 1) << bit_pos
        d['writable'] = field_write_permissions & 1
        d['msb'] = bit_pos
        d['lsb'] = prev_bit_pos
        
        field_write_permissions = field_write_permissions >> 1
        prev_bit_pos = bit_pos
        ret.append(d)
    register['fields'] = ret
    return ret
    

def generate_register_slave(registers, name):
    f = open("output/%s_reg_slave.v" % name, "w")
    f.write( """/* Note: This is a auto-generated file. 
 * Do not modify directly. 
 * Current Working Directory : %s 
 * Generation command line: %s """ % (os.getcwd() , ' '.join(sys.argv) + "\n*/\n\n\n"))
    f.write("`include %s_reg_slave.vh" %name)

    ftemplate = open("reg_slave.template", "r")
    output_reg_registers = ""
    reset_value_assignments = ""
    write_register_case_statements = ""
    read_register_case_statements = ""
    for i in registers:
        print (i)
        output_reg_registers = output_reg_registers + "output reg [15:0] reg_%s_%s, " %(name, i['name'])
        reset_value_assignments = reset_value_assignments + "        reg_%s_%s <= %s\n" % (name , i['name'], i['reset_value'])

        write_register_case_statements = write_register_case_statements + """                8'd%s: 
                    reg_%s_%s <= wdata;
                    wrsp_slverr <= 0;
""" % ( i['offset'], name, i['name'])
        read_register_case_statements = read_register_case_statements + """                8'd%s: 
                    rdata <= reg_%s_%s;
                    read_ready <= 1;
                    rrsp_slverr <= 0;
"""
        print (output_reg_registers, i)

    for i in ftemplate.readlines():
         i = re.sub('<output_reg_registers>', output_reg_registers, i)
         i = re.sub('<read_register_case_statements>', read_register_case_statements, i)
         i = re.sub('<write_register_case_statements>', write_register_case_statements, i)
         i = re.sub('<reset_value_assignments>', reset_value_assignments, i)
         f.write(i)
    f.close()
    ftemplate.close()
   
def generate_c_header(registers, name):
    f = open("output/%s.h" % name, "w")
    print ("#ifndef __REG_%s__" % name, file=f)
    print ("#define __REG_%s__" % name, file=f)
    print ("", file=f)
    for i in registers:
        print ("/* Reigster REG_%s_%s */" %(name, i['name']), file=f)
        print ("#define REG_%s_%s %s" % (name, i['name'], i['offset']), file=f)

        fields = i['fields'] 
        for field in fields:
            
            print ('#define REG_%s_%s_%s_NAME "%s"' % (name, i['name'], field['field_name'], field['field_name']), file=f)
            print ('#define REG_%s_%s_%s_SHIFT "%s"' % (name, i['name'], field['field_name'], field['shift']), file=f)
            print ('#define REG_%s_%s_%s_MASK "%s"' % (name, i['name'], field['field_name'], field['mask']), file=f)
            print ("", file=f)
       
    print ("#endif", file=f)
    
def generate_verilog_header(registers, name):
#BEGIN 
    f = open("output/%s.vh" % name, "w")
    print ("", file=f)
    for i in registers:
        print ("/* Reigster REG_%s_%s */" %(name, i['name']), file=f)
        print ("/* REG_%s_%s %s */" % (name, i['name'], i['offset']), file=f)

        fields = i['fields'] 

        for field in fields:
            print ('`define REG_%s_%s_%s "%s"' % (name, i['name'], field['field_name'], "[" + str(field['msb'])+":" + str(field['lsb'])+ "]"), file=f)
            print ("", file=f)
       
    print ("#endif", file=f)
    

#ENDDEF

def reg_gen(csv_file_path):
    try:
        os.mkdir("output")
    except:
        pass
    registers = list(csv_to_dict(csv_file_path))
    for i in registers:
        get_field_shift_and_mask(i)
    
    ip_name = os.path.basename(csv_file_path).rsplit('.')[0]
    
    generate_c_header(registers, ip_name)
    generate_register_slave(registers, ip_name) 
    generate_verilog_header(registers, ip_name)

def main():
    if (len(sys.argv) != 2):
        print("Usage: %s <register_spec_file.csv>", sys.argv[0])
    reg_gen(sys.argv[1])

if (__name__ == "__main__"):
    sys.exit(main())
