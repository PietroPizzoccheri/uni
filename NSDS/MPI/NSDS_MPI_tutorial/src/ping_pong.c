#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

// Simple ping pong program to exemplify MPI_Send and MPI_Recs
// Assume only two processes
int main(int argc, char **argv)
{
  const int tot_msgs = 100;

  MPI_Init(NULL, NULL);

  int my_rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
  int other_rank = 1 - my_rank;

  int num_msgs = 0;

  if (my_rank == 0)
  {
    MPI_Ssend(&num_msgs, 1, MPI_INT, other_rank, 0, MPI_COMM_WORLD);
    printf("Rank %d sent message %d to rank %d\n", my_rank, num_msgs, other_rank);
  }

  while (num_msgs < tot_msgs)
  {
    MPI_Recv(&num_msgs, 1, MPI_INT, other_rank, MPI_ANY_TAG, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    printf("Rank %d received message %d from rank %d\n", my_rank, num_msgs, other_rank);
    num_msgs++;
    if (num_msgs <= tot_msgs)
    {
      MPI_Ssend(&num_msgs, 1, MPI_INT, other_rank, 0, MPI_COMM_WORLD);
      printf("Rank %d sent message %d to rank %d\n", my_rank, num_msgs, other_rank);
    }
    else
    {
      break;
    }
  }

  MPI_Finalize();
}
