#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <mpi.h>

// Creates an array of random numbers.
int *create_random_array(int num_elements, int max_value) {
  int *arr = (int *) malloc(sizeof(int)*num_elements);
  for (int i=0; i<num_elements; i++) {
    arr[i] = (rand() % max_value);
  }
  return arr;
}

// Process 0 selects a number num.
// All other processes have an array that they filter to only keep the elements
// that are multiples of num.
// Process 0 collects the filtered arrays and print them.
int main(int argc, char** argv) {
  // Maximum value for each element in the arrays
  const int max_val = 100;
  // Number of elements for each processor
  int num_elements_per_proc = 50;
  // Number to filter by
  int num_to_filter_by = 2;
  if (argc > 1) {
    num_elements_per_proc = atoi(argv[1]);
  }

  // Init random number generator
  srand(time(NULL));

  MPI_Init(NULL, NULL);

  int my_rank, world_size; 
  MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);

  // Process 0 selects the num
  int num;
  if (my_rank == 0) {
    num = num_to_filter_by;
  }

  // TODO
  
  MPI_Barrier(MPI_COMM_WORLD);
  MPI_Finalize();
}
