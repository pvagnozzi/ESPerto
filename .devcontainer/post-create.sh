#!/bin/bash
# post-create.sh
# ESPerto ESP32 Development Environment Setup Script

echo "🚀 Setting up ESPerto ESP32 Development Environment..."

# Update system packages
sudo apt-get update

# Install PlatformIO Core
echo "📦 Installing PlatformIO Core..."
python3 -m pip install --upgrade pip setuptools
python3 -m pip install --user platformio

# Add PlatformIO to PATH
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
echo 'export PATH=$PATH:~/.local/bin' >> ~/.zshrc
source ~/.bashrc || true

# Install ESP-IDF
echo "📦 Installing ESP-IDF..."
mkdir -p ~/esp
cd ~/esp
if [ ! -d "esp-idf" ]; then
    git clone --recursive https://github.com/espressif/esp-idf.git
fi
cd esp-idf
git checkout release/v5.1
./install.sh esp32

# Setup ESP-IDF environment
echo 'alias get_idf=". ~/esp/esp-idf/export.sh"' >> ~/.bashrc
echo 'alias get_idf=". ~/esp/esp-idf/export.sh"' >> ~/.zshrc

# Setup USB permissions for ESP32 flashing
echo "🔧 Setting up USB permissions..."
sudo usermod -a -G dialout $USER
sudo usermod -a -G plugdev $USER

# Create udev rules for ESP32
sudo tee /etc/udev/rules.d/99-esp32.rules > /dev/null <<'EOF'
# ESP32 Development Board
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", GROUP="dialout", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", GROUP="dialout", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", GROUP="dialout", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", GROUP="dialout", MODE="0666"
EOF

sudo udevadm control --reload-rules || true
sudo udevadm trigger || true

# Initialize PlatformIO project
echo "🔧 Initializing PlatformIO project..."
cd /workspaces/ESPerto
~/.local/bin/pio pkg install || true

# Set proper permissions
echo "🔧 Setting file permissions..."
sudo chown -R vscode:vscode /workspaces/ESPerto || true
sudo chown -R vscode:vscode ~/.platformio || true

# Create helpful aliases
echo "🔧 Setting up development aliases..."
cat >> ~/.zshrc << 'EOF'

# ESPerto Development Aliases
alias pio-build='~/.local/bin/pio run'
alias pio-upload='~/.local/bin/pio run --target upload'
alias pio-monitor='~/.local/bin/pio device monitor'
alias pio-clean='~/.local/bin/pio run --target clean'
alias pio-erase='~/.local/bin/pio run --target erase'
alias esp-build='get_idf && idf.py build'
alias esp-flash='get_idf && idf.py flash'
alias esp-monitor='get_idf && idf.py monitor'
alias esp-clean='get_idf && idf.py clean'

# Useful development functions
esp-full() {
    get_idf && idf.py clean && idf.py build && idf.py flash && idf.py monitor
}

pio-full() {
    ~/.local/bin/pio run --target clean && ~/.local/bin/pio run --target upload && ~/.local/bin/pio device monitor
}
EOF

# Copy aliases to bashrc too
cat >> ~/.bashrc << 'EOF'

# ESPerto Development Aliases
alias pio-build='~/.local/bin/pio run'
alias pio-upload='~/.local/bin/pio run --target upload'
alias pio-monitor='~/.local/bin/pio device monitor'
alias pio-clean='~/.local/bin/pio run --target clean'
alias pio-erase='~/.local/bin/pio run --target erase'
alias esp-build='get_idf && idf.py build'
alias esp-flash='get_idf && idf.py flash'
alias esp-monitor='get_idf && idf.py monitor'
alias esp-clean='get_idf && idf.py clean'

# Useful development functions
esp-full() {
    get_idf && idf.py clean && idf.py build && idf.py flash && idf.py monitor
}

pio-full() {
    ~/.local/bin/pio run --target clean && ~/.local/bin/pio run --target upload && ~/.local/bin/pio device monitor
}
EOF

echo "✅ ESPerto ESP32 Development Environment setup complete!"
echo ""
echo "🎯 Available commands:"
echo "  - pio-build    : Build the project"
echo "  - pio-upload   : Upload to ESP32"
echo "  - pio-monitor  : Open serial monitor"
echo "  - esp-build    : Build with ESP-IDF"
echo "  - esp-flash    : Flash with ESP-IDF"
echo "  - esp-monitor  : Monitor with ESP-IDF"
echo "  - esp-full     : Clean, build, flash, and monitor"
echo "  - pio-full     : Clean, upload, and monitor"
echo ""
echo "🔌 Don't forget to connect your ESP32 board!"
echo "📝 Restart your terminal or run 'source ~/.zshrc' to use the new aliases"

# Install ESP-IDF
echo "📦 Installing ESP-IDF..."
mkdir -p ~/esp
cd ~/esp
git clone --recursive https://github.com/espressif/esp-idf.git
cd esp-idf
git checkout release/v5.1
./install.sh esp32

# Setup ESP-IDF environment
echo 'alias get_idf=". ~/esp/esp-idf/export.sh"' >> ~/.bashrc
echo 'alias get_idf=". ~/esp/esp-idf/export.sh"' >> ~/.zshrc

# Install Boost libraries for ESP32 (header-only)
echo "📦 Installing Boost libraries..."
sudo apt-get install -y libboost-all-dev

# Setup USB permissions for ESP32 flashing
echo "🔧 Setting up USB permissions..."
sudo usermod -a -G dialout $USER
sudo usermod -a -G plugdev $USER

# Create udev rules for ESP32
sudo tee /etc/udev/rules.d/99-esp32.rules > /dev/null <<EOF
# ESP32 Development Board
SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", GROUP="dialout", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", GROUP="dialout", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", GROUP="dialout", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", GROUP="dialout", MODE="0666"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger

# Initialize PlatformIO project if not already done
echo "🔧 Initializing PlatformIO project..."
cd /workspaces/ESPerto
if [ ! -f "platformio.ini" ]; then
    pio project init --board esp32dev --project-option="framework=espidf"
fi

# Install project dependencies
echo "📦 Installing project dependencies..."
pio pkg install

# Set proper permissions
echo "🔧 Setting file permissions..."
sudo chown -R vscode:vscode /workspaces/ESPerto
sudo chown -R vscode:vscode ~/.platformio

# Create helpful aliases
echo "🔧 Setting up development aliases..."
cat >> ~/.zshrc << EOF

# ESPerto Development Aliases
alias pio-build='pio run'
alias pio-upload='pio run --target upload'
alias pio-monitor='pio device monitor'
alias pio-clean='pio run --target clean'
alias pio-erase='pio run --target erase'
alias esp-build='get_idf && idf.py build'
alias esp-flash='get_idf && idf.py flash'
alias esp-monitor='get_idf && idf.py monitor'
alias esp-clean='get_idf && idf.py clean'

# Useful development functions
esp-full() {
    get_idf && idf.py clean && idf.py build && idf.py flash && idf.py monitor
}

pio-full() {
    pio run --target clean && pio run --target upload && pio device monitor
}
EOF

echo "✅ ESPerto ESP32 Development Environment setup complete!"
echo ""
echo "🎯 Available commands:"
echo "  - pio-build    : Build the project"
echo "  - pio-upload   : Upload to ESP32"
echo "  - pio-monitor  : Open serial monitor"
echo "  - esp-build    : Build with ESP-IDF"
echo "  - esp-flash    : Flash with ESP-IDF"
echo "  - esp-monitor  : Monitor with ESP-IDF"
echo "  - esp-full     : Clean, build, flash, and monitor"
echo "  - pio-full     : Clean, upload, and monitor"
echo ""
echo "🔌 Don't forget to connect your ESP32 board!"
echo "📝 Restart your terminal or run 'source ~/.zshrc' to use the new aliases"
