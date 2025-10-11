# Notes

```shell
qemu-system-aarch64 -machine virt -nographic -cpu cortex-a57 -bios u-boot.bin
qemu-system-riscv64 -nographic -machine virt -bios spl/u-boot-spl.bin -device loader,file=u-boot.itb,addr=0x80200000
```
