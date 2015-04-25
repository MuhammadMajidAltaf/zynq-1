#include <stdio.h>

#define GETREGS(regs) \
  asm("mov %0, %%r0" : "=r" (regs[0]));\
  asm("mov %0, %%r1" : "=r" (regs[1]));\
  asm("mov %0, %%r2" : "=r" (regs[2]));\
  asm("mov %0, %%r3" : "=r" (regs[3]));\
  asm("mov %0, %%r4" : "=r" (regs[4]));\
  asm("mov %0, %%r5" : "=r" (regs[5]));\
  asm("mov %0, %%r6" : "=r" (regs[6]));\
  asm("mov %0, %%r7" : "=r" (regs[7]));\
  asm("mov %0, %%r8" : "=r" (regs[8]));\
  asm("mov %0, %%r9" : "=r" (regs[1]));\
  asm("mov %0, %%r10" : "=r" (regs[10]));\
  asm("mov %0, %%r11" : "=r" (regs[11]));\
  asm("mov %0, %%r12" : "=r" (regs[12]));\
  asm("mov %0, %%r13" : "=r" (regs[13]))

#define PRINTREGS(regs) \
  offload(regs[0], regs[1], regs[2], regs[3], regs[4], regs[5], regs[6], regs[7], regs[8], regs[9], regs[10], regs[11], regs[12], regs[13])

extern int offload(int vr0, int vr1, int vr2, int vr3, int vr4, int vr5, int vr6, int vr7, int vr8, int vr9, int vr10, int vr11, int vr12, int vr13);

unsigned long regs[14];

int getvalues(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j, int k, int l, int m)
{
  int n;

  n = a + b + c + d + e + f + g + h + i + j + k + l + m;

  GETREGS(regs);
  PRINTREGS(regs);

  return n;
}

int main()
{
  getvalues(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);
  GETREGS(regs);
  PRINTREGS(regs);
}
