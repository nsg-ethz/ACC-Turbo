#ifdef __cplusplus
extern "C" {
#endif
#include <bf_rt/bf_rt_init.h>
#include <bf_rt/bf_rt_session.h>
#include <bf_rt/bf_rt_common.h>
#include <bf_rt/bf_rt_table_key.h>
#include <bf_rt/bf_rt_table_data.h>
#include <bf_rt/bf_rt_table.h>
#include <getopt.h>
#include <pthread.h>
#include <unistd.h>
#include <signal.h>

#include <bfutils/clish/thread.h>
#include <bf_switchd/bf_switchd.h>
#include <bfsys/bf_sal/bf_sys_intf.h>
#ifdef __cplusplus
}
#endif

// Generic instantiation of the target
#define ALL_PIPES 0xffff
bf_rt_target_t dev_tgt;

// Hdl for the info object associated to the p4 program
const bf_rt_info_hdl *bfrtInfo = NULL;

// Hdl for the session (generics)
bf_rt_session_hdl *session = NULL;
bf_rt_table_key_hdl *bfrtTableKey;
bf_rt_table_data_hdl *bfrtTableData;

/**********************************************/
/* Specifics for the "do_packet_count" table */
/**********************************************/

// Table specifics: Hdl for the "do_packet_count" table
const bf_rt_table_hdl *do_packet_count_table_hdl = NULL;

// Table specifics: Key field ids
bf_rt_id_t do_packet_count_table_queue_id_field_id = 0;
bf_rt_id_t do_packet_count_table_packet_count_action_id = 0;
bf_rt_id_t do_packet_count_table_packet_count_counter_field_id = 0;

// Structure to store the date we extract from (or we want to put to) "do_packet_count" key
typedef struct local_do_packet_count_key {
  uint16_t local_queue_id;
} local_do_packet_count_key;

// Structure to store the date we extract from (or we want to put to) "do_packet_count" data
typedef struct local_do_packet_count_data {
  uint32_t local_counter;
} local_do_packet_count_data;


// This function does the initial setUp of getting bfrtInfo object associated
// with the P4 program from which all other required objects are obtained
void setUp() {
  dev_tgt.dev_id = 0;
  dev_tgt.pipe_id = ALL_PIPES;

  // Get bfrtInfo object from dev_id and p4 program name
  bf_status_t bf_status = bf_rt_info_get(dev_tgt.dev_id, "ddos_aid_4x4_singlepipe_p4_16", &bfrtInfo);
  // Check for status
  assert(bf_status == BF_SUCCESS);

  // Create a session object
  bf_status = bf_rt_session_create(&session);
  // Check for status
  assert(bf_status == BF_SUCCESS);
}

// This function does the initial set up of getting key field-ids, action-ids
// and data field ids associated with the do_packet_count table. This is done once
// during init time.
void tableSetUp() {

  // Get table object from name
  bf_status_t bf_status = bf_rt_table_from_name_get(bfrtInfo, "MyEgress.do_packet_count", &do_packet_count_table_hdl);
  assert(bf_status == BF_SUCCESS);

  // Once we have the table, get action id for the packet_count action
  bf_status = bf_rt_action_name_to_id(do_packet_count_table_hdl, "MyEgress.packet_count", &do_packet_count_table_packet_count_action_id);
  assert(bf_status == BF_SUCCESS);

  // Get field-ids for key field and data fields
  bf_status = bf_rt_key_field_id_get(do_packet_count_table_hdl, "queue_id", &do_packet_count_table_queue_id_field_id);
  assert(bf_status == BF_SUCCESS);

  // Not sure about the best way to read from a counter
  bf_status = bf_rt_data_field_id_with_action_get(do_packet_count_table_hdl,do_packet_count_table_packet_count_action_id,&do_packet_count_table_packet_count_counter_field_id);
  assert(bf_status == BF_SUCCESS);


  // Allocate key and data once, and use reset across different uses
  bf_status = bf_rt_table_key_allocate(do_packet_count_table_hdl, &bfrtTableKey);
  assert(bf_status == BF_SUCCESS);

  bf_status = bf_rt_table_data_allocate(do_packet_count_table_hdl, &bfrtTableData);
  assert(bf_status == BF_SUCCESS);
}

// This function clears up any allocated memory during tableSetUp()
void tableTearDown() {
  bf_status_t bf_status;
  // Deallocate key and data
  bf_status = bf_rt_table_key_deallocate(bfrtTableKey);
  assert(bf_status == BF_SUCCESS);

  bf_status = bf_rt_table_data_deallocate(bfrtTableData);
  assert(bf_status == BF_SUCCESS);
}

// This function clears up any allocated mem during setUp()
void tearDown() {
  bf_status_t bf_status;
  bf_status = bf_rt_session_destroy(session);
  // Check for status
  assert(bf_status == BF_SUCCESS);
}

/*******************************************************************************
 * Utility functions associated with "do_packet_count" table in the P4 program.
 ******************************************************************************/

// This function sets the passed in ip_dst and vrf value into the key object
// passed using the setValue methods on the key object
void do_packet_count_key_setup(const do_packet_count_key *key, bf_rt_table_key_hdl *table_key) {
  
  // Set value into the key object. Key type is "EXACT"
  bf_status_t bf_status = bf_rt_key_field_set_value(table_key, do_packet_count_table_queue_id_field_id,key->queue_id);
  assert(bf_status == BF_SUCCESS);

  return;
}

// This function processes the entry obtained by a get call. Based on the action id the data object is intepreted.
void do_packet_count_process_entry_get(const bf_rt_table_data_hdl *table_data, do_packet_count_data *data) {
  // First get actionId, then based on that, fill in appropriate fields
  bf_status_t bf_status;
  bf_rt_id_t action_id;

  bf_status = bf_rt_data_action_id_get(table_data, &action_id);
  assert(bf_status == BF_SUCCESS);

  if (action_id == do_packet_count_table_packet_count_action_id) {
    ipRoute_process_route_entry_get(table_data, &data->table_data.route_data);
  }
  return;
}

// This function reads an entry specified by the key, and fills in the
// passedin IpRoute object
void do_packet_count_entry_get(const do_packet_count_key *key, do_packet_count_data *data) {
  // Reset key and data before use
  bf_rt_table_key_reset(do_packet_count_table, &bfrtTableKey);
  // Data reset is done without action-id, since the action-id is filled in by
  // the get function
  bf_rt_table_data_reset(do_packet_count_table, &bfrtTableData);

  do_packet_count_key_setup(key, bfrtTableKey);

  bf_status_t status = BF_SUCCESS;
  // Entry get from hardware with the flag set to read from hardware
  bf_rt_entry_read_flag_e flag = ENTRY_READ_FROM_HW;
  status = bf_rt_table_entry_get(do_packet_count_table, session, &dev_tgt, bfrtTableKey, bfrtTableData, flag);
  assert(status == BF_SUCCESS);

  do_packet_count_process_entry_get(bfrtTableData, data);

  return;
}

// This function deletes an entry specified by the key
void do_packet_count_entry_delete(const do_packet_count_key *key) {
  // Reset key before use
  bf_rt_table_key_reset(do_packet_count_table, &bfrtTableKey);

  do_packet_count_key_setup(key, bfrtTableKey);

  bf_status_t status =
      bf_rt_table_entry_del(do_packet_count_table, session, &dev_tgt, bfrtTableKey);
  assert(status == BF_SUCCESS);
  bf_rt_session_complete_operations(session);
  return;
}

static void parse_options(bf_switchd_context_t *switchd_ctx,
                          int argc,
                          char **argv) {
  int option_index = 0;
  enum opts {
    OPT_INSTALLDIR = 1,
    OPT_CONFFILE,
  };
  static struct option options[] = {
      {"help", no_argument, 0, 'h'},
      {"install-dir", required_argument, 0, OPT_INSTALLDIR},
      {"conf-file", required_argument, 0, OPT_CONFFILE}};

  while (1) {
    int c = getopt_long(argc, argv, "h", options, &option_index);

    if (c == -1) {
      break;
    }
    switch (c) {
      case OPT_INSTALLDIR:
        switchd_ctx->install_dir = strdup(optarg);
        printf("Install Dir: %s\n", switchd_ctx->install_dir);
        break;
      case OPT_CONFFILE:
        switchd_ctx->conf_file = strdup(optarg);
        printf("Conf-file : %s\n", switchd_ctx->conf_file);
        break;
      case 'h':
      case '?':
        printf("tna_exact_match \n");
        printf(
            "Usage : tna_exact_match --install-dir <path to where the SDE is "
            "installed> --conf-file <full path to the conf file "
            "(tna_exact_match.conf)\n");
        exit(c == 'h' ? 0 : 1);
        break;
      default:
        printf("Invalid option\n");
        exit(0);
        break;
    }
  }
  if (switchd_ctx->install_dir == NULL) {
    printf("ERROR : --install-dir must be specified\n");
    exit(0);
  }

  if (switchd_ctx->conf_file == NULL) {
    printf("ERROR : --conf-file must be specified\n");
    exit(0);
  }
}

void perform_driver_func() {

  // Do initial set up
  setUp();

  // Do table level set up
  tableSetUp();
  
  // Add a table entry
  IpRouteKey ipRoute_key1 = {0x0A0B0C01, 9};
  IpRoute_routeData ipRoute_data = {0xaabbccddeeff, 0xffeeddccbbaa, 2};
  ipRoute_entry_add_modify_with_route(&ipRoute_key1, &ipRoute_data, true);

  // Modify the table entry
  IpRoute_natData ipNat_data = {0x264DCC42, 0xC0A80102, 7};
  ipRoute_entry_add_modify_with_nat(&ipRoute_key1, &ipNat_data, false);

  // Add a few more entries
  IpRouteKey ipRoute_key2 = {0x0B0B0C02, 9};
  ipRoute_entry_add_modify_with_route(&ipRoute_key2, &ipRoute_data, true);
  IpRouteKey ipRoute_key3 = {0x0B0B0C03, 10};
  ipRoute_entry_add_modify_with_route(&ipRoute_key3, &ipRoute_data, true);
  IpRouteKey ipRoute_key4 = {0x0B0B0C04, 11};
  ipRoute_entry_add_modify_with_route(&ipRoute_key4, &ipRoute_data, true);

  // Iterate over the table
  table_iterate();

  // Delete the table entries

  ipRoute_entry_delete(&ipRoute_key1);
  ipRoute_entry_delete(&ipRoute_key2);
  ipRoute_entry_delete(&ipRoute_key3);
  ipRoute_entry_delete(&ipRoute_key4);

  // Table tear down
  tableTearDown();
  // Tear Down
  tearDown();
  return;
}

int main(int argc, char **argv) {
  bf_switchd_context_t *switchd_ctx;
  sigset_t signal_set;
  int sig;

  if ((switchd_ctx = (bf_switchd_context_t *)calloc(
           1, sizeof(bf_switchd_context_t))) == NULL) {
    printf("Cannot Allocate switchd context\n");
    exit(1);
  }
  parse_options(switchd_ctx, argc, argv);

  switchd_ctx->running_in_background = true;
  bf_status_t status = bf_switchd_lib_init(switchd_ctx);
  perform_driver_func();
  cli_run_bfshell();

  if (switchd_ctx) free(switchd_ctx);

  sigemptyset(&signal_set);
  sigaddset(&signal_set, SIGINT);
  sigwait(&signal_set, &sig);
  return status;
}
