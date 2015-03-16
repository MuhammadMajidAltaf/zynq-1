#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "libxdma.h"
#define MAGIC 0x0ffa0ffb
#define LENGTH 15

//----------------------
//Interesting functions?
//----------------------

int ma(int a, int b, int n)
{
  int tmp = 1;

  for(int i=0; i<n; i++)
  {
    tmp = tmp * a;
    tmp = tmp + b;
 //   tmp = tmp << a;
 //   tmp = tmp | b;
 //   tmp = tmp ^ a;
 //   tmp = tmp - b;
  }

  return tmp;
}

int ma_10(int a, int b)
{
  return ma(a, b, 10);
}

int ma_20(int a, int b)
{
  return ma(a, b, 20);
}

int ma_50(int a, int b)
{
  return ma(a, b, 50);
}

//----------------------
//Boring part
//----------------------

int main(int argc, char** argv)
{
  int a, b, r1, r2;
  struct timespec start, end;
  uint32_t *src, *dst;

  if(argc < 3)
  {
    fprintf(stderr, "not enough arguments.\n [a] [b]\n");
    return -1;
  }

  a = atoi(argv[1]);
  b = atoi(argv[2]);

  printf("using a: %d, b: %d\n", a, b);

  printf("running on cpu:\n");
  clock_gettime(CLOCK_REALTIME, &start);
  r1 = ma_10(a, b);
  clock_gettime(CLOCK_REALTIME, &end);
  printf("took %lus %luns\n", end.tv_sec-start.tv_sec, end.tv_nsec-start.tv_nsec);


  printf("running on logic:\n");
  if(xdma_init() < 0)
    return -2;
  src = xdma_alloc(LENGTH, sizeof(uint32_t));
  dst = xdma_alloc(LENGTH, sizeof(uint32_t));
  //KNOW: r0=a, r1=b
  src[0] = MAGIC;
  src[1] = a; //r0
  src[2] = b; //r1

  clock_gettime(CLOCK_REALTIME, &start);

  if(0 < xdma_num_of_devices())
  {
    xdma_perform_transaction(0, XDMA_WAIT_NONE, src, LENGTH, NULL, 0);

    xdma_perform_transaction(0, XDMA_WAIT_NONE, NULL, 0, dst, LENGTH);
  }

  r2 = dst[1]; //r0

  clock_gettime(CLOCK_REALTIME, &end);
  xdma_exit();
  printf("took %lus %luns\n", end.tv_sec-start.tv_sec, end.tv_nsec-start.tv_nsec);

  if(r1 != r2)
    fprintf(stderr, "results differ between cpu and logic: %d(%lx) =/= %d(%lx)\n", r1, r1, r2, r2);

  return 0;
}

