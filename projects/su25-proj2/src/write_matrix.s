.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    mv s2 a2
    mv s3 a3
    mv s4 a1

    # open file
    addi a1, x0, 1
    jal ra, fopen
    addi t0, x0, -1
    beq a0, t0, error1
    mv s1, a0 # file descriptor

    # write the number of rows and columns
    addi sp, sp, -8
    sw s2, 0(sp)
    sw s3, 4(sp)
    mv a1, sp
    addi a2, x0, 2
    addi a3, x0, 4
    jal ra, fwrite
    addi sp, sp, 8
    addi t0, x0, 2
    bne a0, t0, error2

    # write the matrix
    mul t0, s2, s3
    mv a0, s1
    mv a1, s4
    mul a2, s2, s3
    addi a3, x0, 4
    jal ra, fwrite
    mul t0, s2, s3
    bne a0, t0, error2

    # close the file
    mv a0, s1
    jal ra, fclose
    bne a0, x0, error3

    # Epilogue
    lw ra, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    addi sp, sp, 20

    jr ra

error1:
    li a0, 27
    j exit
error2:
    li a0, 30
    j exit
error3:
    li a0, 28
    j exit
