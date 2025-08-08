.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    bge x0, a2, error1
    bge x0, a3, error2
    bge x0, a4, error2
    mv t0, x0
    mv t1, x0
    mv t2, x0
loop_start:
    bge x0, a2, loop_end
    slli t3, t0, 2
    slli t4, t1, 2
    add t3, a0, t3
    add t4, a1, t4
    lw t3, 0(t3) # element in arr0
    lw t4, 0(t4) # element in arr1
    mul t3, t3, t4 # e0 * e1
    add t2, t2, t3 # update result
    addi a2, a2, -1
    add t0, t0, a3
    add t1, t1, a4
    j loop_start
loop_end:
    mv a0, t2
    jr ra
error1:
    li a0, 36
    j exit
error2:
    li a0, 37
    j exit