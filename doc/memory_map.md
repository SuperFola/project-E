# General memory map

Start | End | Size | Type | Description
------+-----+------+------+------------
0x0000 | 0x03ff | 1 KiB | RAM | unusable, Real Move IVT (Interrupt Vector Table)
0x0400 | 0x04ff | 256 B | RAM | unusable, BDA (BIOS data area)
0x0500 | 0x7bff | 30'463 B | RAM | free for use
0x7c00 | 0x7dff | 512 B | RAM | unusable, OS Boot Sector
0x7e00 | 0x7ffff | 480.5 KiB | RAM | free for use
0x80000 | 0x9fbff | 120 KiB | RAM (**if it exists**) | free for use
0x9fc00 | 0x9ffff | 1 KiB | RAM | unusable, EBDA (Extended BIOS data area)
0xa0000 | 0xfffff | 384 KiB | various | unusable, video memory or ROM area

# Project-E memory map
Start | End | Size | Type | Description
------+-----+------+------+------------
0x1000 | 0x4fff | 16 KiB | RAM | Kernel
0x7c00 | 0x7dff | 512 B | RAM | OS Boot Sector
0x7e00 | 0x7ffff | 480.5 KiB | User space (Applications and files will be loaded here)
