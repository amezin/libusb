stress = executable(
  'stress',
  sources: ['stress.c', 'libusb_testlib.h', 'testlib.c'],
  dependencies: [libusb_dep, getopt_dep]
)

test('init_and_exit', stress, args: ['-v', 'init_and_exit'], timeout: 120)
test('get_device_list', stress, args: ['-v', 'get_device_list'])
test('many_device_lists', stress, args: ['-v', 'many_device_lists'])
test('default_context_change', stress, args: ['-v', 'default_context_change'])
