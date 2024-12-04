#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int rank;
int num_procs;

const int num_rounds = 10;

const int min_num = 1;
const int max_num = 1000;

// Array, one element per process
// The leader board, instantiated and used in process 0
int *leaderboard = NULL;

// Array, one element per process
// The array of number selected in the current round
int *selected_numbers = NULL;

// The leader for the current round
int leader = 0;

// Allocate dynamic variables
void allocate_vars()
{
  leaderboard = (int *)malloc(num_procs * sizeof(int));
  selected_numbers = (int *)malloc(num_procs * sizeof(int));
  memset(leaderboard, 0, num_procs * sizeof(int));
  memset(selected_numbers, 0, num_procs * sizeof(int));
}

// Deallocate dynamic variables
void free_vars()
{
  free(leaderboard);
  free(selected_numbers);
}

// Select a random number between min_num and max_num
int select_number()
{
  return min_num + rand() % (max_num - min_num + 1);
}

// Function used to communicate the selected number to the leader
void send_num_to_leader(int num)
{
  MPI_Send(&num, 1, MPI_INT, leader, 0, MPI_COMM_WORLD);
}

// Compute the winner (-1 if there is no winner)
// Function invoked by the leader only
int compute_winner(int number_to_guess)
{
  int diff = 0;
  int min_diff = max_num; // the difference cannot be larger than the max_num used to generte the random number
  int new_leader = -1;
  for (int i = 0; i < num_procs; i++)
  {
    diff = abs(selected_numbers[i] - number_to_guess);
    if (diff < min_diff)
    {
      min_diff = diff;
      new_leader = i;
    }
  }
  return new_leader;
}

// Function used to communicate the winner to everybody
void send_winner(int *winner)
{
  MPI_Bcast(winner, 1, MPI_INT, leader, MPI_COMM_WORLD);
}

// Update leader
void update_leader(int winner)
{
  if(winner != -1)
    leader = winner;
}

// Update leaderboard (invoked by process 0 only)
void update_leaderboard(int winner)
{
  leaderboard[winner]++;
}

// Print the leaderboard
void print_leaderboard(int round, int winner)
{
  printf("\n* Round %d *\n", round);
  printf("Winner: %d\n", winner);
  printf("Leaderboard\n");
  for (int i = 0; i < num_procs; i++)
  {
    printf("P%d:\t%d\n", i, leaderboard[i]);
  }
}

void receive_numbers()
{
  for (int i = 0; i < num_procs; i++)
  {
    MPI_Status status;
    MPI_Probe(MPI_ANY_SOURCE, 0, MPI_COMM_WORLD, &status);
    int source = status.MPI_SOURCE;
    MPI_Recv((selected_numbers + source), 1, MPI_INT, source, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
  }
}

int main(int argc, char **argv)
{
  MPI_Init(NULL, NULL);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &num_procs);
  srand(time(NULL) + rank);

  allocate_vars();
  int winner;
  for (int round = 0; round < num_rounds; round++)
  {
    int my_selected_number = select_number();

    send_num_to_leader(my_selected_number);

    if (rank == leader)
    {
      receive_numbers();
      int number_to_guess = select_number();
      winner = compute_winner(number_to_guess); // computes winner against number selected by winner
    }
    send_winner(&winner);
    update_leader(winner);

    if (rank == 0)
    {
      update_leaderboard(winner);
      print_leaderboard(round, winner);
    }
  }

  MPI_Barrier(MPI_COMM_WORLD);
  free_vars();

  MPI_Finalize();
}
