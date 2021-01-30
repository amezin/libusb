if platform == 'posix'

  platform_src = [
    'os/events_posix.h',
    'os/events_posix.c',
    'os/threads_posix.h',
    'os/threads_posix.c'
  ]

else

  platform_src = [
    'os/events_windows.h',
    'os/events_windows.c',
    'os/threads_windows.h',
    'os/threads_windows.c'
  ]

endif

libusb_libadd = []

if backend == 'darwin'

  os_src = ['os/darwin_usb.h', 'os/darwin_usb.c']

elif backend == 'haiku'

  os_src = []

  libusb_haiku = static_library(
    'libusb_haiku',
    sources: [
      'os/haiku_usb.h',
      'os/haiku_usb_backend.cpp',
      'os/haiku_pollfs.cpp',
      'os/haiku_usb_raw.h',
      'os/haiku_usb_raw.cpp'
    ]
  )

  libusb_libadd += [libusb_haiku]

elif backend == 'linux'

  os_src = ['os/linux_usbfs.h', 'os/linux_usbfs.c']
  if libudev.found()
    os_src += ['os/linux_udev.c']
  else
    os_src += ['os/linux_netlink.c']
  endif

elif backend == 'netbsd'

  os_src = ['os/netbsd_usb.c']

elif backend == 'null'

  os_src = ['os/null_usb.c']

elif backend == 'openbsd'

  os_src = ['os/openbsd_usb.c']

elif backend == 'sunos'

  os_src = ['os/sunos_usb.h', 'os/sunos_usb.c']

elif backend == 'windows'

  os_src = [
    import('windows').compile_resources('libusb-1.0.rc'),
    'os/windows_common.h',
    'os/windows_common.c',
    'os/windows_usbdk.h',
    'os/windows_usbdk.c',
    'os/windows_winusb.h',
    'os/windows_winusb.c'
  ]

endif

libusb = library(
  'libusb-1.0',
  name_prefix: '',
  sources: [
    'libusbi.h',
    'version.h',
    'version_nano.h',
    'core.c',
    'descriptor.c',
    'hotplug.h',
    'hotplug.c',
    'io.c',
    'strerror.c',
    'sync.c'
  ] + platform_src + os_src,
  install: true,
  include_directories: config_include_dir,
  gnu_symbol_visibility: 'hidden',
  dependencies: libs,
  link_with: libusb_libadd,
  vs_module_defs: 'libusb-1.0.def',
  link_args: lib_link_args,
  kwargs: lib_version_kwargs
)

install_headers('libusb.h', subdir: 'libusb-1.0')

pkg = import('pkgconfig')
pkg.generate(
  libusb,
  description: 'C API for USB device access from Linux, Mac OS X, Windows, OpenBSD/NetBSD and Solaris userspace',
  subdirs: ['libusb-1.0']
)

libusb_dep = declare_dependency(
  link_with: libusb,
  include_directories: [config_include_dir, include_directories('.')]
)

if meson.version().version_compare('>=0.54.0')
  meson.override_dependency('libusb-1.0', libusb_dep)
endif
