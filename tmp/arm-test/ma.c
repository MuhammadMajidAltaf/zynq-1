int ma(int a, int b, int n)
{
  int tmp = 1;

  for(int i=0; i<n; i++)
  {
    tmp = tmp * a;
    tmp = tmp + b;
    tmp = tmp << a;
    tmp = tmp | b;
    tmp = tmp ^ a;
    tmp = tmp - b;
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
