#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <mpi.h>
#include <math.h>

/*
 * Group number: XX
 *
 * Group members
 *  - Student 1
 *  - Student 2
 *  - Student 3
 */

const float min = 0;
const float max = 1000;
const float len = max - min;
const int num_ants = 8 * 1000 * 1000;
const int num_food_sources = 10;
const int num_iterations = 50;

float random_position()
{
  return (float)rand() / (float)(RAND_MAX / (max - min)) + min;
}

void init_food_sources(float *food_sources_positions)
{
  for (int i = 0; i < num_food_sources; i++)
  {
    food_sources_positions[i] = random_position();
  }
}

void init_ants(float *ants)
{
  for (int i = 0; i < num_ants; i++)
  {
    ants[i] = random_position();
  }
}

float nearest_food(float *food_positions, float ant_position)
{
  float min_distance = len;
  float nearest = 0;
  for (int i = 0; i < num_food_sources; i++)
  {
    float distance = fabs(ant_position - food_positions[i]);
    if (distance < min_distance)
    {
      min_distance = distance;
      nearest = food_positions[i];
    }
  }
  return nearest;
}

float compute_new_position(float ant_position, float nearest_food, float center)
{
  float new_position = 0;
  new_position += (ant_position - center) * 0.012;
  new_position += (ant_position - nearest_food) * 0.01;
  return new_position;
}

float compute_center(float *my_ants_positions, int num_my_ants)
{
  float my_sum = 0;
  for (int i = 0; i < num_my_ants; i++)
  {
    my_sum += my_ants_positions[i];
  }
  float global_sum = 0;
  MPI_Allreduce(&my_sum, &global_sum, 1, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);
  return global_sum / num_ants;
}

int main()
{
  MPI_Init(NULL, NULL);

  int rank;
  int num_procs;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

  srand(rank);

  // Allocate space in each process for food sources and ants
  float *food_sources_positions = NULL;
  float *all_ants = NULL;
  float *my_ants_positions = NULL;
  int num_my_ants = num_ants / num_procs;

  food_sources_positions = (float *)malloc(num_food_sources * sizeof(float));
  my_ants_positions = (float *)malloc(num_my_ants * sizeof(float));

  // Process 0 initializes food sources and ants
  if (rank == 0)
  {
    all_ants = (float *)malloc(num_ants * sizeof(float));
    init_food_sources(food_sources_positions);
    init_ants(all_ants);
  }

  MPI_Bcast(food_sources_positions, num_food_sources, MPI_FLOAT, 0, MPI_COMM_WORLD);
  MPI_Scatter(all_ants, num_my_ants, MPI_FLOAT, my_ants_positions, num_my_ants, MPI_FLOAT, 0, MPI_COMM_WORLD);

  if (rank == 0)
  {
    free(all_ants);
  }

  printf("Process %d has %d ants\n", rank, num_my_ants);
  for (int i = 0; i < num_food_sources; i++)
  {
    printf("Process %d has food source %d at %f\n", rank, i, food_sources_positions[i]);
  }

  // Iterative simulation
  float center = 0;
  float nearest = 0;
  for (int iter = 0; iter < num_iterations; iter++)
  {

    center = compute_center(my_ants_positions, num_my_ants);

    for (int i = 0; i < num_my_ants; i++)
    {
      nearest = 0;
      nearest = nearest_food(food_sources_positions, my_ants_positions[i]);
      my_ants_positions[i] += compute_new_position(my_ants_positions[i], nearest, center);
    }

    if (rank == 0)
    {
      printf("Iteration: %d - Average position: %f\n", iter, center);
    }
  }

  // Free memory
  free(food_sources_positions);
  free(my_ants_positions);

  MPI_Finalize();
  return 0;
}
