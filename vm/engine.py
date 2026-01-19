import subprocess
import pathlib
import sys
import time

QEMU = "qemu-system-x86_64"

BZIMAGE = pathlib.Path("bzImage")
INITRAMFS = pathlib.Path("initramfs.cpio.gz")
TESTAPP = pathlib.Path("testapp")

if not BZIMAGE.exists():
    sys.exit("bzImage not found")
if not INITRAMFS.exists():
    sys.exit("initramfs not found")
if not TESTAPP.exists():
    sys.exit("testapp not found")

qemu_cmd = [
    QEMU,
    "-kernel", str(BZIMAGE),
    "-initrd", str(INITRAMFS),
    "-m", "512M",
    "-nographic",
    "-append",
    "console=ttyS0 panic=-1",
    "-fsdev",
    f"local,id=fsdev0,path={TESTAPP.parent.resolve()},security_model=none",
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
        send("cp /mnt/host/testapp /opt/testapp")
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
