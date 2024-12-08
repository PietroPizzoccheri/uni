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
const int num_iterations = 500;

float random_position() {
  return (float) rand() / (float)(RAND_MAX/(max-min)) + min;
}

/*
 * Process 0 invokes this function to initialize food sources.
 */
void init_food_sources(float* food_sources) {
  for (int i=0; i<num_food_sources; i++) {
    food_sources[i] = random_position();
  }
}

/*
 * Process 0 invokes this function to initialize the position of ants.
 */
void init_ants(float* ants) {
  for (int i=0; i<num_ants; i++) {
    ants[i] = random_position();
  }
}

float nearest_food_source(float* food_sources, float ant) {
  float current_min = len;
  float res = food_sources[0];
  for (int i=0; i<num_food_sources; i++) {
    float dist = fabs(ant - food_sources[i]);
    if (dist < current_min) {
      current_min = dist;
      res = food_sources[i];
    }
  }
  return res;
}

float compute_center(float* my_ants, int num_my_ants) {
  float my_sum = 0;
  for (int i=0; i<num_my_ants; i++) {
    my_sum += my_ants[i];
  }
  float global_sum = 0;
  MPI_Allreduce(&my_sum, &global_sum, 1, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);
  return global_sum / num_ants;
}

float compute_force(float ant, float point, float mul) {
  int direction = ant > point ? -1 : 1;
  float force = fabs(ant - point);
  return mul * force * direction;
}

int main() {
  MPI_Init(NULL, NULL);
    
  int rank;
  int num_procs;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

  srand(rank);

  float* food_sources = NULL; 
  float* all_ants = NULL;

  // Allocate space in each process for food sources and ants
  food_sources = (float*) malloc(num_food_sources*sizeof(float));
  int num_my_ants = num_ants/num_procs;
  float *my_ants = (float*) malloc(num_my_ants*sizeof(float));

  // Process 0 initializes food sources and ants
  if (rank == 0) {
    init_food_sources(food_sources);
    all_ants = (float*) malloc(num_ants*sizeof(float));
    init_ants(all_ants);
  }

  // Process 0 broadcasts food sources
  MPI_Bcast(food_sources, num_food_sources, MPI_FLOAT, 0, MPI_COMM_WORLD);

  // Process 0 distributes ants and deletes the global array
  MPI_Scatter(all_ants, num_my_ants, MPI_FLOAT, my_ants, num_my_ants, MPI_FLOAT, 0, MPI_COMM_WORLD); 
  if (rank == 0) {
    free(all_ants);
  }

  for (int iter=0; iter<num_iterations; iter++) {
    float center = compute_center(my_ants, num_my_ants);
    for (int a=0; a<num_my_ants; a++) {
      float ant = my_ants[a];
      float nearest_food = nearest_food_source(food_sources, ant);
      float center_force = compute_force(ant, center, 0.012);
      float food_force = compute_force(ant, nearest_food, 0.01);
      my_ants[a] = my_ants[a] + center_force + food_force;
    }

    if (rank == 0) {
      printf("Iteration: %d - Average position: %f\n", iter, center);
    }
  }
  
  free(my_ants);
  free(food_sources);
    
  MPI_Finalize();
  return 0;
}
