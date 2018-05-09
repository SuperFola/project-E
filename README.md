# Project E

Project E is a small Operating System (if we can say so) composed of a basic bootloader and of a simple kernel, capable of loading a given application an executing it.

It was developped and tested under Lubuntu 18.04, on a x86_64 machine.

## Building

```bash
~$ cd project-E-master
~/project-E-master$ sudo ./configure.sh  # to install the dependencies
~/project-E-master$ ./build.sh kerasm qemu  # we are telling the build script to compile the ASM kernel and to boot qemu with
                                            # the generated .fda file
```

## Bug report

Feel free to open an issue if you encounter any kind of problem with Project E :smiley:
