/**
 * @file types.hpp
 * @brief Platform-independent base types for ESPerto projects.
 * @author ESPerto Contributors
 * @license MIT
 */

#pragma once

// Platform-independent base types
#include <cstdint>
#include <string>
#include <string_view>

namespace esperto {

/** 8-bit signed integer. */
using int8  = std::int8_t;
/** 16-bit signed integer. */
using int16 = std::int16_t;
/** 32-bit signed integer. */
using int32 = std::int32_t;
/** 64-bit signed integer. */
using int64 = std::int64_t;

/** 8-bit unsigned integer. */
using uint8  = std::uint8_t;
/** 16-bit unsigned integer. */
using uint16 = std::uint16_t;
/** 32-bit unsigned integer. */
using uint32 = std::uint32_t;
/** 64-bit unsigned integer. */
using uint64 = std::uint64_t;

/** 32-bit floating point. */
using float32 = float;
/** 64-bit floating point. */
using float64 = double;

/** 8-bit boolean. */
using bool8 = uint8;

/** 8-bit character. */
using char8  = char;
/** 16-bit character. */
using char16 = char16_t;
/** 32-bit character. */
using char32 = char32_t;

/** UTF-8 string. */
using string  = std::string;
/** UTF-8 string view. */
using string_view = std::string_view;
/** UTF-16 string. */
using u16string = std::u16string;
/** UTF-32 string. */
using u32string = std::u32string;

} // namespace esperto