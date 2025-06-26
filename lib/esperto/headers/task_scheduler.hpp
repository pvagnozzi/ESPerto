// task_scheduler.hpp
// TaskScheduler class (C#/.NET-like) for ESP32 FreeRTOS
// Author: ESPerto Contributors
// License: MIT

#pragma once

#include "object.hpp"
#include "task.hpp"
#include <vector>
#include <memory>

namespace esperto {

/**
 * @brief Schedules and manages multiple Task objects (C#-like TaskScheduler).
 */
class TaskScheduler : public Object {
public:
    /**
     * @brief Gets the singleton instance of the scheduler.
     */
    static TaskScheduler& instance();

    /**
     * @brief Starts a new task and adds it to the scheduler.
     * @param func The function to execute.
     * @param name The task name.
     * @param stackSize Stack size in words.
     * @param priority Task priority.
     * @return Shared pointer to the created Task.
     */
    std::shared_ptr<Task> startNew(Task::TaskFunction func, const esperto::string& name = "Task", esperto::uint32 stackSize = 4096, UBaseType_t priority = tskIDLE_PRIORITY + 1);

    /**
     * @brief Gets all managed tasks.
     */
    std::vector<std::shared_ptr<Task>> getTasks() const;

    /**
     * @brief Removes a task from the scheduler.
     */
    void remove(const std::shared_ptr<Task>& task);

    /**
     * @brief Suspends all tasks.
     */
    void suspendAll();

    /**
     * @brief Resumes all tasks.
     */
    void resumeAll();

    /**
     * @brief Gets the count of active tasks.
     */
    size_t getTaskCount() const;

    /**
     * @brief Cleans up completed tasks from the scheduler.
     */
    void cleanupCompletedTasks();

    /**
     * @brief Waits for all tasks to complete.
     */
    void waitForAll();

    /**
     * @brief Gets statistics about running tasks.
     */
    void printTaskStatistics() const;

    // Object interface
    bool equals(const Object& other) const override;

private:
    TaskScheduler() = default;
    std::vector<std::shared_ptr<Task>> m_tasks;
};

} // namespace esperto
