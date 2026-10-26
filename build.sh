#!/bin/bash

nasm -f elf64 -o loader.o loader.asm
ld -nostdlib --nmagic -o loader loader.o
strip --strip-section-headers loader
