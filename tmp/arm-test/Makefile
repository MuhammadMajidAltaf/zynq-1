CC=arm-linux-gnueabihf-gcc
OD=arm-linux-gnueabihf-objdump

INCPATH=/tools/zynq/zynq-xdma/lib/
LIBPATH=/tools/zynq/zynq-xdma/lib/
LIBS=-lxdma -lrt

CFLAGS=-march=armv7-a -mtune=cortex-a9 -mfpu=neon -marm -std=gnu99 -O3 -I${INCPATH} -L${LIBPATH}

all: loop.o ma matrix.o ma.dis

clean:
	rm *.o *.dis

loop.o: loop.c
	${CC} ${CFLAGS} -c -o loop.o loop.c

ma.dis: ma.o
	${OD} -d ma.o > ma.dis

ma.o: ma.c
	${CC} ${CFLAGS} -c -o ma.o ma.c

ma: ma.o
	${CC} ${CFLAGS} -o ma ma.o ${LIBS}

matrix.o: matrix.c
	${CC} ${CFLAGS} -c -o matrix.o matrix.c
