# SD-Kernel
SDos Kernel


## Environment
 - Debian   11 (Bullseye)    
 - NASM
 - GCC      10.2.1 (with multilib)
 - QEMU     5.2.0


## Run (with QEMU)
```
qemu-system-x86_64 -L . -m 64 -fda <OS Image> -M pc 
```