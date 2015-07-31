int c[4];

int small_add(int a, int b, int c, int d)
{
  return a + b + c + d;
};

int gt(int a,int b)
{
  return a > b ? a : b;
}

int movn(int a, int b)
{
  return b != 0 ? a : 0;
}

int mvn(int a, int b)
{
  return ~b;
}

int shift(int a, int b)
{
  return a >> (b << a);
}

int mul(int a, int b)
{
  return a * b;
}

int mla(int a, int b, int c)
{
  return a * b + c;
}

int mls(int a, int b, int c)
{
  return c - a * b;
}

int mulrsb(int a, int b, int c)
{
  return a * b - c;
}

int andnot(int a, int b)
{
  return a & ~b;
}

int main(int argc, char** argv)
{
  return 0;
}
