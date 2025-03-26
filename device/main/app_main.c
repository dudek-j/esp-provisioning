#include <stdio.h>
#include <string.h>

#include <freertos/FreeRTOS.h>
#include <freertos/event_groups.h>
#include <freertos/task.h>

#include <esp_event.h>
#include <esp_log.h>
#include <esp_wifi.h>
#include <nvs_flash.h>

#include <wifi_provisioning/manager.h>
#include <wifi_provisioning/scheme_softap.h>

static const char *TAG = "app";

/* Signal Wi-Fi events on this event-group */
const int WIFI_CONNECTED_EVENT = BIT0;
static EventGroupHandle_t wifi_event_group;

#define PROV_TRANSPORT_SOFTAP "softap"
#define QRCODE_BASE_URL "https://espressif.github.io/esp-jumpstart/qrcode.html"

/* Event handler for catching system events */
static void ip_event_handler(void *arg, esp_event_base_t event_base,
                             int32_t event_id, void *event_data) {
  if (event_id == IP_EVENT_STA_GOT_IP) {
    ip_event_got_ip_t *event = (ip_event_got_ip_t *)event_data;
    ESP_LOGI(TAG, "Connected with IP Address:" IPSTR,
             IP2STR(&event->ip_info.ip));
    /* Signal main application to continue execution */
    xEventGroupSetBits(wifi_event_group, WIFI_CONNECTED_EVENT);
  }
}

static void protocomm_event_handler(void *arg, esp_event_base_t event_base,
                                    int32_t event_id, void *event_data) {
  switch (event_id) {
  case PROTOCOMM_SECURITY_SESSION_SETUP_OK:
    ESP_LOGI(TAG, "Secured session established!");
    break;
  case PROTOCOMM_SECURITY_SESSION_INVALID_SECURITY_PARAMS:
    ESP_LOGE(TAG, "Received invalid security parameters for establishing "
                  "secure session!");
    break;
  case PROTOCOMM_SECURITY_SESSION_CREDENTIALS_MISMATCH:
    ESP_LOGE(TAG, "Received incorrect username and/or PoP for establishing "
                  "secure session!");
    break;
  default:
    break;
  }
}

static void wifi_event_handler(void *arg, esp_event_base_t event_base,
                               int32_t event_id, void *event_data) {
  switch (event_id) {
  case WIFI_EVENT_STA_START:
    esp_wifi_connect();
    break;
  case WIFI_EVENT_STA_DISCONNECTED:
    ESP_LOGI(TAG, "Disconnected. Connecting to the AP again...");
    esp_wifi_connect();
    break;
  case WIFI_EVENT_AP_STACONNECTED:
    ESP_LOGI(TAG, "SoftAP transport: Connected!");
    break;
  case WIFI_EVENT_AP_STADISCONNECTED:
    ESP_LOGI(TAG, "SoftAP transport: Disconnected!");
    break;
  default:
    break;
  }
}

static void wifi_prov_event_handler(void *arg, esp_event_base_t event_base,
                                    int32_t event_id, void *event_data) {
  static int retries;

  switch (event_id) {
  case WIFI_PROV_START:
    ESP_LOGI(TAG, "Provisioning started");
    break;
  case WIFI_PROV_CRED_RECV: {
    wifi_sta_config_t *wifi_sta_cfg = (wifi_sta_config_t *)event_data;
    ESP_LOGI(TAG,
             "Received Wi-Fi credentials"
             "\n\tSSID     : %s\n\tPassword : %s",
             (const char *)wifi_sta_cfg->ssid,
             (const char *)wifi_sta_cfg->password);
    break;
  }
  case WIFI_PROV_CRED_FAIL: {
    wifi_prov_sta_fail_reason_t *reason =
        (wifi_prov_sta_fail_reason_t *)event_data;
    ESP_LOGE(TAG,
             "Provisioning failed!\n\tReason : %s"
             "\n\tPlease reset to factory and retry provisioning",
             (*reason == WIFI_PROV_STA_AUTH_ERROR)
                 ? "Wi-Fi station authentication failed"
                 : "Wi-Fi access-point not found");
    retries++;
    if (retries >= 3) {
      ESP_LOGI(TAG, "Failed to connect with provisioned AP, resetting "
                    "provisioned credentials");
      wifi_prov_mgr_reset_sm_state_on_failure();
      retries = 0;
    }
    break;
  }
  case WIFI_PROV_CRED_SUCCESS:
    ESP_LOGI(TAG, "Provisioning successful");
    retries = 0;
    break;
  case WIFI_PROV_END:
    /* De-initialize manager once provisioning is finished */
    wifi_prov_mgr_deinit();
    break;
  default:
    break;
  }
}

static void get_device_service_name(char *service_name, size_t max) {
  uint8_t eth_mac[6];
  const char *ssid_prefix = "PROV_";
  esp_wifi_get_mac(WIFI_IF_STA, eth_mac);
  snprintf(service_name, max, "%s%02X%02X%02X", ssid_prefix, eth_mac[3],
           eth_mac[4], eth_mac[5]);
}

void setup_deps() {
  esp_err_t ret = nvs_flash_init();
  if (ret == ESP_ERR_NVS_NO_FREE_PAGES ||
      ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
    ESP_ERROR_CHECK(nvs_flash_erase());
    ESP_ERROR_CHECK(nvs_flash_init());
  }

  ESP_ERROR_CHECK(esp_netif_init());
  ESP_ERROR_CHECK(esp_event_loop_create_default());
}

void setup_handlers() {
  ESP_ERROR_CHECK(esp_event_handler_register(WIFI_PROV_EVENT, ESP_EVENT_ANY_ID,
                                             wifi_prov_event_handler, NULL));
  ESP_ERROR_CHECK(esp_event_handler_register(PROTOCOMM_SECURITY_SESSION_EVENT,
                                             ESP_EVENT_ANY_ID,
                                             protocomm_event_handler, NULL));
  ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID,
                                             wifi_event_handler, NULL));
  ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP,
                                             ip_event_handler, NULL));
}

void app_main(void) {
  setup_deps();
  setup_handlers();

  wifi_event_group = xEventGroupCreate();

  esp_netif_create_default_wifi_sta();
  esp_netif_create_default_wifi_ap();

  wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
  ESP_ERROR_CHECK(esp_wifi_init(&cfg));

  wifi_prov_mgr_config_t config = {
      .scheme = wifi_prov_scheme_softap,
      .scheme_event_handler = WIFI_PROV_EVENT_HANDLER_NONE, // Clean up thingy
  };

  /* Initialize provisioning manager with the
   * configuration parameters set above */
  ESP_ERROR_CHECK(wifi_prov_mgr_init(config));

  wifi_prov_mgr_reset_provisioning();

  ESP_LOGI(TAG, "Starting provisioning");
  char service_name[12];
  ESP_LOGI(TAG, "Service name %s", service_name);
  get_device_service_name(service_name, sizeof(service_name));

  wifi_prov_security_t security = WIFI_PROV_SECURITY_1;
  wifi_prov_security1_params_t *pop = NULL; // NO POP
  const char *service_key = NULL;
  ESP_ERROR_CHECK(wifi_prov_mgr_start_provisioning(security, pop, service_name,
                                                   service_key));

  xEventGroupWaitBits(wifi_event_group, WIFI_CONNECTED_EVENT, true, true,
                      portMAX_DELAY);

  /* Start main application now */
  while (1) {
    ESP_LOGI(TAG, "Hello World!");
    vTaskDelay(1000 / portTICK_PERIOD_MS);
  }
}
