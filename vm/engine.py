#!/usr/bin/env python3

import argparse
import pathlib
import subprocess
import sys


def parse_args():
    p = argparse.ArgumentParser(
        description="Run Linux kernel test in QEMU BusyBox environment"
    )
    p.add_argument(
        "--bzimage",
        required=True,
        type=pathlib.Path,
        help="Path to bzImage"
    )
    p.add_argument(
        "--initramfs",
        required=True,
        type=pathlib.Path,
        help="Path to initramfs.cpio.gz"
    )
    p.add_argument(
        "--testapp",
        required=True,
        type=pathlib.Path,
        help="Path to test application binary"
    )
    p.add_argument(
        "--qemu",
        default="qemu-system-x86_64",
        help="QEMU binary (default: qemu-system-x86_64)"
    )
    return p.parse_args()


def main():
    args = parse_args()

    for path, name in [
        (args.bzimage, "bzImage"),
        (args.initramfs, "initramfs"),
        (args.testapp, "testapp"),
    ]:
        if not path.exists():
            sys.exit(f"{name} not found: {path}")
        if not path.is_file():
            sys.exit(f"{name} is not a file: {path}")

    qemu_cmd = [
        args.qemu,
        "-kernel", str(args.bzimage),
        "-initrd", str(args.initramfs),
        "-m", "512M",
        "-nographic",
        "-append", "console=ttyS0 panic=-1",
        "-fsdev",
        f"local,id=fsdev0,path={args.testapp.parent.resolve()},security_model=none",
        "-device",
        "virtio-9p-pci,fsdev=fsdev0,mount_tag=hostshare",
    ]

    proc = subprocess.Popen(
        qemu_cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    def send(cmd):
        proc.stdin.write(cmd + "\n")
        proc.stdin.flush()

    test_finished = False

    for line in proc.stdout:
        print(line, end="")

        if "INIT READY" in line:
            send(f"cp /mnt/host/{args.testapp.name} /opt/testapp")
            send("chmod +x /opt/testapp")
            send("/opt/testapp")
            send("echo TESTAPP_EXIT_CODE=$?")
            send("poweroff")

        if "TESTAPP_EXIT_CODE=" in line:
            test_finished = True

    proc.wait()

    if proc.returncode != 0:
        sys.exit(f"QEMU exited with code {proc.returncode}")

    if not test_finished:
        sys.exit("Test did not finish correctly")

    print("Test finished successfully")


if __name__ == "__main__":
    main()
