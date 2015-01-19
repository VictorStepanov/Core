#pragma once

#if _MSC_VER < 1500
#error Visual Studio 2008 SP1 required.
#endif

#include <intrin.h>

#define HELIUM_CC_CL 1

#if _MSC_VER < 1700
# define HELIUM_CPP11 0
#else
# define HELIUM_CPP11 1
#endif

/// Declare a class method as overriding a virtual method of a parent class.
#define HELIUM_OVERRIDE override
/// Declare a class as an abstract base class.
#define HELIUM_ABSTRACT abstract

/// DLL export API declaration.
#define HELIUM_API_EXPORT __declspec( dllexport )
/// DLL import API declaration.
#define HELIUM_API_IMPORT __declspec( dllimport )

/// Attribute for forcing the compiler to inline a function.
#define HELIUM_FORCEINLINE __forceinline

/// Attribute for explicitly defining a pointer or reference as not being externally aliased.
#define HELIUM_RESTRICT __restrict

/// Prefix macro for declaring type or variable alignment.
///
/// @param[in] ALIGNMENT  Byte alignment (must be a power of two).
#define HELIUM_ALIGN_PRE( ALIGNMENT ) __declspec( align( ALIGNMENT ) )

/// Suffix macro for declaring type or variable alignment.
///
/// @param[in] ALIGNMENT  Byte alignment (must be a power of two).
#define HELIUM_ALIGN_POST( ALIGNMENT )

/// Mark variable as actually used (omit unused variable warning)
#define HELIUM_UNUSED(expr) (void)(expr)

// Template classes shouldn't be DLL exported, but the compiler warns us by default.
#pragma warning( disable : 4251 ) // 'identifier' : class 'type' needs to have dll-interface to be used by clients of class 'type2'
// Visual C++ does not support exception specifications at this time, but we still want to retain them for compilers
// that do support them.  This is harmless to ignore.
#pragma warning( disable : 4290 ) // C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
// Visual C++ specific keywords such as "override" and "abstract" are used, but are abstracted via "HELIUM_OVERRIDE" and
// "HELIUM_ABSTRACT" macros.
#pragma warning( disable : 4481 ) // nonstandard extension used: override specifier 'keyword'
// This spuriously comes up on occasion with certain template class methods.
#pragma warning( disable : 4505 ) // 'function' : unreferenced local function has been removed

#if _MSC_VER == 1500
#pragma warning( disable : 4985 ) // ceil() flawed in vs2008 headers
#endif
