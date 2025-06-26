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
#include "driver/gpio.h"
#include "gpio.hpp"
#include "task_scheduler.hpp"

#define BLINK_GPIO GPIO_NUM_2

extern "C" void app_main(void)
{
    printf("Hello world!\n");
    fflush(stdout);
    
    // Create blink task using TaskScheduler and Gpio classes
    auto& scheduler = esperto::TaskScheduler::instance();
    auto blinkTask = scheduler.startNew([](esperto::Task& task) {
        esperto::Gpio led(BLINK_GPIO);
        led.setDirection(GPIO_MODE_OUTPUT);
        
        printf("Blink task started on GPIO %d\n", led.getPin());
        
        while (true) {
            led.setLevel(1);
            esperto::Task::delay(500); // Use Task::delay instead of vTaskDelay
            led.setLevel(0);
            esperto::Task::delay(500);
        }
    }, "BlinkTask", 2048, 5);
    
    printf("Blink task started with TaskScheduler\n");
    
    // Print task statistics every 5 seconds
    scheduler.startNew([](esperto::Task& task) {
        while (true) {
            esperto::Task::delay(5000);
            esperto::TaskScheduler::instance().printTaskStatistics();
        }
    }, "StatsTask", 2048, 3);
}