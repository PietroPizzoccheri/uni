#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

// Simple ping pong program to exemplify MPI_Send and MPI_Recs
// Assume only two processes
int main(int argc, char** argv) {
  const int tot_msgs = 100;
  
  MPI_Init(NULL, NULL);

  int my_rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

  int num_msgs = 0;

  // TODO
  
  MPI_Finalize();
}
