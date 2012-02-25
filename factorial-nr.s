#PURPOSE: Non recursive version of the factorial program.

.section .data

#There is no global data.

.section .text

.globl _start
.globl factorial

_start:
push $7				#Our first parameter
call factorial
addl $4, %esp			#Restore stack pointer
movl %eax, %ebx			#Put the result in %ebx
movl $1, %eax			#Make the exit system call
int $0x80


#Our actual program
.type factorial,@function
factorial:
pushl %ebp			#Save the old base pointer
movl %esp, %ebp			#Set the new base pointer to the current
				#Stack pointer
movl 8(%ebp), %eax		#Get the first argument
movl %eax, %ebx			#Copy the result over to %ebx

factorial_loop_start:
cmpl $1, %ebx			#if the number is 1, we are done
je end_factorial

decl %ebx			#increment %ebx with one
imull %ebx, %eax		#mulipli %ebx with %eax
				#results stored in %eax
jmp factorial_loop_start	#continue until we reach one

end_factorial:
movl %ebp, %esp			#restore stack pointer
popl %ebp
ret
