#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define INFINITE 1e20

// Group number: 12
// Group members:
//  Pietro Pizzocheri - 10797420
//  Heitor Tanoue de Mello - 11071263
//  Enzo Conti - 11071898

const double L = 100.0;
const int n = 1000;
const int iterations_per_round = 1000;
const double allowed_diff = 0.001;

double initial_condition(double x, double L)
{
    return fabs(x - L / 2.0);
}

void initialize_global_array(double *global_array, double L, int n)
{
    double dx = L / (n - 1);
    for (int i = 0; i < n; i++)
    {
        double x = i * dx;
        global_array[i] = initial_condition(x, L);
    }
}

void perform_round_iterations(double *curr, double *next, int chunk_size, int rank, int num_procs)
{
    double left_recv, right_recv;

    double left_send = curr[0];
    double right_send = curr[chunk_size - 1];

    int left_rank = (rank == 0) ? MPI_PROC_NULL : rank - 1;
    int right_rank = (rank == num_procs - 1) ? MPI_PROC_NULL : rank + 1;

    for (int it_on_round = 1; it_on_round <= iterations_per_round; it_on_round++)
    {
        MPI_Sendrecv(&left_send, 1, MPI_DOUBLE, left_rank, 0, &right_recv, 1, MPI_DOUBLE, right_rank, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        MPI_Sendrecv(&right_send, 1, MPI_DOUBLE, right_rank, 1, &left_recv, 1, MPI_DOUBLE, left_rank, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        for (int i = 0; i < chunk_size; i++)
        {
            if (rank == 0 && i == 0)
            { // first chunk, first point
                next[i] = (curr[0] + curr[1]) / 2.0;
                continue;
            }

            if (rank == num_procs - 1 && i == chunk_size - 1)
            { // last chunk, last point
                next[i] = (curr[chunk_size - 2] + curr[chunk_size - 1]) / 2.0;
                continue;
            }

            // internal points
            double left_val, right_val;
            if (i == 0)
            {
                left_val = left_recv;
                right_val = curr[i + 1];
            }
            else if (i == chunk_size - 1)
            {
                left_val = curr[i - 1];
                right_val = right_recv;
            }
            else
            {
                left_val = curr[i - 1];
                right_val = curr[i + 1];
            }
            next[i] = (left_val + curr[i] + right_val) / 3.0;
        }
        // next becomes curr
        double *temp = curr;
        curr = next;
        next = temp;
    }
}

void compute_global_min_max(double *curr, int chunk_size, double *global_min, double *global_max)
{
    double local_min = curr[0];
    double local_max = curr[0];
    for (int i = 1; i < chunk_size; i++)
    {
        if (curr[i] < local_min)
            local_min = curr[i];
        if (curr[i] > local_max)
            local_max = curr[i];
    }

    MPI_Allreduce(&local_min, global_min, 1, MPI_DOUBLE, MPI_MIN, MPI_COMM_WORLD);
    MPI_Allreduce(&local_max, global_max, 1, MPI_DOUBLE, MPI_MAX, MPI_COMM_WORLD);
}

int main(int argc, char **argv)
{
    MPI_Init(&argc, &argv);

    int rank, num_procs;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

    int chunk_size = n / num_procs;

    double *global_array = NULL;
    if (rank == 0)
    {
        global_array = (double *)malloc(n * sizeof(double));
        initialize_global_array(global_array, L, n);
    }

    double *curr = (double *)malloc(chunk_size * sizeof(double));
    double *next = (double *)malloc(chunk_size * sizeof(double));

    MPI_Scatter(global_array, chunk_size, MPI_DOUBLE, curr, chunk_size, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    // for (int i = 0; i < chunk_size; i++)
    // {
    //     printf("rank %d, %d: %f\n", rank, i, curr[i]);
    // }

    if (global_array)
    {
        free(global_array);
        global_array = NULL;
    }

    int round = 0;
    double max_diff = INFINITE;
    double global_min;
    double global_max;
    while (max_diff >= allowed_diff)
    {
        round++;

        compute_global_min_max(curr, chunk_size, &global_min, &global_max);

        max_diff = global_max - global_min;

        // Print results from rank 0
        if (rank == 0)
        {
            printf("Round: %d\tMin: %.5f\tMax: %.5f\tDiff: %.5f\n", round, global_min, global_max, max_diff);
        }

        perform_round_iterations(curr, next, chunk_size, rank, num_procs);
    }

    free(curr);
    free(next);

    MPI_Finalize();
    return 0;
}