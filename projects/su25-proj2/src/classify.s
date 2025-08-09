.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    ebreak
    addi t0, x0, 5
    bne a0, t0, classify_error2

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw a2, 24(sp)
    mv s1, a1

    # Read pretrained m0
    lw a0, 4(s1)
    addi sp, sp, -8
    addi a1, sp, 0
    addi a2, sp, 4
    jal ra, read_matrix
    mv s2, a0

    # Read pretrained m1
    lw a0, 8(s1)
    addi sp, sp, -8
    addi a1, sp, 0
    addi a2, sp, 4
    jal ra, read_matrix
    mv s3, a0

    # Read input matrix
    lw a0, 12(s1)
    addi sp, sp, -8
    addi a1, sp, 0
    addi a2, sp, 4
    jal ra, read_matrix
    mv s4, a0

    # s5 = malloc(m0.height * input.width * 4)
    lw t1, 16(sp)
    lw t2, 4(sp)
    mul t0, t1, t2
    slli a0, t0, 2
    jal ra, malloc
    beq a0, x0, classify_error1
    mv s5, a0

    # Compute h = matmul(m0, input)
    mv a0, s2
    lw a1, 16(sp)
    lw a2, 20(sp)
    mv a3, s4
    lw a4, 0(sp)
    lw a5, 4(sp)
    mv a6, s5
    jal ra, matmul

    # Compute h = relu(h)
    lw t1, 16(sp)
    lw t2, 4(sp)
    mv a0, s5
    mul a1, t1, t2
    jal ra, relu

    # Compute o = matmul(m1, h)
    mv a0, s3
    lw a1, 8(sp)
    lw a2, 12(sp)
    mv a3, s5
    lw a4, 16(sp)
    lw a5, 4(sp)
    mv a6, s4
    jal ra, matmul

    # Write output matrix o
    lw a0, 16(s1)
    mv a1, s4
    lw a2, 8(sp)
    lw a3, 4(sp)
    jal ra, write_matrix

    # Compute and return argmax(o)
    mv a0, s4
    lw t1, 8(sp)
    lw t2, 4(sp)
    mul a1, t1, t2
    jal ra, argmax
    mv s1, a0
    addi sp, sp, 24
    # If enabled, print argmax(o) and newline
    lw a2, 24(sp)
    bne a2, x0, end
    jal ra, print_int
    li a0, '\n'
    jal ra, print_char

end:
    # free
    mv a0, s2
    jal ra, free
    mv a0, s3
    jal ra, free
    mv a0, s4
    jal ra, free
    mv a0, s5
    jal ra, free

    mv a0, s1

    # Epilogue
    lw ra, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    addi sp, sp, 28
    jr ra

classify_error1:
    li a0, 26
    j exit
classify_error2:
    li a0, 31
    j exit