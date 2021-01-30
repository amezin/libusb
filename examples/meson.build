executable(
  'dpfp',
  sources: 'dpfp.c',
  dependencies: [libusb_dep, getopt_dep]
)

executable(
  'dpfp_threaded',
  sources: 'dpfp.c',
  dependencies: [threads, libusb_dep, getopt_dep],
  c_args: '-DDPFP_THREADED'
)

executable(
  'fxload',
  sources: ['ezusb.c', 'ezusb.h', 'fxload.c'],
  dependencies: [libusb_dep, getopt_dep]
)

executable(
  'hotplugtest',
  sources: 'hotplugtest.c',
  dependencies: [libusb_dep, getopt_dep]
)

executable(
  'listdevs',
  sources: 'listdevs.c',
  dependencies: [libusb_dep, getopt_dep]
)

executable(
  'sam3u_benchmark',
  sources: 'sam3u_benchmark.c',
  dependencies: [libusb_dep, getopt_dep]
)

executable(
  'testlibusb',
  sources: 'testlibusb.c',
  dependencies: [libusb_dep, getopt_dep]
)

executable(
  'xusb',
  sources: 'xusb.c',
  dependencies: [libusb_dep, getopt_dep]
)
