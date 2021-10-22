#!/usr/bin/env python

import os
from optparse import OptionParser

class Merger:
    def __init__(self,dir):
        self.dir = dir
        self.output_path = os.path.join(dir,"trace.json")

        if os.path.exists(self.output_path):
            os.remove(self.output_path)

        self.output = open(self.output_path,'w')
        self.output.write('[\n')

    def append(self,line):
        line = line.strip('\n')
        self.output.write(line)
        self.output.write('\n')

    def merge_file(self,file_path):

        file = open(file_path)
        while True:
            line = file.readline()
            
            if not line or len(line) == 0:
                break
            if line[0] != '{':
                break
            self.append(line)

    def run(self):
        i = 0
        while True:
            file_path = os.path.join(self.dir,"trace_%d.appletrace" % (i))
            if not os.path.exists(file_path):
                break

            self.merge_file(file_path)
            i+=1

def main():
    p = OptionParser('usage: %prog -d <directory_path>')
    p.add_option("-d","--dir",dest="dir",help="directory path that include all ostrace files")

    (options,args) = p.parse_args()
    if options.dir is None:
        p.print_help();
        return
    
    if options.dir:
        # merge into json
        m = Merger(options.dir)
        m.run()

if __name__ == '__main__':
    main()
