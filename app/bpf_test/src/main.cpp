#include <csignal>
#include <cstdio>
#include <unistd.h>

extern "C" {
#include "bpf_trap.skel.h"
}

static volatile bool running = true;

static void handle_signal(int)
{
    running = false;
}

int main(int argc, char **argv)
{
    struct bpf_trap_bpf *skel;
    int err;

    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    skel = bpf_trap_bpf__open();
    if (!skel) {
        fprintf(stderr, "failed to open BPF skeleton\n");
        return 1;
    }

    err = bpf_trap_bpf__load(skel);
    if (err) {
        fprintf(stderr, "failed to load BPF skeleton: %d\n", err);
        goto cleanup;
    }

    err = bpf_trap_bpf__attach(skel);
    if (err) {
        fprintf(stderr, "failed to attach BPF programs: %d\n", err);
        goto cleanup;
    }

    while (running)
        pause();

cleanup:
    bpf_trap_bpf__destroy(skel);
    return err ? 1 : 0;
}
