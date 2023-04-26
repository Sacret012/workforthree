#include <iostream>

using namespace std;
#define n 800

__global__ void matAdd(float (*)[n], float (*)[n],
					   float (*)[n]);

int main()
{
	const int memSize = sizeof(float) * n * n;
	// Выделение памяти для хост матриц
	float (*a)[n] = (float(*)[n])malloc(memSize);
	float (*b)[n] = (float(*)[n])malloc(memSize);
	float (*c)[n] = (float(*)[n])malloc(memSize);

		// Инициализация двух хост матриц
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < n; j++) {
			a[i][j] = b[i][j] = 0.5;
			c[i][j] = 0;
		}
	}

	// Создание девайс матриц
	float (*devA)[n];
	float (*devB)[n];
	float (*devC)[n];
	size_t pitch;

	// Выделение памяти на устройстве
	cudaMallocPitch(&devA, &pitch, n * sizeof(float), n);
	cudaMallocPitch(&devB, &pitch, n * sizeof(float), n);
	cudaMallocPitch(&devC, &pitch, n * sizeof(float), n);

	cudaMemcpy2D(devA, pitch, a, n * sizeof(float), n * sizeof(float), n, cudaMemcpyHostToDevice);
	cudaMemcpy2D(devB, pitch, b, n * sizeof(float), n * sizeof(float), n, cudaMemcpyHostToDevice);

	dim3 numThreadsPerBlock(10, 10);
	dim3 numBlocks((n + numThreadsPerBlock.x - 1) / numThreadsPerBlock.x,
					(n + numThreadsPerBlock.y - 1) / numThreadsPerBlock.y);
	matAdd<<<numBlocks, numThreadsPerBlock>>>(devA, devB, devC);

	cudaMemcpy2D(c, n * sizeof(float), devC, pitch, n * sizeof(float), n, cudaMemcpyDeviceToHost);

	cudaFree(devA);
	cudaFree(devB);
	cudaFree(devC);

	for (int i = 0; i < 5; i++) {
		for (int j = 0; j < 5; j++) {
			cout << c[i][j] << ' ';
		}
		cout << '\n';
	}

	free(a);
	free(b);
	free(c);

	return 0;	
}

__global__ void matAdd(float (*A)[n], float (*B)[n],
					   float (*C)[n])
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;
	int j = blockDim.y * blockIdx.y + threadIdx.y;
	
	if (i < n && j < n) 
		C[i][j] = A[i][j] + B[i][j];
}






