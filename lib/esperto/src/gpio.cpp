// gpio.cpp
// Implementation of Gpio class for ESP32
// Author: ESPerto Contributors
// License: MIT

#include "../headers/gpio.hpp"

namespace esperto {

bool Gpio::s_gpio_service_installed = false;

Gpio::Gpio(gpio_num_t pin) : m_pin(pin), m_interruptEnabled(false) {    
    
    // Install GPIO ISR service if not already installed
    if (!s_gpio_service_installed) {
        gpio_install_isr_service(0);
        s_gpio_service_installed = true;
    }
}

Gpio::~Gpio() {
    if (m_interruptEnabled) {
        disableInterrupt();
    }
}

void Gpio::setDirection(gpio_mode_t mode) {
    gpio_set_direction(m_pin, mode);
}

void Gpio::setLevel(uint32_t level) {
    gpio_set_level(m_pin, level);
}

int Gpio::getLevel() const {
    return gpio_get_level(m_pin);
}

void Gpio::setPullup(bool enable) {
    gpio_set_pull_mode(m_pin, enable ? GPIO_PULLUP_ONLY : GPIO_FLOATING);
}

void Gpio::setPulldown(bool enable) {
    gpio_set_pull_mode(m_pin, enable ? GPIO_PULLDOWN_ONLY : GPIO_FLOATING);
}

void Gpio::enableInterrupt(gpio_int_type_t interruptType, InterruptCallback callback) {
    if (m_interruptEnabled) {
        disableInterrupt();
    }
    
    m_callback = callback;
    
    // Configure interrupt
    gpio_set_intr_type(m_pin, interruptType);
    gpio_isr_handler_add(m_pin, gpio_isr_handler, this);
    
    m_interruptEnabled = true;
}

void Gpio::disableInterrupt() {
    if (m_interruptEnabled) {
        gpio_isr_handler_remove(m_pin);
        gpio_set_intr_type(m_pin, GPIO_INTR_DISABLE);
        m_interruptEnabled = false;
        m_callback = nullptr;
    }
}

bool Gpio::isInterruptEnabled() const {
    return m_interruptEnabled;
}

gpio_num_t Gpio::getPin() const {
    return m_pin;
}

bool Gpio::equals(const Object& other) const {
    auto* o = static_cast<const Gpio*>(&other);
    return o && o->m_pin == m_pin;
}

void IRAM_ATTR Gpio::gpio_isr_handler(void* arg) {
    Gpio* gpio = static_cast<Gpio*>(arg);
    if (gpio && gpio->m_callback) {
        gpio->m_callback(*gpio);
    }
}

} // namespace esperto
