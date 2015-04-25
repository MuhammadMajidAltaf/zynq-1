int __attribute__ ((noinline)) loopA(int b)
{
  int a = 0;
  for(int i=0; i<b; i++)
  {
    a |= 1 << i;
  }
  return a;
}

int main(int argc, char **argv)
{
  volatile int x = 5;
  return loopA(x);
}
