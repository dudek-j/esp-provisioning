#include "wifi/wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_wifi.h"
#include "esp_wifi_default.h"
#include "wifi_provisioning/manager.h"
#include "wifi_provisioning/scheme_softap.h"
#include <nvs_flash.h>

#define APP_TAG "APP_TAG"
#define SERVICE_NAME "dudek-sonos-vinyl"

static callback connecting_handler;
static callback connected_handler;
static callback disconnected_handler;

static bool provisioned = false;

static void wifi_prov_event_handler(void *arg, esp_event_base_t event_base,
                                    int32_t event_id, void *event_data) {
  switch (event_id) {
  case WIFI_PROV_START:
    ESP_LOGI(APP_TAG, "Provisioning started");
    break;
  case WIFI_PROV_CRED_RECV: {
    connecting_handler();
    ESP_LOGI(APP_TAG, "Provisioning credentials recieved");
    break;
  }
  case WIFI_PROV_CRED_FAIL: {
    ESP_LOGI(APP_TAG, "Provisioning failed");
    wifi_prov_mgr_reset_sm_state_on_failure();
    break;
  }
  case WIFI_PROV_CRED_SUCCESS:
    ESP_LOGI(APP_TAG, "Provisioning successful");
    break;
  case WIFI_PROV_END:
    wifi_prov_mgr_deinit();
    break;
  default:
    break;
  }
}

static void wifi_event_handler(void *arg, esp_event_base_t event_base,
                               int32_t event_id, void *event_data) {
  if (event_id == WIFI_EVENT_STA_START) {
    ESP_LOGI(APP_TAG, "Station started connecting");
    esp_wifi_connect();

    if (provisioned) {
      connecting_handler();
    }
  } else if (event_id == WIFI_EVENT_STA_DISCONNECTED) {
    ESP_LOGI(APP_TAG, "Station disconnected");
    disconnected_handler();

    if (provisioned) {
      vTaskDelay(5000 / portTICK_PERIOD_MS);
      esp_wifi_connect();
      connecting_handler();
      ESP_LOGI(APP_TAG, "Attempting reconnect");
    }
  }
}

static void ip_event_handler(void *arg, esp_event_base_t event_base,
                             int32_t event_id, void *event_data) {
  if (event_id == IP_EVENT_STA_GOT_IP) {
    ip_event_got_ip_t *event = (ip_event_got_ip_t *)event_data;
    ESP_LOGI(APP_TAG, "Recieved IP:" IPSTR, IP2STR(&event->ip_info.ip));
    connected_handler();
  }
}

static void setup_flash() {
  esp_err_t err = nvs_flash_init();
  if (err == ESP_ERR_NVS_NO_FREE_PAGES ||
      err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
    ESP_ERROR_CHECK(nvs_flash_erase());
    err = nvs_flash_init();
  }
  ESP_ERROR_CHECK(err);
  ESP_LOGI(APP_TAG, "Flash setup successful");
}

static void setup_handlers() {
  ESP_ERROR_CHECK(esp_event_handler_register(WIFI_PROV_EVENT, ESP_EVENT_ANY_ID,
                                             wifi_prov_event_handler, NULL));
  ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID,
                                             wifi_event_handler, NULL));
  ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP,
                                             ip_event_handler, NULL));
}

static void setup_wifi() {
  ESP_ERROR_CHECK(esp_netif_init());
  ESP_ERROR_CHECK(esp_event_loop_create_default());

  esp_netif_create_default_wifi_sta();
  esp_netif_create_default_wifi_ap();

  wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
  ESP_ERROR_CHECK(esp_wifi_init(&cfg));
}

static void setup_provisioning() {
  wifi_prov_mgr_config_t config = {
      .scheme = wifi_prov_scheme_softap,
      .scheme_event_handler = WIFI_PROV_EVENT_HANDLER_NONE, // Clean up thingy
  };

  ESP_ERROR_CHECK(wifi_prov_mgr_init(config));
  ESP_LOGI(APP_TAG, "Provisioning configured");
}

static void start_provisioning() {
  wifi_prov_mgr_is_provisioned(&provisioned);

  if (provisioned) {
    ESP_LOGI(APP_TAG, "Already provisioned");
    wifi_prov_mgr_deinit();
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_start());
  } else {
    wifi_prov_security_t security = WIFI_PROV_SECURITY_1;
    wifi_prov_security1_params_t *pop = NULL; // NO POP
    const char *service_key = NULL;
    ESP_ERROR_CHECK(wifi_prov_mgr_start_provisioning(
        security, pop, SERVICE_NAME, service_key));
  }
}

void configure_wifi(callback connecting, callback connected,
                    callback disconnected) {
  connecting_handler = connecting;
  connected_handler = connected;
  disconnected_handler = disconnected;

  setup_flash();
  setup_wifi();
  setup_handlers();
  setup_provisioning();
  start_provisioning();
}

void reset_provisioning() { wifi_prov_mgr_reset_provisioning(); }
