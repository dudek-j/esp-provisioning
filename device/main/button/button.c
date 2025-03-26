#include "button/button.h"
#include "driver/gpio.h"
#include "esp_attr.h"
#include "freertos/idf_additions.h"
#include "portmacro.h"

#define BUTTON_GPIO 9

static SemaphoreHandle_t button_sem;
callback button_callback;

static void IRAM_ATTR button_isr_handler() {
  xSemaphoreGiveFromISR(button_sem, NULL);
}

void button_task() {
  button_sem = xSemaphoreCreateBinary();

  for(;;) {
    xSemaphoreTake(button_sem, portMAX_DELAY);
    button_callback();
  }
}

void setup_button() {
  gpio_config_t io_conf = {};
  io_conf.intr_type = GPIO_INTR_NEGEDGE; // Falling edge (button down)
  io_conf.mode = GPIO_MODE_INPUT;
  io_conf.pin_bit_mask = (1 << BUTTON_GPIO);
  io_conf.pull_up_en = GPIO_PULLUP_ENABLE; // Enable internal pull-up resistor

  gpio_config(&io_conf);
  gpio_install_isr_service(0);
  gpio_isr_handler_add(BUTTON_GPIO, button_isr_handler, NULL);
}

void configure_button(callback handler) {
  button_callback = handler;
  setup_button();
  xTaskCreate(button_task, "BUTTON", 2048, NULL, 1, NULL);
}
