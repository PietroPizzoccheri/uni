#include <stdio.h>

int main(int argc, char *argv[])
{
  int v1 = 9;
  int v2 = 9;
  int v3 = v1 + v2;
  int v4 = 9;
  int v5 = 7;
  int v6 = v4 * v5;
  int v7 = v3 + v6;
  printf("result = %d\n", v7);

  int v8 = 5;
  int v9 = 1;
  int v10 = 0;
  int v11 = v9 * v10;
  int v12 = v8 + v11;
  printf("result = %d\n", v12);

  printf("bye!\n");
  return 0;
}
