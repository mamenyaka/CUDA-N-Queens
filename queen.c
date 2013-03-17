#include <stdio.h>
#include <math.h>

int db = 0, queens;
FILE *f;

void kiir(char *A)
{
    int i, j;
    
    db++;
    
    for(i = 0; i < 20; i++)
	printf("\b");
    
    printf("%d", db);
    
    fprintf(f, "%d\n", db);

    
    for(i = 0; i < queens; i++)
    {
        for(j = 0; j < queens; j++)
            if(A[i] == j)
                fprintf(f, "Q ");
            else
                fprintf(f, ". ");

        fprintf(f, "\n");
    }

    fprintf(f, "\n");
}

void queen(char *A, const int k, const int n)
{
    A[n-1] = k;

    int i, j;
    for(i = 0; i < n - 1; i++)
        for(j = i + 1; j < n; j++)
            if(A[i] == A[j] || abs(i - j) == abs(A[i] - A[j]))
                return;

    if(n == queens)
        kiir(A);
    else
        for(i = 0; i < queens; i++)
        {
            char B[n+1];

            for(j = 0; j < n; j++)
                B[j] = A[j];

            queen(B, i, n+1);
        }
}

int
main()
{
    printf("Number of queens: ");
    scanf("%d", &queens);

    f = fopen("out", "w");
    
    printf("Number of solutions: \n");

    int i;
    for(i = 0; i < queens; i++)
    {
        char A[1] = {0};
        queen(A, i, 1);
    }

    printf("\n");

    fclose(f);

    return 0;
}
