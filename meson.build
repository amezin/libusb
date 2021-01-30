project(
  'libusb-1.0',
  'c',
  version: '1.0.24',
  license: 'LGPL-2.1-or-later',
  meson_version: '>= 0.53',
  default_options: [
    'buildtype=debugoptimized',
    'warning_level=2',
    'b_ndebug=if-release',
    'c_std=gnu11'
  ]
)

cc = meson.get_compiler('c')

if cc.get_argument_syntax() == 'msvc'
  add_project_arguments('/D_CRT_SECURE_NO_WARNINGS', language: 'c')
endif

# from configure.ac
lt_current = 3
lt_revision = 0
lt_age = 3

lib_version_kwargs = {
  'version': '@0@.@1@.@2@'.format(lt_current - lt_age, lt_age, lt_revision)
}

cdata = configuration_data()

if cc.get_argument_syntax() == 'gcc'
  cdata.set('_GNU_SOURCE', '1')
endif

if cc.has_function_attribute('visibility:default')
  cdata.set('DEFAULT_VISIBILITY', '__attribute__ ((visibility ("default")))')
else
  cdata.set('DEFAULT_VISIBILITY', '')
endif

if cc.has_function_attribute('format')
  cdata.set('PRINTF_FORMAT(a, b)', '__attribute__ ((__format__ (__printf__, a, b)))')
else
  cdata.set('PRINTF_FORMAT(a, b)', '')
endif

is_android_linux = false

if host_machine.system() == 'darwin'
  summary('operating system', 'Darwin/Mac OS X')
  backend = 'darwin'
  platform = 'posix'
elif host_machine.system() == 'haiku'
  summary('operating system', 'Haiku')
  backend = 'haiku'
  platform = 'posix'
elif host_machine.system() == 'linux'
  summary('operating system', 'Linux')
  backend = 'linux'
  platform = 'posix'
elif host_machine.system() == 'android'
  summary('operating system', 'Android Linux')
  backend = 'linux'
  platform = 'posix'
  is_android_linux = true
elif host_machine.system() == 'netbsd'
  summary('operating system', 'NetBSD')
  backend = 'netbsd'
  platform = 'posix'
elif host_machine.system() == 'openbsd'
  summary('operating system', 'OpenBSD')
  backend = 'openbsd'
  platform = 'posix'
elif host_machine.system() == 'sunos'
  summary('operating system', 'SunOS')
  backend = 'sunos'
  platform = 'posix'
elif host_machine.system() == 'cygwin'
  summary('operating system', 'Windows (using Cygwin)')
  backend = 'windows'
  platform = 'windows'
elif host_machine.system() == 'windows'
  summary('operating system', 'Windows')
  backend = 'windows'
  platform = 'windows'
else
  summary('operating system', 'Null')
  warning('The host being compiled for is not supported.')
  warning('The library may compile but will not function in any useful manner.')
  backend = 'null'
  platform = 'posix'
endif

threads = dependency('threads')
libs = [threads]
lib_link_args = []

if platform == 'posix'
  cdata.set('PLATFORM_POSIX', 1)

  if cc.has_header_symbol('poll.h', 'nfds_t')
    cdata.set('HAVE_NFDS_T', 1)
  endif

  if cc.has_function('pipe2')
    cdata.set('HAVE_PIPE2', 1)
  endif

  if not cc.links(
      '_Thread_local int x; int main(void) { x = 42; return 0; }',
      name: 'compiler supports _Thread_local'
    )
    error('compiler with C11 support is required to build libusb')
  endif

  # -pthread checks replaced by dependency('thread') below
elif platform == 'windows'
  cdata.set('PLATFORM_WINDOWS', 1)
else
  error('Unknown platform')
endif

if backend == 'darwin'

  if cc.has_function('pthread_threadid_np', dependencies: threads)
    cdata.set('HAVE_PTHREAD_THREADID_NP', 1)
  endif

  corefoundation = dependency('appleframeworks', modules: 'CoreFoundation')
  iokit = dependency('appleframeworks', modules: 'IOKit')

  libs += [corefoundation, iokit]

elif backend == 'haiku'

  add_languages('cpp')
  cpp = meson.get_compiler('cpp')

  libs += [cpp.find_library('be')]

elif backend == 'linux'
  # clock_gettime() checked later

  if cc.has_function('pthread_setname_np', dependencies: threads)
    cdata.set('HAVE_PTHREAD_SETNAME_NP', 1)
  endif

  libudev = dependency('libudev', required: get_option('udev'))
  if libudev.found()

    libs += [libudev]
    cdata.set('HAVE_LIBUDEV', 1)
    summary('use udev', true, bool_yn: true)

  else

    if cc.has_header('asm/types.h')
      cdata.set('HAVE_ASM_TYPES_H', 1)
    endif

    cc.has_header('linux/netlink.h', required: true)
    cc.has_header('sys/socket.h', required: true)

    summary('use udev', false, bool_yn: true)
  endif

elif backend == 'sunos'

  libs += [cc.find_library('devinfo')]

elif backend == 'windows'

  if cc.has_header_symbol('time.h', 'struct timespec')
    cdata.set('HAVE_STRUCT_TIMESPEC', 1)
  endif

  cdata.set('_WIN32_WINNT', '_WIN32_WINNT_VISTA')

  if cc.has_link_argument('-Wl,--add-stdcall-alias')
    lib_link_args += ['-Wl,--add-stdcall-alias']
  endif

  lib_version_kwargs = {}

endif

if cc.has_header('sys/time.h')
  cdata.set('HAVE_SYS_TIME_H', 1)
endif

# clock_gettime()
if platform == 'posix'

  have_clock_gettime = false

  if backend == 'darwin'
    osx_10_12_or_later = cc.compiles('''
      #include <AvailabilityMacros.h>
      #if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_12
      # error "Target OS X version is too old"
      #endif''',
      name: 'OS X target version is 10.12 or later'
    )

    if osx_10_12_or_later
      have_clock_gettime = cc.has_function('clock_gettime')
    else
      message('clock_gettime() is not available on target OS X version')
    endif

  else

    if cc.has_function('clock_gettime')
      have_clock_gettime = true
    else
      # On glibc older than 2.17, clock_gettime is provided by time.h and -lrt
      librt = cc.find_library('rt', required: false)

      if librt.found() and cc.has_function('clock_gettime', dependencies: librt)
        have_clock_gettime = true
        libs += [librt]
      else
        error('clock_gettime() is required on this platform')
      endif
    endif

  endif

  if have_clock_gettime
    cdata.set('HAVE_CLOCK_GETTIME', 1)

    if not cc.has_header_symbol('time.h', 'CLOCK_MONOTONIC')
      error('C library headers missing definition for CLOCK_MONOTONIC')
    endif

    if cc.has_function('pthread_condattr_setclock', dependencies: threads)
      cdata.set('HAVE_PTHREAD_CONDATTR_SETCLOCK', 1)

      if not cc.has_header_symbol('time.h', 'CLOCK_REALTIME')
        error('C library headers missing definition for CLOCK_REALTIME')
      endif
    endif
  endif
endif

# eventfd support
if backend == 'linux' or backend == 'sunos'
  if get_option('eventfd').disabled()

    summary('use eventfd for signalling', 'no (disabled by user)')

  elif not cc.has_header('sys/eventfd.h')

    if get_option('eventfd').enabled()
      error('eventfd header not available; glibc 2.9+ required')
    endif

    summary('use eventfd for signalling', 'no (header not available)')

  elif not (cc.has_header_symbol('sys/eventfd.h', 'EFD_NONBLOCK') and cc.has_header_symbol('sys/eventfd.h', 'EFD_CLOEXEC'))

    if get_option('eventfd').enabled()
      error('eventfd header not usable; glibc 2.9+ required')
    endif

    summary('use eventfd for signalling', 'no (header not usable)')

  elif not cc.has_function('eventfd')

    if get_option('eventfd').enabled()
      error('eventfd() function not found; glibc 2.9+ required')
    endif

    summary('use eventfd for signalling', 'no (functions not available)')

  else

    cdata.set('HAVE_EVENTFD', 1)
    summary('use eventfd for signalling', true, bool_yn: true)

  endif
endif

# timerfd support
if backend == 'linux' or backend == 'sunos'
  if get_option('timerfd').disabled()

    summary('use timerfd for timing', 'no (disabled by user)')

  elif not cc.has_header('sys/timerfd.h')

    if get_option('timerfd').enabled()
      error('timerfd header not available; glibc 2.9+ required')
    endif

    summary('use timerfd for timing', 'no (header not available)')

  elif not (cc.has_header_symbol('sys/timerfd.h', 'TFD_NONBLOCK') and cc.has_header_symbol('sys/timerfd.h', 'TFD_CLOEXEC'))

    if get_option('timerfd').enabled()
      error('timerfd header not usable; glibc 2.9+ required')
    endif

    summary('use timerfd for timing', 'no (header not usable)')

  elif not cc.has_function('timerfd_create')

    if get_option('timerfd').enabled()
      error('timerfd_create() function not found; glibc 2.9+ required')
    endif

    summary('use timerfd for timing', 'no (functions not available)')

  else

    cdata.set('HAVE_TIMERFD', 1)
    summary('use timerfd for timing', true, bool_yn: true)

  endif
endif

# Message logging
if get_option('log')
  cdata.set('ENABLE_LOGGING', 1)
endif

if get_option('debug-log')
  cdata.set('ENABLE_DEBUG_LOGGING', 1)
endif

if get_option('system-log')
  cdata.set('USE_SYSTEM_LOGGING_FACILITY', 1)

  if backend != 'windows' and not is_android_linux
    if cc.has_header('syslog.h')
      if cc.has_function('syslog')
        cdata.set('HAVE_SYSLOG', 1)
      endif
    endif
  endif
endif

if cc.get_argument_syntax() == 'gcc'

  if backend == 'windows'
    # The -Wcast-function-type warning causes a flurry of warnings when compiling
    # Windows with GCC 8 or later because of dynamically loaded functions
    if cc.has_argument('-Wno-cast-function-type')
      add_project_arguments('-Wno-cast-function-type', language: 'c')
    endif
  endif

  add_project_arguments(
    # -Wall -Wextra are set by warning_level=2
    '-Wshadow',
    '-Wunused',
    '-Wwrite-strings',
    '-Werror=format-security',
    '-Werror=implicit-function-declaration',
    '-Werror=implicit-int',
    '-Werror=init-self',
    '-Werror=missing-prototypes',
    '-Werror=strict-prototypes',
    '-Werror=undef',
    '-Werror=uninitialized',
    language: ['c', 'cpp']
  )

endif

configure_file(output: 'config.h', configuration: cdata)
config_include_dir = include_directories('.')

subdir('libusb')

getopt_dep = []

if cc.get_argument_syntax() == 'msvc'
  subdir('msvc/getopt')
endif

# Examples build
if get_option('examples-build')
  subdir('examples')
endif

# Tests build
if get_option('tests-build')
  subdir('tests')
endif
