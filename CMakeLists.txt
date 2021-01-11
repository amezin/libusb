cmake_minimum_required(VERSION 3.12.0 FATAL_ERROR)

file(READ libusb/version.h LU_VERSION_H)

function(LU_DEFINE_VERSION_ATOM var_name)
    if(LU_VERSION_H MATCHES "#define[ \\t]+${var_name}[ \\t]([0-9]+)")
        set("${var_name}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
    endif()
endfunction()

function(LU_DEFINE_VERSION_RC_ATOM var_name)
    if(LU_VERSION_H MATCHES "#define[ \\t]+${var_name}[ \\t]\"(-rc[0-9]*)\"")
        set("${var_name}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
    endif()
endfunction()

LU_DEFINE_VERSION_ATOM(LIBUSB_MAJOR)
LU_DEFINE_VERSION_ATOM(LIBUSB_MINOR)
LU_DEFINE_VERSION_ATOM(LIBUSB_MICRO)
LU_DEFINE_VERSION_RC_ATOM(LIBUSB_RC)

project(
    libusb
    VERSION "${LIBUSB_MAJOR}.${LIBUSB_MINOR}.${LIBUSB_MICRO}${LIBUSB_RC}"
    LANGUAGES C CXX
    HOMEPAGE_URL http://libusb.info
)

set(CMAKE_C_STANDARD 11)

include(CheckCSourceCompiles)
include(CheckFunctionExists)
include(CheckLibraryExists)

check_c_source_compiles(
    "_Thread_local int x; int main(void) { x = 42; return 0; }"
    c11_thread_local_supported
)
if(NOT c11_thread_local_supported)
    message(FATAL_ERROR "compiler with C11 support is required to build libusb")
endif()

unset(is_android_linux)

if(APPLE)
    set(backend darwin)
    set(platform posix)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Haiku")
    set(backend haiku)
    set(platform posix)
elseif(ANDROID)
    set(backend linux)
    set(platform posix)
    set(is_android_linux ON)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(backend linux)
    set(platform posix)
elseif(CYGWIN)
    set(backend windows)
    set(platform windows)
    add_compile_options(-mwin32)  # is this necessary?
elseif(MINGW)
    set(backend windows)
    set(platform windows)
    add_compile_options(-mwin32 -fno-omit-frame-pointer)  # is this necessary?
elseif(WIN32)
    set(backend windows)
    set(platform windows)
elseif(CMAKE_SYSTEM_NAME STREQUAL "NetBSD")
    set(backend netbsd)
    set(platform posix)
elseif(CMAKE_SYSTEM_NAME STREQUAL "OpenBSD")
    set(backend openbsd)
    set(platform posix)
elseif(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
    set(backend sunos)
    set(platform posix)
else()
    message(WARNING "The host being compiled for is not supported.")
    message(WARNING "The library may compile but will not function in any useful manner.")
    set(backend null)
    set(platform posix)
endif()

if(platform STREQUAL "posix")
    set(PLATFORM_POSIX 1)

    check_c_source_compiles("#include <poll.h>\nint main(void) { nfds_t foo; return 0; }" HAVE_NFDS_T)
    check_function_exists(pipe2 HAVE_PIPE2)

elseif(platform STREQUAL "windows")
    set(PLATFORM_WINDOWS 1)
else()
    message(FATAL_ERROR "Unknown platform ${platform}")
endif()

find_package(Threads REQUIRED)
link_libraries(Threads::Threads)
set(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} Threads::Threads)

if(backend STREQUAL "darwin")
    check_function_exists(pthread_threadid_np HAVE_PTHREAD_THREADID_NP)

    find_library(IOKIT_FRAMEWORK IOKit REQUIRED)
    link_libraries("${IOKIT_FRAMEWORK}")

    find_library(COREFOUNDATION_FRAMEWORK CoreFoundation REQUIRED)
    link_libraries("${COREFOUNDATION_FRAMEWORK}")
elseif(backend STREQUAL "haiku")
    link_libraries(be)
elseif(backend STREQUAL "linux")
    check_function_exists(clock_gettime HAVE_CLOCK_GETTIME)
    if(NOT HAVE_CLOCK_GETTIME)
        check_library_exists(rt clock_gettime "" HAVE_CLOCK_GETTIME)
        if(HAVE_CLOCK_GETTIME)
            link_libraries(rt)
        endif()
    endif()

    check_function_exists(pthread_setname_np HAVE_PTHREAD_SETNAME_NP)

    option(WITH_UDEV "use udev for device enumeration and hotplug support (recommended)" ON)
    if(WITH_UDEV)
    else()
    endif()
elseif(backend STREQUAL "sunos")
    link_libraries(devinfo)
elseif(backend STREQUAL "windows")
    check_c_source_compiles("#include <time.h>\nint main(void) { struct timespec foo; return 0; }" HAVE_STRUCT_TIMESPEC)
endif()

configure_file(config.h.cmake config.h @ONLY)
