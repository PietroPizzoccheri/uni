#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/**
 * Group number:
 *
 * Group members
 * Member 1
 * Member 2
 * Member 3
 *
 **/

// Set DEBUG 1 if you want car movement to be deterministic
#define DEBUG 0

const int num_segments = 256;
const int num_iterations = 1000;
const int count_every = 10;
const double alpha = 0.5;
const int max_in_per_sec = 10;

// Returns the number of car that enter the first segment at a given iteration.
int create_random_input()
{
  if (DEBUG)
  {
    return 1;
  }
  else
  {
    return rand() % max_in_per_sec;
  }
}

// Returns 1 if a car needs to move to the next segment at a given iteration, 0 otherwise.
int move_next_segment()
{
  if (DEBUG)
  {
    return 1;
  }
  else
  {
    return rand() < alpha * RAND_MAX ? 1 : 0;
  }
}

void initialize_segments(int *segments, int segs_per_proc)
{
  memset(segments, 0, segs_per_proc * sizeof(int));
}

void move_cars(int *segments, int segs_per_proc, int rank, int num_procs)
{
  for (int i = 0; i < segs_per_proc; ++i)
  {
    int cars_moving = 0;
    for (int j = 0; j < segments[i]; j++)
    {
      if (move_next_segment())
        cars_moving++;
    }

    segments[i] -= cars_moving;

    if (i < segs_per_proc - 1)
    {
      segments[i + 1] += cars_moving;
    }
    else if (i == segs_per_proc - 1 && rank < num_procs - 1)
    {
      MPI_Request request;
      MPI_Isend(&cars_moving, 1, MPI_INT, rank + 1, 0, MPI_COMM_WORLD, &request);
    }
  }
}

void receive_cars(int *segments, int rank)
{
  int cars_received_to_first = 0;
  if (rank != 0)
  {
    MPI_Request request;
    MPI_Irecv(&cars_received_to_first, 1, MPI_INT, rank - 1, 0, MPI_COMM_WORLD, &request);
    MPI_Wait(&request, MPI_STATUS_IGNORE);
  }
  else
  {
    cars_received_to_first = create_random_input();
  }
  segments[0] += cars_received_to_first;
}

void compute_and_print_global_sum(int *segments, int segs_per_proc, int rank, int iteration)
{
  int my_sum = 0;
  for (int i = 0; i < segs_per_proc; i++)
    my_sum += segments[i];

  int global_sum = 0;
  MPI_Reduce(&my_sum, &global_sum, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

  if (rank == 0)
  {
    printf("Iteration: %d, sum: %d\n", iteration, global_sum);
  }
}

void simulate_traffic(int *segments, int segs_per_proc, int rank, int num_procs)
{
  for (int it = 0; it < num_iterations; ++it)
  {
    move_cars(segments, segs_per_proc, rank, num_procs);
    receive_cars(segments, rank);

    if (it % count_every == 0)
    {
      compute_and_print_global_sum(segments, segs_per_proc, rank, it);
    }

    MPI_Barrier(MPI_COMM_WORLD);
  }
}

int main(int argc, char **argv)
{
  MPI_Init(NULL, NULL);

  int rank, num_procs;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &num_procs);
  srand(time(NULL) + rank);

  int segs_per_proc = num_segments / num_procs;
  int cars_my_segments[segs_per_proc];

  initialize_segments(cars_my_segments, segs_per_proc);
  simulate_traffic(cars_my_segments, segs_per_proc, rank, num_procs);

  MPI_Finalize();
  return 0;
}