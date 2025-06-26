// object.hpp
// Base Object class for all non-interface types (C#-like)
// Author: ESPerto Contributors
// License: MIT

#pragma once
#include <cstddef>

namespace esperto {

/**
 * @brief Base Object class for all non-interface types.
 *
 * Provides default implementations for equals and hashCode based on pointer identity.
 */
class Object {
public:
    /**
     * @brief Virtual destructor.
     */
    virtual ~Object() = default;

    /**
     * @brief Checks if this object is equal to another (default: pointer equality).
     * @param other The object to compare with.
     * @return true if the pointers are the same, false otherwise.
     */
    virtual bool equals(const Object& other) const {
        return this == &other;
    }
    
    /**
     * @brief Equals operators.
     * @param other The object to compare.
     * @return True if object are equals.
     */
    inline bool operator==(const Object& other) const {
        return equals(other);
    }

    /**
     * @brief Returns a hash code based on the object's pointer.
     * @return Hash code value (pointer cast to size_t).
     */
    virtual size_t hashCode() const {
        return reinterpret_cast<size_t>(this);
    }


};

} // namespace esperto