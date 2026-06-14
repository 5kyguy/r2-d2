# AMD ISP4 Webcam Fix

HP ZBook Ultra G1a (and similar AMD Strix Halo laptops) ship with an OmniVision OV05C10 MIPI CSI-2 sensor wired through the AMD ISP4 pipeline. There is **no mainline Linux driver** for this sensor or the ISP4 V4L2 capture path — the `amd_isp4` platform driver in mainline only creates the I2C device and software node graph, but lacks the sensor driver and V4L2 capture driver needed to produce `/dev/videoX`.

AMD provides both drivers in their out-of-tree repo at [github.com/amd/Linux_ISP_Kernel](https://github.com/amd/Linux_ISP_Kernel) (branch `4.0`), but they require patching to build against mainline kernels.

---

## Hardware detection

```bash
# Confirm sensor I2C device exists
ls /sys/bus/i2c/devices/i2c-ov05c10/

# Confirm ISP capture platform device exists
ls /sys/bus/platform/devices/amd_isp_capture.1.auto/
```

The `amd_isp4` platform driver (built into amdgpu) creates both. What's missing:

| Component | Mainline status |
| --------- | --------------- |
| OV05C10 sensor driver (`ov05c.ko`) | Not in mainline |
| ISP4 V4L2 capture driver (`amd_capture.ko`) | Not in mainline |
| ISP buffer allocation API | Exported by amdgpu (`isp_user_buffer_alloc`, `isp_kernel_buffer_alloc`) |

---

## Build from source

### Clone AMD's ISP kernel repo

```bash
git clone -b 4.0 https://github.com/amd/Linux_ISP_Kernel.git amd-isp-kernel
```

### Sensor driver (`ov05c.ko`)

Sources: `amd-isp-kernel/drivers/media/i2c/ov05c.c`

Two patches are needed:

**1. Fix module license** — AMD ships `MODULE_LICENSE("Proprietary")` which taints the kernel and blocks GPL-only symbols. Change to `"GPL"`:

```c
MODULE_LICENSE("GPL");
```

**2. Add I2C device ID** — The mainline `amd_isp4` driver creates the I2C client with name `ov05c10`, but AMD's driver only matches `ov05`. Add to the `i2c_device_id` table:

```c
{ "ov05c10", 0 },
```

Build with a simple Makefile:

```makefile
obj-m += ov05c.o

all:
  make -C /usr/lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
  make -C /usr/lib/modules/$(shell uname -r)/build M=$(PWD) clean
```

### ISP4 V4L2 capture driver (`amd_capture.ko`)

Sources: `amd-isp-kernel/drivers/media/platform/amd/isp4/` (11 `.c` files + headers)

Multiple patches needed to build against mainline kernels:

**1. Replace amdgpu internal buffer API with exported ISP API**

AMD's driver calls `amdgpu_bo_create_kernel` / `amdgpu_bo_free_kernel` and `amdgpu_bo_create_isp_user` / `amdgpu_bo_free_isp_user` — these are local (unexported) symbols. Replace with the mainline-exported equivalents:

| AMD internal (unexported) | Mainline exported |
| ------------------------- | ----------------- |
| `amdgpu_bo_create_kernel` | `isp_kernel_buffer_alloc` |
| `amdgpu_bo_free_kernel` | `isp_kernel_buffer_free` |
| `amdgpu_bo_create_isp_user` | `isp_user_buffer_alloc` |
| `amdgpu_bo_free_isp_user` | `isp_user_buffer_free` |

In `isp_hwa.c`: replace buffer alloc/free calls and remove `struct amdgpu_device` / `struct amdgpu_bo` types.

In `isp_core.c`: replace user buffer alloc/free, rename `vb2_amdgpu_attachment` to `vb2_isp_attachment`.

**2. Replace amdgpu types with ISP types**

In `isp_common.h`:

```c
#include <drm/amd/isp.h>
```

Change all `amdisp_platform_data` references to `isp_platform_data` (the mainline struct). Remove the local `amdisp_platform_data` definition from `isp_core.h`.

**3. Remove `wait_prepare` / `wait_finish` from `vb2_ops` (kernel 7.0+)**

Kernel 7.0 removed `wait_prepare` and `wait_finish` from `struct vb2_ops`. Remove both the struct initializers and the function definitions:

```c
// REMOVE these entirely:
static void isp4_qops_wait_prepare(struct vb2_queue *vq) { ... }
static void isp4_qops_wait_finish(struct vb2_queue *vq) { ... }

// REMOVE from isp4_qops:
.wait_prepare = isp4_qops_wait_prepare,
.wait_finish = isp4_qops_wait_finish,
```

**4. Add `MODULE_LICENSE("GPL")`** to the main module source.

Build with a Makefile that links all 11 object files:

```makefile
obj-m += amd_capture.o
amd_capture-objs := isp_core.o \
                     isp_hwa.o \
                     isp_debug.o \
                     isp_phy.o \
                     isp_fw_ctrl.o \
                     isp_events.o \
                     isp_module_intf.o \
                     isp_mc_addr_mgr.o \
                     isp_queue.o \
                     isp_utils.o \
                     isp_pwr.o

ccflags-y += -I$(src)

all:
  make -C /usr/lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
  make -C /usr/lib/modules/$(shell uname -r)/build M=$(PWD) clean
```

---

## Install and load

```bash
KVER=$(uname -r)
sudo mkdir -p /usr/lib/modules/$KVER/extra
sudo cp ov05c.ko /usr/lib/modules/$KVER/extra/
sudo cp amd_capture.ko /usr/lib/modules/$KVER/extra/
sudo depmod -a $KVER
sudo modprobe ov05c
sudo modprobe amd_capture
```

Verify:

```bash
ls /dev/video*
```

---

## Persistence across kernel updates

The modules must be rebuilt for each new kernel version. Options:

**DKMS** — Automatically rebuilds on kernel install. Place sources in `/usr/src/amd-isp-4.0/` with a `dkms.conf`.

**Pacman hook** — Use the existing `linux-modules-cleanup.service` pattern or add a hook that triggers a rebuild after `linux` / `linux-headers` updates.

**Migration script** — Add a migration in `migrations/` that checks if the modules are present for the running kernel and rebuilds if not.

---

## Integration into R2-D2

Suggested approach:

1. **`install/config/hardware/amd-isp-webcam.sh`** — Detect AMD ISP4 hardware, clone/patch/build/install the modules if not already present. Add to `install/config/all.sh` after the existing hardware scripts.

2. **Migration** — Add a timestamped migration that runs the same logic for existing installs.

3. **Kernel update hook** — Add a pacman hook or DKMS config so modules are rebuilt when the kernel package updates.

### Hardware detection check

```bash
# Only relevant if both ISP capture device and sensor I2C device exist
if ls /sys/bus/platform/devices/amd_isp_capture.*.auto >/dev/null 2>&1 &&
   ls /sys/bus/i2c/devices/i2c-ov05c10 >/dev/null 2>&1; then
  # Apply the fix
fi
```

---

## Key files in the build

| File | Role |
| ---- | ---- |
| `ov05c.c` | OmniVision OV05C10 I2C sensor driver |
| `isp_core.c` | V4L2 video device, vb2 queue, buffer management |
| `isp_hwa.c` | ISP hardware abstraction, kernel buffer alloc |
| `isp_module_intf.c` | Module interface / firmware commands |
| `isp_fw_ctrl.c` | Firmware control |
| `isp_events.c` | Event handling |
| `isp_phy.c` | CSI-2 PHY management |
| `isp_queue.c` | Buffer queue management |
| `isp_mc_addr_mgr.c` | Media controller address management |
| `isp_utils.c` | Utility functions |
| `isp_pwr.c` | Power management |
| `isp_debug.c` | Debug utilities |
| `isp_core.h` | Core data structures |
| `isp_common.h` | Common types and platform data |

## Tested on

- HP ZBook Ultra G1a 14" (AMD Strix Halo)
- Arch Linux, kernel 7.0.3-arch1-2
- Sensor: OmniVision OV05C10 MIPI CSI-2 (ACPI ID `OMNI5C10`, I2C bus 24)
