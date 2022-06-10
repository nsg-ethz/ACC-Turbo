# RUN WITH PYTHON 3 !!! OTHERWISE THE apply_async DOES NOT WORK !!!
import sys
import os 

if __name__ == '__main__':

    # We initialize the file
    input_file = open('python/plots/ranking_algorithms/priority_performance_logs.dat', 'r')
    output_file = open('python/plots/ranking_algorithms/ranking_algorithms.dat', 'w')
    output_file.write("#    NumPackets    Throughput    NumPacketsSize    ThroughputSize\n")

    score_numpackets_mssql = "0"
    score_throughput_mssql = "0"
    score_numpacketssize_mssql = "0"
    score_throughputsize_mssql = "0"

    score_numpackets_ssdp = "0"
    score_throughput_ssdp = "0"
    score_numpacketssize_ssdp = "0"
    score_throughputsize_ssdp = "0"
    
    # We analye the file
    for line in input_file.readlines():
        if ("MSSQL" in line):
            if("ThroughputSize" in line):
                score_throughputsize_mssql = line.split(",")[1].split("\n")[0]
            elif("Throughput" in line):
                score_throughput_mssql = line.split(",")[1].split("\n")[0]
            elif("NumPacketsSize" in line):
                score_numpacketssize_mssql = line.split(",")[1].split("\n")[0] 
            elif("NumPackets" in line):
                score_numpackets_mssql = line.split(",")[1].split("\n")[0] 
            else:
                raise Exception("Ranking algorithm not expected: {}".format(line))

        elif ("SSDP" in line):
            if("ThroughputSize" in line):
                score_throughputsize_ssdp = line.split(",")[1].split("\n")[0]
            elif("Throughput" in line):
                score_throughput_ssdp = line.split(",")[1].split("\n")[0]
            elif("NumPacketsSize" in line):
                score_numpacketssize_ssdp = line.split(",")[1].split("\n")[0] 
            elif("NumPackets" in line):
                score_numpackets_ssdp = line.split(",")[1].split("\n")[0] 
            else:
                raise Exception("Ranking algorithm not expected: {}".format(line))
        
        else:
            raise Exception("Attack type not expected: {}".format(line))
    
    # We close the file
    input_file.close()

    # We build the output file
    output_file.write("MSSQL    " + score_numpackets_mssql + "    " + score_throughput_mssql + "    " + score_numpacketssize_mssql + "    " + score_throughputsize_mssql + "\n")
    output_file.write("SSDP    " + score_numpackets_ssdp + "    " + score_throughput_ssdp + "    " + score_numpacketssize_ssdp + "    " + score_throughputsize_ssdp + "\n")