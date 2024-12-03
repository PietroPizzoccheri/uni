#include <mpi.h>
#include <stdio.h>

// Run with two processes.
// Process 0 sends an integer to process 1 and vice-versa.
// Try to run the system: what goes wrong?

// mpicc deadlock.c -o deadlock
// mpirun -np 2 deadlock

int main(int argc, char **argv)
{
    MPI_Init(NULL, NULL);

    int my_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
    int other_rank = 1 - my_rank;

    int msg_to_send = 1;
    int msg_to_recv;

    // send and receive messages in a non-blocking  way to avoid deadlock
    MPI_Isend(&msg_to_send, 1, MPI_INT, other_rank, 0, MPI_COMM_WORLD, MPI_REQUEST_NULL);
    MPI_Irecv(&msg_to_recv, 1, MPI_INT, other_rank, MPI_ANY_TAG, MPI_COMM_WORLD, MPI_REQUEST_NULL);

    printf("Rank %d received message %d from rank %d\n", my_rank, msg_to_recv, other_rank);

    MPI_Finalize();
}