// ota_wifi.h
// ESPerto OTA WiFi update API
//
// This header defines the interface for starting OTA updates over WiFi
// and WiFi credentials for the ESP32 project. See ota_wifi.c for implementation.
//
// Author: ESPerto Contributors
// Date: 2025-05-20
// License: MIT

#pragma once

#define WIFI_SSID      "YOUR_WIFI_SSID"
#define WIFI_PASS      "YOUR_WIFI_PASSWORD"
#define OTA_URL        "https://your-server.com/firmware.bin"

void start_wifi_ota_task(const char* url);
