#PURPOSE: Given a number, this program computes the 
#	  factorial. For example, the factorial of 
#	  3 is 3 * 2 * 1.

#This program show how to call a function recusively.

.section .data

#This program has no global data

.section .text

.globl _start
.globl factorial		#this is unneeded unless we want to share
				#this function among other programs
_start:
pushl $4			#The factorial takes one argument - the
				#number we want a factorial of. So, it
				#gets pushed
call factorial			#run the factorial function
addl $4, %esp			#scrubs the paramets that was pushed on
				#the stack
movl %eax, %ebx			#factorial returns the anwser to %eax, but
				#we want it in %bx to send it as our 
				#exit status
movl $1, %eax			#call kernel's exit function
int $0x80


#This is the actual function definition
.type factorial,@function
factorial:
pushl %ebp			#standard function stuff - we have to
				#restore %ebp to its prior state before
				#returning, we we have to push it
movl %esp, %ebp			#this is because we dont want to modify
				#the stack pointer, so we use %ebp.

movl 8(%ebp), %eax		#moves the first argument to %eax
cmpl $1, %eax			#if the number is one, this is our base
				#case, and we simply return (1 is
				#already in %eax as the return value)
je end_factorial
decl %eax			#otherwise, decrease the value
pushl %eax			#push it for our call to factorial
call factorial
movl 8(%ebp), %ebx		#%eax has the return value, so we reload
				#our parameter into %ebx
imull %ebx, %eax		#multiply that be the result of the
				#last call to factorial (in %eax)
				#the answer is stored in %eax
end_factorial:
movl %ebp, %esp
popl %ebp
ret
