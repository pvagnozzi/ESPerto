// task.hpp
// Task class (C#/.NET-like) for ESP32 FreeRTOS
// Author: ESPerto Contributors
// License: MIT

#pragma once

#include "object.hpp"
#include "types.hpp"
#include <functional>
#include <string>
extern "C" {
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
}

namespace esperto {

/**
 * @brief Represents an asynchronous operation (C#-like Task) using FreeRTOS.
 */
class Task : public Object {
public:
    using TaskFunction = std::function<void(Task&)>;

    enum class TaskState {
        Created,    ///< Task has been created but not started
        Running,    ///< Task is currently running
        Suspended,  ///< Task has been suspended
        Completed,  ///< Task has completed execution
        Deleted     ///< Task has been deleted
    };

    /**
     * @brief Creates a new Task object (does not start it).
     * @param func The function to execute in the task.
     * @param name The task name.
     * @param stackSize Stack size in words.
     * @param priority Task priority.
     */
    Task(TaskFunction func, const esperto::string& name = "Task", esperto::uint32 stackSize = 4096, UBaseType_t priority = tskIDLE_PRIORITY + 1);

    /**
     * @brief Destroys the Task object and deletes the underlying FreeRTOS task.
     */
    virtual ~Task();

    /**
     * @brief Starts the task (if not started already).
     */
    virtual void start();

    /**
     * @brief Waits for the task to complete (join).
     */
    virtual void wait();

    /**
     * @brief Suspends the task.
     */
    virtual void suspend();

    /**
     * @brief Resumes the task.
     */
    virtual void resume();

    /**
     * @brief Gets the current state of the task.
     */
    virtual TaskState getState() const;

    /**
     * @brief Gets the FreeRTOS task handle.
     */
    virtual TaskHandle_t getHandle() const;

    /**
     * @brief Gets the task name.
     */
    virtual esperto::string getName() const;

    /**
     * @brief Gets the task stack size.
     */
    virtual esperto::uint32 getStackSize() const;

    /**
     * @brief Gets the task priority.
     */
    virtual UBaseType_t getPriority() const;

    /**
     * @brief Checks if the task is currently running.
     */
    virtual bool isRunning() const;

    /**
     * @brief Checks if the task has completed.
     */
    virtual bool isCompleted() const;

    /**
     * @brief Static method to delay the current task (wraps vTaskDelay).
     * @param delayMs Delay time in milliseconds
     */
    static void delay(esperto::uint32 delayMs);

    /**
     * @brief Static method to delay the current task in ticks (wraps vTaskDelay).
     * @param delayTicks Delay time in FreeRTOS ticks
     */
    static void delayTicks(TickType_t delayTicks);

    /**
     * @brief Static method to yield the current task (wraps taskYIELD).
     */
    static void yield();

    // Object interface
    bool equals(const Object& other) const override;

private:
    TaskFunction m_func;
    esperto::string m_name;
    esperto::uint32 m_stackSize;
    UBaseType_t m_priority;
    TaskHandle_t m_handle;
    TaskState m_state;
    
    static void taskEntryPoint(void* param);
    TaskState convertFreeRTOSState(eTaskState freeRTOSState) const;
};

} // namespace esperto
