CC=arm-cortex_a9-linux-gnueabihf-gcc
OD=arm-cortex_a9-linux-gnueabihf-objdump

INCPATH=/tools/zynq/zynq-xdma/lib/
LIBPATH=/tools/zynq/zynq-xdma/lib/
LIBS=-lxdma -lrt

CFLAGS=-march=armv7-a -mtune=cortex-a9 -mfpu=neon -marm -std=gnu99 -O3 -I${INCPATH} -L${LIBPATH}

all: ma matrix.o ma.dis

clean:
	rm *.o *.dis

ma: ma.o
	${CC} ${CFLAGS} -o ma ma.o ${LIBS}

%.dis: %.o
	${OD} -d $< > $@

%.o: %.c
	${CC} ${CFLAGS} -c -o $@ $<

read-reg: read-reg.o offload.o
	${CC} ${CFLAGS} -o read-reg read-reg.o offload.o ${LIBS}
