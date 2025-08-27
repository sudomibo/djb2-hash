SHELL=/usr/bin/bash
AS=nasm
LD=ld
LN=ln -s
RM=rm -f
ASFLAGS=-felf32
LDFLAGS=-m elf_i386

X=djb2
XA=djb2.i386

$(X): $(XA)
	$(LN) $(XA) $(X)

$(XA): $(XA).o
	$(LD) $(LDFLAGS) $(XA).o -o $(XA)

$(XA).o: $(XA).asm
	$(AS) $(ASFLAGS) $(XA).asm

test: $(X)
	echo -n "timeGetTime" | ./$(X) | diff -q - <(echo "1e196283")

clean:
	$(RM) $(XA).o $(XA) $(X)
