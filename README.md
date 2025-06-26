# ESPerto Firmware 🚀

A professional ESP32 firmware project with OTA (Over-The-Air) WiFi update support.

## Features ✨

- ESP32 chip info display
- WiFi connection (STA mode)
- OTA firmware update via HTTPS
- FreeRTOS-based main loop
- Automatic restart after update
- Dev Container support for VS Code ([`.devcontainer`](.devcontainer/) folder)

## Getting Started 🛠️

### Requirements

- ESP32 development board
- PlatformIO or ESP-IDF toolchain
- WiFi network credentials
- HTTPS server hosting your firmware binary

### Build & Flash

1. Clone this repository:

   ```sh
   git clone https://github.com/yourusername/ESPerto.git
   ```

2. Configure your WiFi SSID, password, and OTA URL in `src/ota_wifi.c`:

   ```c
   #define WIFI_SSID      "YOUR_WIFI_SSID"
   #define WIFI_PASS      "YOUR_WIFI_PASSWORD"
   #define OTA_URL        "https://your-server.com/firmware.bin"
   ```

3. Build and upload the firmware:

   ```sh
   pio run --target upload
   ```

   or using ESP-IDF:

   ```sh
   idf.py build && idf.py -p <PORT> flash
   ```

### OTA Update 🔄

- On boot, the device connects to WiFi and checks the OTA URL for a new firmware binary.
- If an update is available, it is downloaded and flashed automatically.
- The device restarts after a successful update.

### Dev Container 🐳

- Open the project in VS Code and use the Dev Containers extension for a ready-to-code environment.
- Includes PlatformIO, ESP-IDF, CMake, Python, and all recommended extensions.

## File Structure 📁

```text
ESPerto/
├── include/         # Header files
│   └── ota_wifi.h   # OTA WiFi API
├── src/             # Source files
│   ├── main.c       # Main application
│   └── ota_wifi.c   # OTA WiFi implementation
├── .devcontainer/   # Dev Container config
│   └── devcontainer.json
├── platformio.ini   # PlatformIO config
├── sdkconfig.esp32dev # ESP-IDF config
└── ...
```

## Customization 📝

- Edit `WIFI_SSID`, `WIFI_PASS`, and `OTA_URL` in `src/ota_wifi.c` to match your environment.
- Extend `main.c` for your application logic.

## Contributing 🤝

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License 📄

This project is licensed under the MIT License. See [LICENSE](LICENSE).

---

Made with ❤️ for ESP32 enthusiasts.
