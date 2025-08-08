.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    bge x0, a1, error
    mv t1, x0
loop_start:
    bge t1, a1, loop_end
    slli t2, t1, 2
    add t0, a0, t2
    lw t2, 0(t0)
    bge t2, x0, loop_continue
    sw x0, 0(t0)
loop_continue:
    addi t1, t1, 1
    j loop_start
loop_end:
    jr ra
error:
    li a0, 36
    j exit
    