getopt = static_library(
  'getopt',
  sources: ['getopt.h', 'getopt.c', 'getopt1.c'],
  c_args: ['/DHAVE_STRING_H'],
  build_by_default: false
)

getopt_dep = declare_dependency(
  link_with: getopt,
  include_directories: include_directories('.')
)
