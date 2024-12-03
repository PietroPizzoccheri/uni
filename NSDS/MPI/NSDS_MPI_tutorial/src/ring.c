#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

// Send a message in a ring starting from process 0 and increment by one at each hop.
// When the message gets back to process 0, print the number of hops.
int main(int argc, char **argv)
{
  MPI_Init(NULL, NULL);

  int my_rank, world_size;
  MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);

  int num_hops = 0;

  while (num_hops < world_size)
  {
    int hop = 0;
    MPI_Recv(&hop, 1, MPI_INT, (my_rank - 1), 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    if (my_rank == 0 && hop == 0)
    {
      MPI_Send(&num_hops, 1, MPI_INT, (my_rank + 1), 0, MPI_COMM_WORLD);
    }
    num_hops = hop + 1;
    if (my_rank == 0)
    {
      printf("Number of hops in process %d = %d\n", my_rank, num_hops);
      break;
    }
    MPI_Send(&num_hops, 1, MPI_INT, (my_rank + 1) % world_size, 0, MPI_COMM_WORLD);
  }

  MPI_Finalize();
}
