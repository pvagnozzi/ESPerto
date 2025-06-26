// gpio.hpp
// GPIO management class for ESP32 (C++/OOP)
// Author: ESPerto Contributors
// License: MIT

#pragma once

#include "object.hpp"
#include "types.hpp"
#include <functional>
#include <memory>
#include <esp_attr.h>
extern "C" {
#include "driver/gpio.h"
}

namespace esperto {

/**
 * @brief Class to manage GPIO functionality in an OOP way.
 */
class Gpio : public Object {
public:
    using InterruptCallback = std::function<void(Gpio&)>;

    /**
     * @brief Construct a GPIO object for a given pin.
     * @param pin GPIO number (e.g., GPIO_NUM_2)
     */
    explicit Gpio(gpio_num_t pin);

    /**
     * @brief Destructor that cleans up interrupt handlers.
     */
    virtual ~Gpio();

    /**
     * @brief Set the direction of the GPIO pin.
     * @param mode GPIO_MODE_INPUT, GPIO_MODE_OUTPUT, etc.
     */
    void setDirection(gpio_mode_t mode);

    /**
     * @brief Set the output level of the GPIO pin.
     * @param level 0 = Low, 1 = High
     */
    void setLevel(uint32_t level);

    /**
     * @brief Get the input level of the GPIO pin.
     * @return 0 = Low, 1 = High
     */
    int getLevel() const;

    /**
     * @brief Enable or disable the internal pull-up resistor.
     * @param enable true to enable, false to disable
     */
    void setPullup(bool enable);

    /**
     * @brief Enable or disable the internal pull-down resistor.
     * @param enable true to enable, false to disable
     */
    void setPulldown(bool enable);

    /**
     * @brief Enable interrupt on this GPIO pin.
     * @param interruptType Type of interrupt (GPIO_INTR_POSEDGE, GPIO_INTR_NEGEDGE, etc.)
     * @param callback Function to call when interrupt occurs
     */
    void enableInterrupt(gpio_int_type_t interruptType, InterruptCallback callback);

    /**
     * @brief Disable interrupt on this GPIO pin.
     */
    void disableInterrupt();

    /**
     * @brief Check if interrupt is enabled on this pin.
     * @return true if interrupt is enabled, false otherwise
     */
    bool isInterruptEnabled() const;

    /**
     * @brief Get the pin number managed by this object.
     */
    gpio_num_t getPin() const;

    // Object interface
    bool equals(const Object& other) const override;

private:
    gpio_num_t m_pin;
    InterruptCallback m_callback;
    bool m_interruptEnabled;
    
    static void IRAM_ATTR gpio_isr_handler(void* arg);
    static bool s_gpio_service_installed;
};

} // namespace esperto
