// main.cpp
// ESPerto main application entry point (C++)
//
// This file initializes the ESP32, prints chip information, starts OTA WiFi update,
// and manages the main restart loop. See README.md for project details.
//
// Author: ESPerto Contributors
// Date: 2025-05-20
// License: MIT

extern "C" {
#include "sdkconfig.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_chip_info.h"
#include "esp_flash.h"
}
#include <cstdio>
#include "../lib/esperto/headers/task.hpp"

// Example of a FreeRTOS-compatible task function
void example_task(void* pvParameters) {
    while (true) {
        printf("[Task] Task running!\n");
        vTaskDelay(2000 / portTICK_PERIOD_MS);
    }
}

extern "C" void app_main(void)
{
    printf("Hello world!\n");

    // Start an example task using the C++ wrapper
    static esperto::Task myTask("ExampleTask", example_task);

    // Start OTA WiFi (edit URL and credentials in ota_wifi.cpp)


    /* Print chip information */
    esp_chip_info_t chip_info;
    uint32_t flash_size;
    esp_chip_info(&chip_info);
    printf("This is %s chip with %d CPU core(s), WiFi%s%s, ",
           CONFIG_IDF_TARGET,
           chip_info.cores,
           (chip_info.features & CHIP_FEATURE_BT) ? "/BT" : "",
           (chip_info.features & CHIP_FEATURE_BLE) ? "/BLE" : "");

    unsigned major_rev = chip_info.revision / 100;
    unsigned minor_rev = chip_info.revision % 100;
    printf("silicon revision v%d.%d, ", major_rev, minor_rev);
    if(esp_flash_get_size(NULL, &flash_size) != ESP_OK) {
        printf("Get flash size failed");
        return;
    }

    printf("%uMB %s flash\n", (unsigned int) flash_size / (1024 * 1024),
           (chip_info.features & CHIP_FEATURE_EMB_FLASH) ? "embedded" : "external");

    printf("Minimum free heap size: %d bytes\n", (int) esp_get_minimum_free_heap_size());

    for (int i = 10; i >= 0; i--) {
        printf("Restarting in %d seconds...\n", i);
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }
    printf("Restarting now.\n");
    fflush(stdout);
    esp_restart();
}