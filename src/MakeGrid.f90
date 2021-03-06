!
! Module that makes, initializes and deletes a grid with 
! functions to access the different variables of a grid
!
module MakeGridModule
    use NumberKinds
    use Tools
    implicit none
    save

    private 
    public :: GridType
    public :: New, Delete
    public :: GetGridPoint, GetDimension, GetLowBound, GetUpBound, GetH

    type GridType
        real(KREAL), allocatable :: gridPoints(:)
        integer(KINT) :: numberOfPoints
        real(KREAL) :: interval(2) ! with interval(1) = lowerbound, interval(2) = upperbound
        real(KREAL) :: h
    end type

    interface New 
        module procedure NewPrivate
        module procedure NewPrivateUserInput
    end interface
  
contains

!
! Initialize a new grid and delete a grid
!
subroutine NewPrivate(self, numberOfPoints, interval)
    type (GridType) :: self
    integer(KINT), intent(in) :: numberOfPoints
    real(KREAL), intent(in) :: interval(2)
    integer (KINT) :: i

    ! save the number of gridpoints and the interval
    self%numberOfPoints = numberOfPoints
    self%interval = interval

    ! allocate the grid points array and initialize
    call AllocAndInit(self%gridPoints, self%numberOfPoints)

    ! calculate h
    self%h = CalculateH(self)

    ! calculate the gridpoints
    self%gridPoints(1) = self%interval(1)
    do i = 2, self%numberOfPoints
        self%gridPoints(i) = self%gridpoints(i-1) + (i-1)*self%h
    enddo

    call WriteToFile(self%gridPoints, "Gridpoints")

end subroutine

subroutine NewPrivateUserInput(self)
    type(GridType) :: self
    integer(KINT) :: i

    ! ask for user input
    print *, "Put in number of gridpoints"
    read *, self%numberOfPoints
    if (self%numberOfPoints < 0) then
        print *, "ERROR: Wrong input for the number of gridpoints"
        stop 
    endif
    print *, "Put in the interval"
    read *, self%interval(:)   
    if (abs(self%interval(1)) /= abs(self%interval(2)).or.self%interval(1)>=self%interval(2)) then
        print *, "ERROR: Wrong input for the interval"
        stop 
    endif

    ! allocate the grid points array and initialize
    call AllocAndInit(self%gridPoints, self%numberOfPoints)

    ! calculate h
    self%h = CalculateH(self)

    ! calculate the gridpoints
    self%gridPoints(1) = self%interval(1)
    do i = 2, self%numberOfPoints
        self%gridPoints(i) = self%gridpoints(1) + (i-1)*self%h
    enddo

    call WriteToFile(self%gridPoints, "Gridpoints")

end subroutine

subroutine Delete(self)
    type(GridType) :: self

    deallocate(self%gridPoints)
end subroutine

!
! Accessors
!
function GetGridPoint(self, index)
    type(GridType) :: self 
    integer(KINT) :: index
    real(KREAL) :: GetGridPoint 

    GetGridPoint = self%gridPoints(index)
end function

function GetDimension(self)
    type(GridType) :: self
    integer(KINT) :: GetDimension

    GetDimension = self%numberOfPoints
end function

function GetLowBound(self)
    type(GridType) :: self
    real(KREAL) :: GetLowBound

    GetLowBound = self%interval(1)
end function

function GetUpBound(self)
    type(GridType) :: self
    real(KREAL) :: GetUpBound

    GetUpBound = self%interval(2)
end function

function GetH(self)
    type(GridType) :: self
    real(KREAL) :: GetH

    GetH = self%h
end function

!
! Other routines
!
real(KREAL) function CalculateH(self)
    type(GridType) :: self

    CalculateH = (self%interval(2)-self%interval(1))/self%numberOfPoints
end function

end module MakeGridModule