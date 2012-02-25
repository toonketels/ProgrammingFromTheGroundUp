#PURPOSE: Calculates the square of number 5.

.section .data

#This program has no global data.

.section .text

.globl _start
.globl square

_start:
pushl $9			#Push first param onto stack
call square			#Call function
addl $4, %esp			#Clean up the stack - remove our param
movl %eax, %ebx			#Move the square result to %ebx to return
movl $1, %eax			#Exit system call
int $0x80

#Our actual square program
.type square,@function
square:
push %ebp			#Save old base pointer
movl %esp, %ebp			#Set new base pointer to current
				#stack pointer
movl 8(%ebp), %eax		#move first argument to %eax
imull %eax, %eax		#multiple our argument
				#since the result is in %eax,
				#we can just return
movl %esp, %ebp
popl %ebp
ret

