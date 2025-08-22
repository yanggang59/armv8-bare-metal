# Test commands.
#	make run
#	Ctrl-A X (Exit)


IMAGE := kernel.elf
TOOLCHAIN_PATH=/home/thomas/workspace/xpack-aarch64-none-elf-gcc-12.2.1-1.2/bin/
CROSS = ${TOOLCHAIN_PATH}aarch64-none-elf
CC = ${CROSS}-gcc
AS = ${CROSS}-as
LD = ${CROSS}-ld
OBJDUMP = ${CROSS}-objdump
CFLAGS =  -mcpu=cortex-a57 -Wall -Wextra -g
#	-mcpu=name
#		Specify the name of the target processor
#	-Wall
#		Turns on all optional warnings which are desirable for normal code
#	-Wextra
#		This enables some extra warning flags that are not enabled by -Wall
#	-g  Produce debugging information in the operating system's native format.
#		 GDB can work with this debugging information.

ASM_FLAGS = -mcpu=cortex-a57 -g

OBJS = boot.o vector.o exception.o kernel.o gic_v3.o uart.o psw.o aarch64.o timer.o
# OBJS = boot.o gic-pl390.o kernel.o


all: $(IMAGE)

${IMAGE}: ${OBJS}
	${LD} -T linker.ld $^ -o $@
	${OBJDUMP} -D kernel.elf > kernel.list

#boot.o: boot.S
%.o: %.S
	# ${AS} ${ASM_FLAGS} -c $< -o $@
	$(CC) ${CFLAGS} -c $< -o $@			# for include header file in assembly

%.o : %.c
	$(CC) ${CFLAGS} -c $<

run:
	$(MAKE) kernel.elf
	# qemu-system-aarch64 -machine virt -cpu cortex-a57 -m 128 -serial stdio -nographic -nodefaults -kernel kernel.elf
	# qemu-system-aarch64 -machine virt,gic_version=3 -cpu cortex-a57 -nographic -kernel kernel.elf
	qemu-system-aarch64 -machine virt -cpu cortex-a57 -nographic -kernel kernel.elf

gen_tags:
	./gen_tags.sh

clean_tags:
	rm -rf tags cscope*

clean:
	rm -f *.o *.elf *.list

.PHONY: run gen_tags clean_tags clean
