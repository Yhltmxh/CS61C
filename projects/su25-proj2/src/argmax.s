.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    bge x0, a1, error
    mv t1, x0
    lw t3, 0(a0)
    mv t4, x0
loop_start:
    bge t1, a1, loop_end
    slli t2, t1, 2
    add t0, a0, t2
    lw t2, 0(t0)
    bge t3, t2, loop_continue
    mv t3, t2 # update the max element
    mv t4, t1 # update the index
loop_continue:
    addi t1, t1, 1
    j loop_start
loop_end:
    mv a0, t4
    jr ra
error:
    li a0, 36
    j exit
