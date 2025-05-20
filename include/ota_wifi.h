#pragma once

#define WIFI_SSID      "YOUR_WIFI_SSID"
#define WIFI_PASS      "YOUR_WIFI_PASSWORD"
#define OTA_URL        "https://your-server.com/firmware.bin"

void start_wifi_ota_task(const char* url);
