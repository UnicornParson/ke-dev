// SPDX-License-Identifier: GPL-2.0
#include <linux/bpf.h>
#include <linux/types.h>

#include <bpf/bpf_helpers.h>

/* raw sys_enter tracepoint */
struct trace_event_raw_sys_enter {
    __u16 common_type;
    __u8  common_flags;
    __u8  common_preempt_count;
    __s32 common_pid;
    __s64 id;
    __s64 args[6];
};

SEC("tracepoint/syscalls/sys_enter_openat")
int sys_enter_openat(struct trace_event_raw_sys_enter *ctx)
{
    int dfd = (int)ctx->args[0];
    const char *filename = (const char *)ctx->args[1];
    int flags = (int)ctx->args[2];
    int mode  = (int)ctx->args[3];

    char fname[256];
    bpf_probe_read_user_str(fname, sizeof(fname), filename);

    return 0;
}

SEC("tracepoint/syscalls/sys_enter_openat2")
int sys_enter_openat2(struct trace_event_raw_sys_enter *ctx)
{
    int dfd = (int)ctx->args[0];
    const char *filename = (const char *)ctx->args[1];
    void *how = (void *)ctx->args[2];

    char fname[256];
    bpf_probe_read_user_str(fname, sizeof(fname), filename);

    return 0;
}

char LICENSE[] SEC("license") = "GPL";
