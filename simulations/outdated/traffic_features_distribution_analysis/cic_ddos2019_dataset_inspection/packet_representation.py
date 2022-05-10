class PacketRepresentation():
    '''
    The PacketRepresentation object is a fixed-size representation of a given packet, which keeps information
    up to application level, that can later be used to compute features and characterize a traffic mix.

    Attributes:
        dateTime (datetime):            The time at which the packet was received by the analyzer
        isX (bool):                     True if the packet contains header X
        fields (dict):                  A dict of header fields that characterize the packets
    '''

    def __init__(self):
        self.dateTime                   = 0
        self.fields                     = {
            "eth" : {
                "dst"                   : 0,
                "src"                   : 0,
                "type"                  : 0
            },
            "arp" : {
                "hwtype"                : 0,
                "prototype"             : 0,
                "hwsize"                : 0,
                "protosize"             : 0,
                "opcode"                : 0,
                "sendermac"             : 0,
                "senderip"              : 0,
                "targetmac"             : 0,
                "targetip"              : 0
            },
            "ip" : {
                "version"               : 0,
                "hdr_len"               : 0,
                "dsfield"               : 0,
                "dsfield_dscp"          : 0,
                "dsfield_ecn"           : 0,
                "len"                   : 0,
                "id"                    : 0,
                "flags"                 : 0,
                "flags_rb"              : 0,
                "flags_df"              : 0,
                "flags_mf"              : 0,
                "frag_offset"           : 0,
                "ttl"                   : 0,
                "proto"                 : 0,
                "checksum"              : 0,
                "checksum_status"       : 0,
                "src"                   : 0,
                "addr"                  : 0,
                "src_host"              : 0,
                "host"                  : 0,
                "dst"                   : 0,
                "dst_host"              : 0
            },
            "tcp" : {
                "srcport"               : 0,
                "dstport"               : 0,
                "seq"                   : 0,
                "ack"                   : 0,
                "hdr_len"               : 0,
                "flags_res"             : 0,
                "flags_ns"              : 0,
                "flags_cwr"             : 0,
                "flags_ecn"             : 0,
                "flags_urg"             : 0,
                "flags_ack"             : 0,
                "flags_push"            : 0,
                "flags_reset"           : 0,
                "flags_syn"             : 0,
                "flags_fin"             : 0,
                "window_size"           : 0,
                "checksum"              : 0,
                "urgent_pointer"        : 0            },
            "http" : {
                "request_method"        : 0,
                "request_uri"           : 0,
                "request_version"       : 0,
                "host"                  : 0,
                "accept"                : 0,
                "connection"            : 0,
                "cookie"                : 0,
                "user_agent"            : 0,
                "accept_language"       : 0,
                "referer"               : 0,
                "accept_encoding"       : 0
            },
            "udp" : {
                "srcport"               : 0,
                "dstport"               : 0,
                "length"                : 0,
                "checksum"              : 0            
            },
            "dns" : {
                "id"                    : 0,
                "flags_response"        : 0,
                "flags_opcode"          : 0,
                "flags_truncated"       : 0,
                "flags_recdesired"      : 0,
                "flags_z"               : 0,
                "flags_checkdisable"    : 0,
                "count_queries"         : 0,
                "count_answers"         : 0,
                "count_authrr"          : 0,
                "count_addrr"           : 0
            },
            "ntp" : {
                "flags_li"              : 0,
                "flags_version"         : 0,
                "flags_mode"            : 0,
                "stratum"               : 0,
                "peer_polling_interval" : 0,
                "peer_clock_precision"  : 0,
                "root_delay"            : 0,
                "root_dispersion"       : 0,
                "reference_id"          : 0,
                "reference_timestamp"   : 0,
                "origin_timestamp"      : 0,
                "receive_timestamp"     : 0,
                "transmit_timestamp"    : 0
            }
        }

    def parse_packet(self, packet):
        '''
        Extracts all the information from the pyshark-formatted packet, and creates a fixed (flat) representation, 
        with a constant number of fields.

        Args:
            packet (dict):              The packet in pyshark format
        '''
        
        self.date_time                                              = packet.sniff_time
        if "ETH" in packet:
            self.fields["eth"]["dst"]                               = packet.eth.dst #(all objects are strings, it is just parsing the XML) you can do "pkt.ip.flags_rb.int_value"
            self.fields["eth"]["src"]                               = packet.eth.src
            #self.fields["eth"]["type"]                              = int(packet.eth.type, 16)

            if "ARP" in packet:
                self.fields["arp"]["hwtype"]                        = packet.arp.hw_type
                self.fields["arp"]["prototype"]                     = packet.arp.proto_type
                self.fields["arp"]["hwsize"]                        = packet.arp.hw_size
                self.fields["arp"]["protosize"]                     = packet.arp.proto_size
                self.fields["arp"]["opcode"]                        = packet.arp.opcode
                self.fields["arp"]["sendermac"]                     = packet.arp.src_hw_mac
                self.fields["arp"]["senderip"]                      = packet.arp.src_proto_ipv4
                self.fields["arp"]["targetmac"]                     = packet.arp.dst_hw_mac
                self.fields["arp"]["targetip"]                      = packet.arp.dst_proto_ipv4

            if "IP" in packet:
                self.fields["ip"]["version"]                        = packet.ip.version 
                self.fields["ip"]["hdr_len"]                        = packet.ip.hdr_len
                self.fields["ip"]["dsfield"]                        = packet.ip.dsfield
                self.fields["ip"]["dsfield_dscp"]                   = packet.ip.dsfield_dscp
                self.fields["ip"]["dsfield_ecn"]                    = packet.ip.dsfield_ecn
                self.fields["ip"]["len"]                            = packet.ip.len
                self.fields["ip"]["id"]                             = packet.ip.id
                self.fields["ip"]["flags_rb"]                       = packet.ip.flags_rb
                self.fields["ip"]["flags_df"]                       = packet.ip.flags_df
                self.fields["ip"]["flags_mf"]                       = packet.ip.flags_mf
                self.fields["ip"]["frag_offset"]                    = packet.ip.frag_offset
                self.fields["ip"]["ttl"]                            = packet.ip.ttl
                self.fields["ip"]["proto"]                          = packet.ip.proto
                self.fields["ip"]["checksum"]                       = packet.ip.checksum
                self.fields["ip"]["checksum_status"]                = packet.ip.checksum_status
                self.fields["ip"]["src"]                            = packet.ip.src
                self.fields["ip"]["addr"]                           = packet.ip.addr
                self.fields["ip"]["src_host"]                       = packet.ip.src_host
                self.fields["ip"]["host"]                           = packet.ip.host
                self.fields["ip"]["dst"]                            = packet.ip.dst
                self.fields["ip"]["dst_host"]                       = packet.ip.dst_host

                if "TCP" in packet:
                    self.fields["tcp"]["srcport"]                   = packet.tcp.srcport
                    self.fields["tcp"]["dstport"]                   = packet.tcp.dstport
                    self.fields["tcp"]["seq"]                       = packet.tcp.seq
                    self.fields["tcp"]["ack"]                       = packet.tcp.ack
                    self.fields["tcp"]["hdr_len"]                   = packet.tcp.hdr_len
                    self.fields["tcp"]["flags_res"]                 = packet.tcp.flags_res
                    self.fields["tcp"]["flags_ns"]                  = packet.tcp.flags_ns
                    self.fields["tcp"]["flags_cwr"]                 = packet.tcp.flags_cwr
                    self.fields["tcp"]["flags_ecn"]                 = packet.tcp.flags_ecn
                    self.fields["tcp"]["flags_urg"]                 = packet.tcp.flags_urg
                    self.fields["tcp"]["flags_ack"]                 = packet.tcp.flags_ack
                    self.fields["tcp"]["flags_push"]                = packet.tcp.flags_push
                    self.fields["tcp"]["flags_reset"]               = packet.tcp.flags_reset
                    self.fields["tcp"]["flags_syn"]                 = packet.tcp.flags_syn
                    self.fields["tcp"]["flags_fin"]                 = packet.tcp.flags_fin
                    self.fields["tcp"]["window_size"]               = packet.tcp.window_size_value
                    self.fields["tcp"]["checksum"]                  = packet.tcp.checksum
                    self.fields["tcp"]["urgent_pointer"]            = packet.tcp.urgent_pointer

                    #if "HTTP" in packet:
                    #   self.fields["http"]["req_method"]           = packet.http.request_method
                    #   self.fields["http"]["req_uri"]              = packet.http.request_uri
                    #   self.fields["http"]["req_version"]          = packet.http.request_version
                    #   self.fields["http"]["host"]                 = packet.http.host
                    #   self.fields["http"]["accept"]               = packet.http.accept
                    #   self.fields["http"]["connection"]           = packet.http.connection
                    #   self.fields["http"]["cookie"]               = packet.http.cookie
                    #   self.fields["http"]["user_agent"]           = packet.http.user_agent
                    #   self.fields["http"]["accept_lang"]          = packet.http.accept_language
                    #   self.fields["http"]["referer"]              = packet.http.referer
                    #   self.fields["http"]["accept_encod"]         = packet.http.accept_encoding

                elif "UDP" in packet:
                    self.fields["udp"]["srcport"]                   = packet.udp.srcport
                    self.fields["udp"]["dstport"]                   = packet.udp.dstport
                    self.fields["udp"]["length"]                    = packet.udp.length
                    self.fields["udp"]["checksum"]                  = packet.udp.checksum
                    
                    if "DNS" in packet:
                        self.fields["dns"]["id"]                    = packet.dns.id
                        self.fields["dns"]["flags_response"]        = packet.dns.flags_response
                        self.fields["dns"]["flags_opcode"]          = packet.dns.flags_opcode
                        self.fields["dns"]["flags_truncated"]       = packet.dns.flags_truncated
                        self.fields["dns"]["flags_recdesired"]      = packet.dns.flags_recdesired
                        self.fields["dns"]["flags_z"]               = packet.dns.flags_z
                        self.fields["dns"]["flags_checkdisable"]    = packet.dns.flags_checkdisable
                        self.fields["dns"]["count_queries"]         = packet.dns.count_queries
                        self.fields["dns"]["count_answers"]         = packet.dns.count_answers
                        self.fields["dns"]["count_authrr"]          = packet.dns.count_auth_rr
                        self.fields["dns"]["count_addrr"]           = packet.dns.count_add_rr

                    #if "NTP" in packet:
                    #    self.fields["ntp"]["flags_li"]              = packet.ntp.flags_li
                    #    self.fields["ntp"]["flags_version"]         = packet.ntp.flags_vn
                    #    self.fields["ntp"]["flags_mode"]            = packet.ntp.flags_mode
                    #    self.fields["ntp"]["stratum"]               = packet.ntp.stratum
                    #    self.fields["ntp"]["peer_polling_interval"] = packet.ntp.ppoll
                    #    self.fields["ntp"]["peer_clock_precision"]  = packet.ntp.precision
                    #    self.fields["ntp"]["root_delay"]            = packet.ntp.rootdelay
                    #    self.fields["ntp"]["root_dispersion"]       = packet.ntp.rootdispersion
                    #    self.fields["ntp"]["reference_id"]          = packet.ntp.refid
                    #    self.fields["ntp"]["reference_timestamp"]   = packet.ntp.reftime
                    #    self.fields["ntp"]["origin_timestamp"]      = packet.ntp.org
                    #    self.fields["ntp"]["receive_timestamp"]     = packet.ntp.rec
                    #    self.fields["ntp"]["transmit_timestamp"]    = packet.ntp.xmt

    def check(self, header_and_field, min, max):
        '''
        Returns true if, for this packet representation, the requested field lies between the min and the max values specified.

        Args:
            packet (dict):              The packet in pyshark format
        '''

        header = header_and_field.split(".")[0]
        field = header_and_field.split(".")[1]
        if (int(self.fields[header][field]) >= min) and (int(self.fields[header][field]) <= max):
            return True
        else:
            return False