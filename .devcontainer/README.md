# ESPerto Project - DevContainer Documentation

## Development Container for ESP32 

This devcontainer provides a complete ESP32 development environment for the ESPerto project with:

### 🛠️ Tools Included
- **ESP-IDF v5.1** - Official Espressif development framework
- **PlatformIO** - Advanced IDE for embedded development
- **Boost Libraries** - C++ libraries for ESP32
- **OpenOCD** - On-chip debugging
- **Serial Monitors** - For ESP32 communication

### 🎯 Quick Start Commands
```bash
# Build project
pio-build

# Upload to ESP32
pio-upload

# Monitor serial output
pio-monitor

# Full workflow (clean + build + upload + monitor)
pio-full
```

### 📦 Features
- ✅ USB device forwarding for ESP32 flashing
- ✅ Persistent PlatformIO cache
- ✅ Pre-configured VS Code extensions
- ✅ Automatic environment setup
- ✅ Debug server support (OpenOCD on port 3333)

### 🔌 Hardware Setup
1. Connect your ESP32 board via USB
2. The devcontainer will automatically detect it
3. Use the provided aliases for development

### 🐛 Debugging
- OpenOCD debug server available on port 3333
- GDB multiarch support included
- Cortex-Debug extension pre-installed

### 📝 Project Structure
```
ESPerto/
├── .devcontainer/          # Development container config
├── lib/esperto/            # ESPerto C++ library
│   ├── headers/            # Header files
│   └── src/               # Implementation files
├── src/                   # Main application
└── platformio.ini         # PlatformIO configuration
```

### 🎨 VS Code Extensions
- C/C++ IntelliSense
- PlatformIO IDE
- ESP-IDF Extension
- Serial Monitor
- CMake Tools
- And more...

Built for the ESPerto ESP32 C++ framework project.
