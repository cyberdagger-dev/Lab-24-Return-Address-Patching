ProjectName		= RetAddrPatch

CCX64			= c:\users\Administrator\Desktop\Tools\mingw64\bin\x86_64-w64-mingw32-gcc.exe
NASM            = c:\users\Administrator\Desktop\Tools\mingw64\bin\nasm.exe

all: x64

x64:
	$(NASM) -f win64 asm.asm -o asm.o
	$(CCX64) *.c asm.o -o $(ProjectName).exe