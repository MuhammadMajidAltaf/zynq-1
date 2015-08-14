CC=arm-cortex_a9-linux-gnueabihf-gcc
OBJDUMP=arm-cortex_a9-linux-gnueabihf-objdump
CFLAGS=-march=armv7-a -mfpu=neon -marm -std=gnu99 -O3 -ftree-vectorize -mvectorize-with-neon-quad -mfloat-abi=hard -ffast-math

SRCS=$(wildcard *.c)
DISS=$(SRCS:.c=.dis)


all: $(DISS)

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

%.dis : %.o
	$(OBJDUMP) -d $< > $@

clean: $(wildcard *.o) $(wildcard *.dis)
	rm -f *.dis *.o
