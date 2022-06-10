import csv
from collections import Counter, OrderedDict

if __name__ == '__main__':

    # We create a list with all the csv files we want to analyze
    file_name = 'distrib_priorities.txt'

    print("Analyzing file: " + file_name)

    # We create the lists
    list_packet_sizes_9 = []
    list_packet_sizes_8 = []
    list_packet_sizes_7 = []
    list_packet_sizes_6 = []
    list_packet_sizes_5 = []
    list_packet_sizes_4 = []
    list_packet_sizes_3 = []
    list_packet_sizes_2 = []
    list_packet_sizes_1 = []
    list_packet_sizes_0 = []

    row_counter = 0
    with open(file_name) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')

        for row in csv_reader:
            if row[1] == "9":
                list_packet_sizes_9.append(int(row[2]))
            elif row[1] == "8":
                list_packet_sizes_8.append(int(row[2]))
            elif row[1] == "7":
                list_packet_sizes_7.append(int(row[2]))
            elif row[1] == "6":
                list_packet_sizes_6.append(int(row[2]))
            elif row[1] == "5":
                list_packet_sizes_5.append(int(row[2]))
            elif row[1] == "4":
                list_packet_sizes_4.append(int(row[2]))  
            elif row[1] == "3":
                list_packet_sizes_3.append(int(row[2]))  
            elif row[1] == "2":
                list_packet_sizes_2.append(int(row[2]))  
            elif row[1] == "1":
                list_packet_sizes_1.append(int(row[2]))  
            elif row[1] == "0":
                list_packet_sizes_0.append(int(row[2]))                  

        cnt_packet_sizes_9 = Counter()
        cnt_packet_sizes_8 = Counter()
        cnt_packet_sizes_7 = Counter()
        cnt_packet_sizes_6 = Counter()
        cnt_packet_sizes_5 = Counter()
        cnt_packet_sizes_4 = Counter()
        cnt_packet_sizes_3 = Counter()
        cnt_packet_sizes_2 = Counter()
        cnt_packet_sizes_1 = Counter()
        cnt_packet_sizes_0 = Counter()

        for packet_size in list_packet_sizes_9:
            cnt_packet_sizes_9[packet_size] += 1

        for packet_size in list_packet_sizes_8:
            cnt_packet_sizes_8[packet_size] += 1

        for packet_size in list_packet_sizes_7:
            cnt_packet_sizes_7[packet_size] += 1

        for packet_size in list_packet_sizes_6:
            cnt_packet_sizes_6[packet_size] += 1

        for packet_size in list_packet_sizes_5:
            cnt_packet_sizes_5[packet_size] += 1

        for packet_size in list_packet_sizes_4:
            cnt_packet_sizes_4[packet_size] += 1

        for packet_size in list_packet_sizes_3:
            cnt_packet_sizes_3[packet_size] += 1

        for packet_size in list_packet_sizes_2:
            cnt_packet_sizes_2[packet_size] += 1

        for packet_size in list_packet_sizes_1:
            cnt_packet_sizes_1[packet_size] += 1

        for packet_size in list_packet_sizes_0:
            cnt_packet_sizes_0[packet_size] += 1

        dict_packet_sizes_9 = OrderedDict(cnt_packet_sizes_9.most_common())
        dict_packet_sizes_8 = OrderedDict(cnt_packet_sizes_8.most_common())
        dict_packet_sizes_7 = OrderedDict(cnt_packet_sizes_7.most_common())
        dict_packet_sizes_6 = OrderedDict(cnt_packet_sizes_6.most_common())
        dict_packet_sizes_5 = OrderedDict(cnt_packet_sizes_5.most_common())
        dict_packet_sizes_4 = OrderedDict(cnt_packet_sizes_4.most_common())
        dict_packet_sizes_3 = OrderedDict(cnt_packet_sizes_3.most_common())
        dict_packet_sizes_2 = OrderedDict(cnt_packet_sizes_2.most_common())
        dict_packet_sizes_1 = OrderedDict(cnt_packet_sizes_1.most_common())
        dict_packet_sizes_0 = OrderedDict(cnt_packet_sizes_0.most_common())

        # We finally print the dictionaries
        file_9 = open('histogram-packet-sizes-9.dat', 'w+')
        file_9.write("#Packet_size,Count\n")
        for key in dict_packet_sizes_9:
            file_9.write(str(key) + "," + str(dict_packet_sizes_9[key]) + "\n")
        file_9.close()

        file_8 = open('histogram-packet-sizes-8.dat', 'w+')
        file_8.write("#Packet_size,Count\n")
        for key in dict_packet_sizes_8:
            file_8.write(str(key) + "," + str(dict_packet_sizes_8[key]) + "\n")
        file_8.close() 

        file_7 = open('histogram-packet-sizes-7.dat', 'w+')
        file_7.write("#Packet_size,Count\n")
        for key in dict_packet_sizes_7:
            file_7.write(str(key) + "," + str(dict_packet_sizes_7[key]) + "\n")
        file_7.close()

        file_6 = open('histogram-packet-sizes-6.dat', 'w+')
        file_6.write("#Packet_size,Count\n")
        for key in dict_packet_sizes_6:
            file_6.write(str(key) + "," + str(dict_packet_sizes_6[key]) + "\n")
        file_6.close()

        file_5 = open('histogram-packet-sizes-5.dat', 'w+')
        file_5.write("#Packet_size,Count\n")
        for key in dict_packet_sizes_5:
            file_5.write(str(key) + "," + str(dict_packet_sizes_5[key]) + "\n")
        file_5.close()

        file_4 = open('histogram-packet-sizes-4.dat', 'w+')
        file_4.write("#Packet_size,Count\n")
        for key in dict_packet_sizes_4:
            file_4.write(str(key) + "," + str(dict_packet_sizes_4[key]) + "\n")
        file_4.close()

        file_3 = open('histogram-packet-sizes-3.dat', 'w+')
        file_3.write("#Packet_size,Count\n")
        for key in dict_packet_sizes_3:
            file_3.write(str(key) + "," + str(dict_packet_sizes_3[key]) + "\n")
        file_3.close()

        file_2 = open('histogram-packet-sizes-2.dat', 'w+')
        file_2.write("#Packet_size,Count\n")
        for key in dict_packet_sizes_2:
            file_2.write(str(key) + "," + str(dict_packet_sizes_2[key]) + "\n")
        file_2.close()

        file_1 = open('histogram-packet-sizes-1.dat', 'w+')
        file_1.write("#Packet_size,Count\n")
        for key in dict_packet_sizes_1:
            file_1.write(str(key) + "," + str(dict_packet_sizes_1[key]) + "\n")
        file_1.close()

        file_0 = open('histogram-packet-sizes-0.dat', 'w+')
        file_0.write("#Packet_size,Count\n")
        for key in dict_packet_sizes_0:
            file_0.write(str(key) + "," + str(dict_packet_sizes_0[key]) + "\n")
        file_0.close()
