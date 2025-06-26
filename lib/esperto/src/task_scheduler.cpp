// task_scheduler.cpp
// Implementation of TaskScheduler class for ESP32 FreeRTOS
// Author: ESPerto Contributors
// License: MIT

#include "../headers/task_scheduler.hpp"
#include <algorithm>
#include <cstdio>

namespace esperto {

TaskScheduler& TaskScheduler::instance() {
    static TaskScheduler scheduler;
    return scheduler;
}

std::shared_ptr<Task> TaskScheduler::startNew(Task::TaskFunction func, const esperto::string& name, esperto::uint32 stackSize, UBaseType_t priority) {
    auto task = std::make_shared<Task>(func, name, stackSize, priority);
    task->start();
    m_tasks.push_back(task);
    return task;
}

std::vector<std::shared_ptr<Task>> TaskScheduler::getTasks() const {
    return m_tasks;
}

void TaskScheduler::remove(const std::shared_ptr<Task>& task) {
    m_tasks.erase(std::remove(m_tasks.begin(), m_tasks.end(), task), m_tasks.end());
}

void TaskScheduler::suspendAll() {
    for (auto& task : m_tasks) {
        if (task && task->isRunning()) {
            task->suspend();
        }
    }
}

void TaskScheduler::resumeAll() {
    for (auto& task : m_tasks) {
        if (task && task->getState() == Task::TaskState::Suspended) {
            task->resume();
        }
    }
}

size_t TaskScheduler::getTaskCount() const {
    return m_tasks.size();
}

void TaskScheduler::cleanupCompletedTasks() {
    m_tasks.erase(
        std::remove_if(m_tasks.begin(), m_tasks.end(), 
            [](const std::shared_ptr<Task>& task) {
                return task && task->isCompleted();
            }), 
        m_tasks.end()
    );
}

void TaskScheduler::waitForAll() {
    for (auto& task : m_tasks) {
        if (task && !task->isCompleted()) {
            task->wait();
        }
    }
}

void TaskScheduler::printTaskStatistics() const {
    printf("TaskScheduler Statistics:\n");
    printf("Total tasks: %zu\n", m_tasks.size());
    
    size_t running = 0, suspended = 0, completed = 0;
    
    for (const auto& task : m_tasks) {
        if (task) {
            switch (task->getState()) {
                case Task::TaskState::Running:
                    running++;
                    break;
                case Task::TaskState::Suspended:
                    suspended++;
                    break;
                case Task::TaskState::Completed:
                case Task::TaskState::Deleted:
                    completed++;
                    break;
                default:
                    break;
            }
        }
    }
    
    printf("Running: %zu, Suspended: %zu, Completed: %zu\n", running, suspended, completed);
}

bool TaskScheduler::equals(const Object& other) const {
    // Singleton: only one instance exists
    return this == &other;
}

} // namespace esperto
