! TODO: documentation

program iscostas
    implicit none
    integer :: n, i, k, d
    integer, allocatable :: perm(:), seen(:)
    logical :: costas

    read (*, *) n
    allocate (perm(n), seen(2 * n + 1))
    read (*, *) perm

    costas = .true.

    seen = 0
    do i = 1, n
        if (perm(i) < 1 .or. perm(i) > n .or. seen(perm(i)) == 1) then
            costas = .false.
        end if
        seen(perm(i)) = 1
    end do

    if (costas) then
        do k = 1, n - 1
            seen = 0
            do i = 1, n - k
                d = perm(i + k) - perm(i) + n + 1
                if (seen(d) == 1) then
                    costas = .false.
                    exit
                end if
                seen(d) = 1
            end do
            if (.not. costas) exit
        end do
    end if

    if (costas) then
        write (*, '(i1)') 1
    else
        write (*, '(i1)') 0
    end if

    deallocate (perm, seen)
end program iscostas
