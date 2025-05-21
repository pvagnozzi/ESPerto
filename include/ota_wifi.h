// ota_wifi.h
// ESPerto OTA WiFi update API (C++)
//
// This header defines the interface for starting OTA updates over WiFi
// and WiFi credentials for the ESP32 project. See ota_wifi.cpp for implementation.
//
// Author: ESPerto Contributors
// Date: 2025-05-20
// License: MIT

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#define WIFI_SSID      "YOUR_WIFI_SSID"
#define WIFI_PASS      "YOUR_WIFI_PASSWORD"
#define OTA_URL        "https://your-server.com/firmware.bin"

void start_wifi_ota_task(const char* url);

#ifdef __cplusplus
}
#endif
