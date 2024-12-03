#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <mpi.h>

// Creates an array of random numbers.
int *create_random_array(int num_elements, int max_value)
{
  int *arr = (int *)malloc(sizeof(int) * num_elements);
  for (int i = 0; i < num_elements; i++)
  {
    arr[i] = (rand() % max_value);
  }
  return arr;
}

// gets an array of ints and a number and returns an array containing only the
// elements that are multiples of the number
// without knowing how many elements will be in the filtered array
void filter_array_by_multiples_of_n(int *array, int array_size, int n)
{
  for (int i = 0; i < array_size; i++)
  {
    if (array[i] % n != 0)
    {
      array[i] = -1;
    }
  }
}

// Process 0 selects a number num.
// All other processes have an array that they filter to only keep the elements
// that are multiples of num.
// Process 0 collects the filtered arrays and print them.
int main(int argc, char **argv)
{
  // Maximum value for each element in the arrays
  const int max_val = 100;
  // Number of elements for each processor
  int num_elements_per_proc = 50;
  // Number to filter by
  int num_to_filter_by = 2;
  if (argc > 1)
  {
    num_elements_per_proc = atoi(argv[1]);
  }

  MPI_Init(NULL, NULL);

  int my_rank, world_size;
  MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);

  // Seed the random number generator with a different value for each process
  srand(time(NULL) + my_rank);

  // Process 0 selects the num
  int num;
  if (my_rank == 0)
  {
    num = num_to_filter_by;
  }

  int *arr = create_random_array(num_elements_per_proc, max_val);

  MPI_Bcast(&num, 1, MPI_INT, 0, MPI_COMM_WORLD);

  filter_array_by_multiples_of_n(arr, num_elements_per_proc, num);

  MPI_Send(arr, num_elements_per_proc, MPI_INT, 0, 0, MPI_COMM_WORLD);

  if (my_rank == 0)
  {
    int *filtered_arrs = (int *)malloc(sizeof(int) * num_elements_per_proc * world_size);
    for (int i = 0; i < world_size; i++)
    {
      MPI_Recv(filtered_arrs + i * num_elements_per_proc, num_elements_per_proc, MPI_INT, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    for (int i = 0; i < world_size; i++)
    {
      printf("Filtered array from process %d:\n", i);
      for (int j = 0; j < num_elements_per_proc; j++)
      {
        if(filtered_arrs[i * num_elements_per_proc + j] > 0) {
          printf("%d ", filtered_arrs[i * num_elements_per_proc + j]);
        }
      }
      printf("\n");
    }

    free(filtered_arrs);
  }

  free(arr);

  MPI_Barrier(MPI_COMM_WORLD);
  MPI_Finalize();
  return 0;
}