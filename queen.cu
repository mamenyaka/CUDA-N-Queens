#include <stdio.h>

#define QUEENS 10

__global__
void queen(int *db, const int n)
{
    int A[QUEENS];

    A[0] = threadIdx.x;
    A[1] = threadIdx.y;
    A[2] = threadIdx.z;
    A[3] = blockIdx.x/10;
    A[4] = blockIdx.x%10;
    A[5] = blockIdx.y/10;
    A[6] = blockIdx.y%10;
    A[7] = blockIdx.z/10;
    A[8] = blockIdx.z%10;
    A[9] = n;

    for(int i = 0; i < QUEENS; i++)
        for(int j = 0; j < QUEENS; j++)
            if((i != j) && (A[i] == A[j] || abs(i - j) == abs(A[i] - A[j])))
                return;

    char s[256];
    int k = 0;

    for(int i = 0; i < QUEENS; i++)
    {
        for(int j = 0; j < QUEENS; j++)
        {
            if(A[i] == j)
                s[k++] =  'Q';
            else
                s[k++] = '.';

            s[k++] = ' ';
        }
        s[k++] = '\n';
    }

    s[k] = '\0';

    atomicAdd(db, 1);
    printf("%d.\n%s\n", *db, s);
}

int
main()
{
    int h = 0, *d;
    cudaMalloc((void**) &d, sizeof(int));
    cudaMemcpy(d, &h, sizeof(int), cudaMemcpyHostToDevice);

    dim3 blocksPerGrid(100, 100, 100);
    dim3 threadsPerBlock(10, 10, 10);

    for(int i = 0; i < QUEENS; i++)
    {
        queen<<<blocksPerGrid, threadsPerBlock>>>(d, i);
        cudaThreadSynchronize();
    }

    cudaMemcpy(&h, d, sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(d);
    cudaDeviceReset();

    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess)
    {
        fprintf(stderr, "CUDA error: %s\n", cudaGetErrorString(error));
        return -1;
    }

    printf("Solutions: %d\n", h);

    fprintf(stderr, "\nDone\n");
    return 0;
}
