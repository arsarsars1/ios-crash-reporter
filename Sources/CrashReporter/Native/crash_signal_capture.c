#include "crash_signal_capture.h"

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static char g_pending_path[512];
static volatile sig_atomic_t g_handling = 0;

static const char *signal_name(int signo) {
    switch (signo) {
        case SIGABRT: return "SIGABRT";
        case SIGBUS: return "SIGBUS";
        case SIGFPE: return "SIGFPE";
        case SIGILL: return "SIGILL";
        case SIGSEGV: return "SIGSEGV";
        case SIGTRAP: return "SIGTRAP";
        default: return "UNKNOWN";
    }
}

static void write_all(int fd, const char *buf, size_t len) {
    while (len > 0) {
        ssize_t n = write(fd, buf, len);
        if (n <= 0) {
            if (n < 0 && errno == EINTR) continue;
            return;
        }
        buf += (size_t)n;
        len -= (size_t)n;
    }
}

static void write_int(int fd, int value) {
    char tmp[16];
    int i = 0;
    int v = value;
    if (v == 0) {
        tmp[i++] = '0';
    } else {
        if (v < 0) {
            tmp[i++] = '-';
            v = -v;
        }
        char digits[12];
        int d = 0;
        while (v > 0 && d < 12) {
            digits[d++] = (char)('0' + (v % 10));
            v /= 10;
        }
        while (d > 0) {
            tmp[i++] = digits[--d];
        }
    }
    write_all(fd, tmp, (size_t)i);
}

static void crash_signal_handler(int signo, siginfo_t *info, void *context) {
    (void)context;
    if (g_handling) {
        _exit(128 + signo);
    }
    g_handling = 1;

    if (g_pending_path[0] == '\0') {
        _exit(128 + signo);
    }

    int fd = open(g_pending_path, O_WRONLY | O_CREAT | O_TRUNC, 0600);
    if (fd >= 0) {
        const char *hdr = "CRASHREPORTER_SIGNAL_V1\n";
        write_all(fd, hdr, strlen(hdr));
        write_int(fd, signo);
        write_all(fd, "\n", 1);
        const char *name = signal_name(signo);
        write_all(fd, name, strlen(name));
        write_all(fd, "\n", 1);
        int code = info ? info->si_code : 0;
        write_int(fd, code);
        write_all(fd, "\n", 1);
        close(fd);
    }

    signal(signo, SIG_DFL);
    raise(signo);
}

static int install_one(int signo) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_sigaction = crash_signal_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_SIGINFO;
    return sigaction(signo, &sa, NULL);
}

bool crashreporter_signal_install(const char *pending_path) {
    if (pending_path == NULL) return false;
    size_t n = strlen(pending_path);
    if (n == 0 || n >= sizeof(g_pending_path)) return false;
    memcpy(g_pending_path, pending_path, n + 1);

    const int signals[] = {SIGABRT, SIGBUS, SIGFPE, SIGILL, SIGSEGV, SIGTRAP};
    for (size_t i = 0; i < sizeof(signals) / sizeof(signals[0]); i++) {
        install_one(signals[i]);
    }
    return true;
}

char *crashreporter_signal_consume(const char *pending_path) {
    if (pending_path == NULL) return NULL;
    int fd = open(pending_path, O_RDONLY);
    if (fd < 0) return NULL;

    char buf[256];
    ssize_t n = read(fd, buf, sizeof(buf) - 1);
    close(fd);
    unlink(pending_path);
    if (n <= 0) return NULL;
    buf[n] = '\0';
    return strdup(buf);
}
