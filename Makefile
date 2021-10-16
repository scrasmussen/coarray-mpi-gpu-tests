lc=nvfortran
lc=mpif90
file=multigputest.f90

# nvfortran + OpenACC
lflags=-g -O3 -acc -Minfo=accel

all: build

build:
	$(lc) $(lflags) $(file) -o runMe.exe

r: run
run:
	mpirun -n 2 ./runMe.exe

clean:
	rm -rf *~ *.exe *.o *.opt *.cg test_gpu.o* omp_gpu.n001.gpu *.cub *.ptx
