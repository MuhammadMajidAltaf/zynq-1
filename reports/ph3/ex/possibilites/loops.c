int unrolled(int a, int b)
{
  int sum;
  for (int i=0; i<10; i++)
    sum = sum * b + a;
  return sum;
}

int huge_unrolled(int a, int b)
{

  int sum;
  for (int i=0; i<5000; i++)
    sum = sum * b + a;
  return sum;
}

int rolled(int a, int b, int num)
{
  int sum;
  for (int i=0; i<num; i++)
    sum = sum * b + a;
  return sum;
}

int partial_unrolled(int a, int b, int num)
{
  int sum;
  for (int i=0; i<(num>>2); i++)
    for (int j=0; j<4; j++)
      sum = sum * b +a;
  return sum;
}
