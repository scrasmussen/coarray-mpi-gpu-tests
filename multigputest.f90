program omp_gpu
  use openacc
  use mpi_f08
  implicit none
  integer, parameter :: n = 10
  integer, dimension(n,n) :: A, B, C
  ! integer :: send[*], recv
  integer :: send, recv
  integer :: i, j, num, num_d, me, me_d, ierr, tag
  type(MPI_Status) :: status
  integer(ACC_DEVICE_NVIDIA) ::  devicetype
  tag = 11

  ! me = this_image()
  call MPI_Init(ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, me, ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, num, ierr)
  B = me
  C = me


  num_d = acc_get_num_devices(ACC_DEVICE_NVIDIA)
  me_d  = acc_get_device_num(ACC_DEVICE_NVIDIA)

  call acc_set_device_num(me, ACC_DEVICE_NVIDIA)

  print *, me, "get_device_num", acc_get_device_num(ACC_DEVICE_NVIDIA)
  print *, me, "get_num_devices", acc_get_num_devices(ACC_DEVICE_NVIDIA)
  ! sync all
  call MPI_Barrier(MPI_COMM_WORLD)

  !$acc parallel loop
  do j=1,n
     do i=1,n
        A(i,j) = B(i,j) + C(i,j)
     end do
  end do
  !$acc end parallel loop

  print *, "A =", A(1:2,1:2)
  ! sync all
  call MPI_Barrier(MPI_COMM_WORLD)

  if (me .eq. 0) then
     ! recv = send[2]
     recv = send

     call MPI_Recv(A, n*n, MPI_INTEGER, 1, tag, MPI_COMM_WORLD, status, ierr)
     print *, "POSTRECV"
     print *, "A ", A(1:4,1:4)
  else
     call MPI_Send(A, n*n, MPI_INTEGER, 0, tag, MPI_COMM_WORLD, ierr)
  end if

  ! sync all
  call MPI_Finalize(ierr)
  print *, "fin"
end program
