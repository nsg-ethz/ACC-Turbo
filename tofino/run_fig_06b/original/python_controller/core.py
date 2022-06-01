from __future__ import print_function
import bfrt_grpc.client as gc

class CoreAPI:

    # More info about the GRPC API: 
    # $SDE_INSTALL/lib/python2.7/site-packages/tofino/bfrt_grpc/client.py

    def __init__(self, client_id=0, p4_name=None, grpc_addr='localhost:50052'):
        try:
            self.setup_grpc(client_id, p4_name, grpc_addr)
        except Exception as e:
            print("Error init: {}".format(e))

    def setup_grpc(self, client_id, p4_name, grpc_addr):
        self.client_id = client_id
        self.dev      = 0
        self.dev_tgt  = gc.Target(self.dev, pipe_id=0xFFFF)
        self.bfrt_info = None

        self.interface = gc.ClientInterface(grpc_addr, client_id=client_id,
                device_id=self.dev, is_master=False, notifications=None)

        if not p4_name:
            self.bfrt_info = self.interface.bfrt_info_get()
            p4_name = self.bfrt_info.p4_name_get()

        self.interface.bind_pipeline_config(p4_name)
        self.p4_name = p4_name

        print("    Connected to Device: {}, Program: {}, ClientId: {}".format(
            self.dev, self.p4_name, self.client_id))

    def list_tables(self):
        for key in sorted(self.bfrt_info.table_dict.keys()):
            print(key)

    def table_exists(self, table_name):
        if table_name not in self.tables:
            print("{} not found in tables. Did you pass it to setup_tables?".format(table_name))
            return False
        return True

    def print_table_info(self, table_name):
        if not self.table_exists(table_name):
            return
        print("====Table Info===")
        t = self.tables[table_name]
        print("{:<30}: {}".format("TableName", t.info.name_get()))
        print("{:<30}: {}".format("Size", t.info.size_get()))
        print("{:<30}: {}".format("Actions", t.info.action_name_list_get()))
        print("{:<30}:".format("KeyFields"))
        for field in sorted(t.info.key_field_name_list_get()):
            print("  {:<28}: {} => {}".format(field, t.info.key_field_type_get(field), t.info.key_field_match_type_get(field)))
        print("{:<30}:".format("DataFields"))
        for field in t.info.data_field_name_list_get():
            print("  {:<28}: {} {}".format(
                "{} ({})".format(field, t.info.data_field_id_get(field)), 
                # type(t.info.data_field_allowed_choices_get(field)), 
                t.info.data_field_type_get(field),
                t.info.data_field_size_get(field),
                ))
        print("================")

    def setup_tables(self, table_names):
        self.tables = {}
        for t in table_names:
            self.tables[t] = self.bfrt_info.table_get(t)

    def add_annotation(self, table_name, field, annotation):
        try:
            self.tables[table_name].info.key_field_annotation_add(field, annotation)
        except Exception as e:
            print("Exc in add_annotation:", e)

    def get_entries(self, table_name, print_entries=False):
        entries = []
        t = self.tables[table_name]
        if print_entries:
            print("======== %s ========" % t.info.name_get())
        for (d, k) in t.entry_get(self.dev_tgt):
            if print_entries:
                self._print_entry(k.to_dict(),d.to_dict())
            entries.append((k.to_dict(), d.to_dict()))
        return entries

    def insert_register_entry(self, table_name, register_idx, register_val):
        t = self.tables[table_name]
        t.entry_add(
            self.dev_tgt,
            [t.make_key([gc.KeyTuple('$REGISTER_INDEX', register_idx)])],
            [t.make_data(
                [gc.DataTuple(table_name + '.f1', register_val)])])

    def get_register_entry(self, table_name, register_idx):
        # Please note that grpc server is always going to return all instances of the register
        # i.e. one per pipe and stage the table exists in. The asymmetric suport for indirect
        # register tables is limited only to the insertion of the entries. Thus even if we
        # made the indirect register table asymmetric, we need to pass in the device target
        # as consisting of all the pipes while reading the entry
        t = self.tables[table_name]
        resp = t.entry_get(
            self.dev_tgt,
            [t.make_key(
                [gc.KeyTuple('$REGISTER_INDEX', register_idx)])],
            {"from_hw": True})
        return resp

    def _print_entry(self, keys, data):
        if len(keys) == 0:
            return 
        print("==entry==")
        print("  keys")
        for k in keys:
            print("    => {:<20}".format(k), end=" ")
            v = keys[k]
            if len(v) == 1:
                print(v['value'])
            else:
                if 'prefix_len' in v:
                    print("{}/{}".format(v['value'], v['prefix_len']))
                elif 'mask' in v:
                    print("{}/{}".format(v['value'], v['mask']))
                elif 'low' in v:
                    print("{} .. {}".format(v['low'], v['high']))
        print("  data")
        for k in data:
            v = data[k]
            print("    =>", "{:<20} {:<30}".format(k,v))
        print()

    # ALWAYS call tear down at the end
    def tear_down(self):
        self.interface._tear_down_stream()


    def clear_tables(self):
        try:
            for table_name in self.tables:
                t = self.tables[table_name]
                print("Clearing Table {}".format(t.info.name_get()))
                keys = []
                for (d, k) in t.entry_get(self.dev_tgt):
                    if k is not None:
                        keys.append(k)
                try:
                    t.entry_del(self.dev_tgt, keys)
                except:
                    pass
                # Not all tables support default entry
                try:
                    t.default_entry_reset(self.dev_tgt)
                except:
                    pass
        except Exception as e:
            print("Error cleaning up: {}".format(e))

    #
    # This is a simple helper method that takes a list of entries and programs
    # them in a specified table
    #
    # Each entry is a tuple, consisting of 3 elements:
    #  key         -- a list of tuples for each element of the key
    #                 @signature (name, value=None, mask=None, prefix_len=None, low=None, high=None)
    #  action_name -- the action to use. Must use full name of the action
    #  data        -- a list (may be empty) of the tuples for each action parameter
    #                 @signature (name, value=None) [for complex use cases refer to bfrt client.py]
    # 
    # Examples:
    # --------------------------------
    # self.program_table("ipv4_host", [
    #         ([("hdr.ipv4.dst_addr", "192.168.1.1")],
    #          "Ingress.send", [("port", 1)])
    # ]
    # self.programTable("ipv4_lpm", [
    #       ([("hdr.ipv4.dst_addr", "192.168.1.0", None, 24)],
    #         "Ingress.send", [("port", 64)]),

    def program_table(self, table_name, entries):
        table = self.tables[table_name]

        key_list=[]
        data_list=[]
        for k, a, d in entries:
            key_list.append(table.make_key([gc.KeyTuple(*f)   for f in k]))
            data_list.append(table.make_data([gc.DataTuple(*p) for p in d], a))
        try:
            table.entry_add(self.dev_tgt, key_list, data_list)
        except:
            table.entry_mod(self.dev_tgt, key_list, data_list)

    def modify_table(self, table_name, entries):
        table = self.tables[table_name]

        key_list=[]
        data_list=[]
        for k, a, d in entries:
            key_list.append(table.make_key([gc.KeyTuple(*f)   for f in k]))
            data_list.append(table.make_data([gc.DataTuple(*p) for p in d], a))
        table.entry_mod(self.dev_tgt, key_list, data_list)

    def clear_counter_packets(self, table_name, key_name, key_value, action_name):
        table = self.tables[table_name]

        table.entry_mod(self.dev_tgt,
            [table.make_key(
                [gc.KeyTuple(key_name, key_value)])],
            [table.make_data(
                [gc.DataTuple('$COUNTER_SPEC_PKTS', 0)],
                action_name)]
        )

    def clear_counter_bytes(self, table_name, key_name, key_value, action_name):
        table = self.tables[table_name]

        table.entry_mod(self.dev_tgt,
            [table.make_key(
                [gc.KeyTuple(key_name, key_value)])],
            [table.make_data(
                [gc.DataTuple('$COUNTER_SPEC_BYTES', 0)],
                action_name)]
        )