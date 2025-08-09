.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # Prologue
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    mv s2 a1
    mv s3 a2

    # open file
    mv a1, x0
    jal ra, fopen
    addi t0, x0, -1
    beq a0, t0, error2
    mv s1, a0 # file descriptor

    # read the number of rows and columns
    mv a1, s2
    addi a2, x0, 4
    jal ra, fread
    addi t0, x0, 4
    bne a0, t0, error4
    mv a0, s1
    mv a1, s3
    addi a2, x0, 4
    jal ra, fread
    addi t0, x0, 4
    bne a0, t0, error4

    # allocate space on the heap to store the matrix
    lw t0, 0(s2)
    lw t1, 0(s3)
    mul t0, t0, t1
    slli a0, t0, 2
    mv s4, a0
    addi sp, sp, -4
    sw a0, 0(sp) # save the size of matrix
    jal ra, malloc
    beq a0, x0, error1

    # read the matrix from the file
    mv a2, s4
    mv s4, a0
    mv a0, s1
    mv a1, s4
    jal ra, fread
    lw t0 0(sp) # load the size of matrix
    addi sp, sp, 4
    bne a0, t0, error4

    # close the file
    mv a0, s1
    jal ra, fclose
    bne a0, x0, error3

    # Epilogue
    mv a0, s4
    lw ra, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    addi sp, sp, 20

    jr ra

error1:
    li a0, 26
    j exit
error2:
    li a0, 27
    j exit
error3:
    li a0, 28
    j exit
error4:
    li a0, 29
    j exit
