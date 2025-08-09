.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # check error
    bge x0, a1, error
    bge x0, a2, error
    bge x0, a4, error
    bge x0, a5, error
    bne a2, a4, error
    # save s-register and ra
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    # the loop_index
    mv s1, x0 # the row index of d
    mv s2, x0 # the col index of d
outer_loop_start:
    bge s1, a1, outer_loop_end
inner_loop_start:
    bge s2, a5, inner_loop_end
    # save a-register
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    # deal with the arg of dot
    mul t0, s1, a2
    slli t0, t0, 2
    add a0, a0, t0 # the row of m0 as arr0
    slli t1, s2, 2
    add a1, a3, t1 # the col of m1 as arr1
    addi a3, x0, 1 # the stride of arr0
    mv a4, a5 # the stride of arr1
    # call dot
    jal ra, dot 
    mv t2, a0
    # restore a-register
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28
    # save the result to d[s1][s2]
    mul t0, s1, a5
    slli t0, t0, 2
    slli t1, s2, 2
    add t0, t0, t1
    add t0, t0, a6
    sw t2, 0(t0) 
    # continue inner_loop
    addi s2, s2, 1
    j inner_loop_start
inner_loop_end:
    # continue outer_loop
    mv s2, x0 # s2 reset 0
    addi s1, s1, 1
    j outer_loop_start
outer_loop_end:
    # restore s-register
    lw ra, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 12
    jr ra
error:
    li a0, 38
    j exit