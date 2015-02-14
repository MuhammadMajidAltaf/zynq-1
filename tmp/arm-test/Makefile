CC=arm-linux-gnueabihf-gcc
OD=arm-linux-gnueabihf-objdump
CFLAGS=-march=armv7-a -mtune=cortex-a9 -mfpu=neon -marm -std=c11 -O3

all: loop.o ma.o matrix.o ma.dis

clean:
	rm *.o *.dis

loop.o: loop.c
	${CC} ${CFLAGS} -c -o loop.o loop.c

ma.dis: ma.o
	${OD} -d ma.o > ma.dis

ma.o: ma.c
	${CC} ${CFLAGS} -c -o ma.o ma.c

matrix.o: matrix.c
	${CC} ${CFLAGS} -c -o matrix.o matrix.c
