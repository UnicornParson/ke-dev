# linux kernel lab

---

# Directories

kernel/
Linux kernel source trees.

kernel/stable/
Primary kernel source tree used for experiments.

cfg/
Kernel configuration variants (.config files).

img/
QEMU-related images (initramfs, disk images, auxiliary artifacts).

app/
User-space test application projects.

bin/
Pipeline artifacts produced by build scripts and consumed by run.sh.

out/
Final test results collected from QEMU runs.

# Scripts

make_ke.sh
Builds the Linux kernel using sources from kernel/ and configs from cfg/.

make_vm.sh
Prepares QEMU runtime images without building the kernel or applications.

make_app.sh
Builds user-space test applications from app/.

run.sh
Runs QEMU, executes the test, and writes results to out/ using only bin/.

clean.sh
Removes all contents of bin/ before a new experiment session.