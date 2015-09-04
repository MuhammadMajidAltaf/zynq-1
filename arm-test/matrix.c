#define LEN_4 4
#define LEN_64 64

int veca[LEN_64];

int mata[LEN_64][LEN_64];
int matb[LEN_64][LEN_64];

int vecop(int* vec, int x)
{
  for(int i=0; i<LEN_64; i++)
    vec[i] = vec[i] * x;
}
