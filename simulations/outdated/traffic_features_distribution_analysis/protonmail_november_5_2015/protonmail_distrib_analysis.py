
# These attacks took ProtonMail offline, making it impossible to access emails
# The largest and most extensive cyberattack in Switzerland, with hundreds of other companies also hit as collateral damage
# In addition to hitting ProtonMail, the attackers also took down the datacenter housing our servers and attacked several upstream ISPs
if __name__ == '__main__':

    # We create a list with all the pcap files we want to analyze
    input_file_name = "protonmail_dump.txt"

    # We create a list for each of the distributions, where we will append all the values that we extract
    ip_src0_distrib = {}
    ip_src1_distrib = {}
    ip_src2_distrib = {}
    ip_src3_distrib = {}
    t_sport_distrib = {}
    t_dport_distrib = {}
    as_src_distrib = {}

    for a in range(0, 65536):
        t_sport_distrib[a] = 0
        t_dport_distrib[a] = 0
        as_src_distrib[a] = 0

    for c in range(0, 256):
        ip_src0_distrib[c] = 0
        ip_src1_distrib[c] = 0
        ip_src2_distrib[c] = 0
        ip_src3_distrib[c] = 0

    # Input file configuration
    print('Started reading ' + input_file_name)
    txt_reader = open(input_file_name, "r")
    first_line = True

    # Start processing the pcap
    for line in txt_reader:

        if first_line:
            first_line = False
            continue

        # Parse values 
        as_srcs = line.split("	")[1]
        ip_src = line.split("	")[3]
        t_dports = line.split("	")[4]
        t_sports = line.split("	")[5]

        ip_src0 = ip_src.split(".")[0]
        ip_src1 = ip_src.split(".")[1]
        ip_src2 = ip_src.split(".")[2]
        ip_src3 = ip_src.split(".")[3]
        
        ip_src0_distrib[int(ip_src0)]                  = ip_src0_distrib[int(ip_src0)] + 1
        ip_src1_distrib[int(ip_src1)]                  = ip_src1_distrib[int(ip_src1)] + 1
        ip_src2_distrib[int(ip_src2)]                  = ip_src2_distrib[int(ip_src2)] + 1
        ip_src3_distrib[int(ip_src3)]                  = ip_src3_distrib[int(ip_src3)] + 1

        t_dports = t_dports.replace('"', '')
        t_dports_list = t_dports.split(',')
        for t_dport in t_dports_list:
            t_dport_distrib[int(t_dport)]                  = t_dport_distrib[int(t_dport)] + 1

        t_sports = t_sports.replace('"', '')
        t_sports = t_sports.replace('\n', '')
        t_sports_list = t_sports.split(',')
        for t_sport in t_sports_list:
            t_sport_distrib[int(t_sport)]                  = t_sport_distrib[int(t_sport)] + 1

        as_srcs = as_srcs.replace('"', '')
        as_srcs_list = as_srcs.split(',')
        for as_src in as_srcs_list:
            as_src_distrib[int(as_src)]                  = as_src_distrib[int(as_src)] + 1

    # Finally, we plot the resulting distribution
    w = open("ip_src.dat", 'w')
    w.write("#    ip_src0    ip_src1    ip_src2    ip_src3\n")
    for line in range(0,len(ip_src0_distrib)):
        w.write("%s   %s   %s   %s   %s\n" % (line, ip_src0_distrib[line], ip_src1_distrib[line], ip_src2_distrib[line], ip_src3_distrib[line]))
    w.close()

    w = open("as_src.dat", 'w')
    w.write("#    as_src\n")
    for line in range(0,len(as_src_distrib)):
        w.write("%s   %s\n" % (line, as_src_distrib[line]))
    w.close()

    w = open("t_ports.dat", 'w')
    w.write("#    t_sport_distrib    t_dport_distrib\n")
    for line in range(0,len(t_sport_distrib)):
        w.write("%s   %s   %s\n" % (line, t_sport_distrib[line], t_dport_distrib[line]))
    w.close()