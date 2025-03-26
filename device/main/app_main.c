#include "button/button.h"
#include "esp_system.h"
#include "wifi.h"
#include <freertos/FreeRTOS.h>
#include <freertos/event_groups.h>
#include <freertos/task.h>

#include <driver/gpio.h>
#include <esp_event.h>
#include <esp_log.h>
#include <esp_wifi.h>
#include <nvs_flash.h>

#include <wifi_provisioning/manager.h>
#include <wifi_provisioning/scheme_softap.h>

bool state = false;

void connecting() { ESP_LOGI("APP_TAG", "FAST BLINK"); }

void connected() { ESP_LOGI("APP_TAG", "LED SOLID"); }

void disconnected() { ESP_LOGI("APP_TAG", "SLOW BLINK"); }

void button_pressed() {
  if (xTaskGetTickCount() > pdMS_TO_TICKS(1000)) {
      reset_provisioning();
      esp_restart();
  }
}

void app_main(void) {
  configure_wifi(connecting, connected, disconnected);
  configure_button(button_pressed);
}
