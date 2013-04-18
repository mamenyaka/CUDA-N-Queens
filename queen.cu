#include <stdio.h>

#define QUEENS 10

__device__
void kiir(char *A)
{
    char s[QUEENS*21 + 1];
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

    printf("%s\n", s);
}

__global__
void queen(int *db, const int n)
{
    {
	bool B[QUEENS];
	
	for(int i = 0; i < QUEENS; i++)
	    B[i] = 0;
	
	B[threadIdx.x] = 1;
	B[threadIdx.y] = 1;
	B[threadIdx.z] = 1;
	B[blockIdx.x/10] = 1;
	B[blockIdx.x%10] = 1;
	B[blockIdx.y/10] = 1;
	B[blockIdx.y%10] = 1;
	B[blockIdx.z/10] = 1;
	B[blockIdx.z%10] = 1;
	B[n] = 1;
	
	for(int i = 0; i < QUEENS; i++)
	    if(B[i] == 0)
		return;
    }
    
    char A[QUEENS];
    
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

    for(int i = 0; i < QUEENS - 1; i++)
        for(int j = i + 1; j < QUEENS; j++)
            if(abs(i - j) == abs(A[i] - A[j]))
                return;
	    
    atomicAdd(db, 1);
    printf("%d.\n", *db);
    kiir(A);
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
	queen<<<blocksPerGrid, threadsPerBlock>>>(d, i);

    cudaMemcpy(&h, d, sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(d);
    cudaDeviceReset();

    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess)
    {
        fprintf(stderr, "CUDA error: %s\n", cudaGetErrorString(error));
        return -1;
    }

    fprintf(stderr, "Solutions: %d\n", h);

    fprintf(stderr, "\nDone\n");
    return 0;
}
