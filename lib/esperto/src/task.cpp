// task.cpp
// Implementation of Task class for ESP32 FreeRTOS
// Author: ESPerto Contributors
// License: MIT

#include "../headers/task.hpp"
#include <utility>

namespace esperto {

Task::Task(TaskFunction func, const esperto::string& name, esperto::uint32 stackSize, UBaseType_t priority)
    : m_func(std::move(func)), m_name(name), m_stackSize(stackSize), m_priority(priority), 
      m_handle(nullptr), m_state(TaskState::Created) {}

Task::~Task() {
    if (m_handle && m_state != TaskState::Deleted) {
        vTaskDelete(m_handle);
        m_handle = nullptr;
        m_state = TaskState::Deleted;
    }
}

void Task::start() {
    if (m_state == TaskState::Created && m_func) {
        BaseType_t result = xTaskCreate(
            &Task::taskEntryPoint,
            m_name.c_str(),
            m_stackSize,
            this,
            m_priority,
            &m_handle
        );
        if (result == pdPASS) {
            m_state = TaskState::Running;
        }
    }
}

void Task::wait() {
    // Wait for task completion by monitoring its state
    while (m_state == TaskState::Running || m_state == TaskState::Suspended) {
        if (m_handle) {
            eTaskState freeRTOSState = eTaskGetState(m_handle);
            m_state = convertFreeRTOSState(freeRTOSState);
            if (m_state == TaskState::Completed || m_state == TaskState::Deleted) {
                break;
            }
        }
        vTaskDelay(pdMS_TO_TICKS(10)); // Small delay to avoid busy waiting
    }
}

void Task::suspend() {
    if (m_handle && m_state == TaskState::Running) {
        vTaskSuspend(m_handle);
        m_state = TaskState::Suspended;
    }
}

void Task::resume() {
    if (m_handle && m_state == TaskState::Suspended) {
        vTaskResume(m_handle);
        m_state = TaskState::Running;
    }
}

Task::TaskState Task::getState() const {
    if (m_handle && m_state != TaskState::Created) {
        // Update state based on FreeRTOS state
        eTaskState freeRTOSState = eTaskGetState(m_handle);
        return convertFreeRTOSState(freeRTOSState);
    }
    return m_state;
}

TaskHandle_t Task::getHandle() const {
    return m_handle;
}

esperto::string Task::getName() const {
    return m_name;
}

esperto::uint32 Task::getStackSize() const {
    return m_stackSize;
}

UBaseType_t Task::getPriority() const {
    return m_priority;
}

bool Task::isRunning() const {
    return getState() == TaskState::Running;
}

bool Task::isCompleted() const {
    TaskState state = getState();
    return state == TaskState::Completed || state == TaskState::Deleted;
}

void Task::delay(esperto::uint32 delayMs) {
    vTaskDelay(pdMS_TO_TICKS(delayMs));
}

void Task::delayTicks(TickType_t delayTicks) {
    vTaskDelay(delayTicks);
}

void Task::yield() {
    taskYIELD();
}

bool Task::equals(const Object& other) const {
    auto* o = static_cast<const Task*>(&other);
    return o && o->m_handle == m_handle;
}

void Task::taskEntryPoint(void* param) {
    Task* self = static_cast<Task*>(param);
    if (self && self->m_func) {        
        self->m_func(*self);
        self->m_state = TaskState::Completed;      
    }
    // Task will be automatically deleted by FreeRTOS when this function returns
    vTaskDelete(nullptr);
}

Task::TaskState Task::convertFreeRTOSState(eTaskState freeRTOSState) const {
    switch (freeRTOSState) {
        case eRunning:
            return TaskState::Running;
        case eSuspended:
            return TaskState::Suspended;
        case eDeleted:
            return TaskState::Deleted;
        case eReady:
        case eBlocked:
            return TaskState::Running; // Consider ready/blocked as running
        default:
            return TaskState::Completed;
    }
}

} // namespace esperto
