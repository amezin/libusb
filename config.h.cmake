#ifdef _MSC_VER
#include "msvc/config.h"
#else

#define DEFAULT_VISIBILITY __attribute__ ((visibility ("default")))

#define PRINTF_FORMAT(a, b) __attribute__ ((__format__ (__printf__, a, b)))

#cmakedefine PLATFORM_POSIX @PLATFORM_POSIX@

#cmakedefine PLATFORM_WINDOWS @PLATFORM_WINDOWS@

#cmakedefine HAVE_NFDS_T @HAVE_NFDS_T@

#cmakedefine HAVE_PIPE2 @HAVE_PIPE2@

#cmakedefine HAVE_PTHREAD_THREADID_NP @HAVE_PTHREAD_THREADID_NP@

#cmakedefine HAVE_CLOCK_GETTIME @HAVE_CLOCK_GETTIME@

#cmakedefine HAVE_PTHREAD_SETNAME_NP @HAVE_PTHREAD_SETNAME_NP@

#cmakedefine HAVE_STRUCT_TIMESPEC @HAVE_STRUCT_TIMESPEC@

#endif
