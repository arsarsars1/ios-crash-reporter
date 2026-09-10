#ifndef CRASH_SIGNAL_CAPTURE_H
#define CRASH_SIGNAL_CAPTURE_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Install POSIX signal handlers. `pending_path` must remain valid for process lifetime
/// (caller keeps a stable C string, e.g. strdup once).
bool crashreporter_signal_install(const char *pending_path);

/// Read + delete pending signal file. Caller must free() the returned string.
/// Returns NULL if none.
char *crashreporter_signal_consume(const char *pending_path);

#ifdef __cplusplus
}
#endif

#endif
