#PURPOSE: Convert an integer number to a decimal string for display.
#
#INPUT:   A buffer large enough to hold the largest possible number.
#	  An integer to convert.
#
#OUTPUT:  The buffer will be overwritten with the decimal string.
#
#VARIABLES:
#  
#  %ecx will hold the count of characters processed
#  %eax will hold the current value
#  %edi will hold the base (10)

.equ ST_VALUE, 8
.equ ST_BUFFER, 12

.globl integer2string
.type integer2string, @function
integer2string:

pushl %ebp
movl %esp, %ebp

movl $0, %ecx					#Current char count

movl ST_VALUE(%ebp), %eax			#Move the value into position

movl $10, %edi					#The base we want to devide with

conversion_loop:

movl $0, %edx					#Division is performed on the combined
						#%edx:%eax register, so first clear out %edx

divl %edi					#Divide %edx:%eax (which are implied) by 10.
						#Store the quotient in %eax and the remainder
						#in %edx (both of which are implied).

addl $'0', %edx					#Quotient is in the right place. %edx has the 
						#remainder, which now needs to be converted
						#into a number. So, %edx has a number that is
						#0 through 9. Tou could also interpret this as 
						#an index on the ASCII table starting from the 
						#charactor '0', The ascii code for '0' plus zero
						#is still the ascii code for '0'. The ascii code 
						#for '0' plus 1 is the ascii code for the 
						#character '1'. Therefore, the following
						#instruction will give us the character for the
						#number stored in %edx

pushl %edx					#Push this value on the stack. This way, when we
						#are done, we can just pop off the characters one
						#by one and they will be in the right order. Note 
						#that we are pushing the whole register; but we only
						#need the byte in %dl (last byte of %edx register)
						#for the character.

incl %ecx					#Increment the digit count

cmpl $0, %eax					#Check to see if %eax is zero yet, go to next step if so
je end_conversion_loop

jmp conversion_loop				#%eax already has its new value



end_conversion_loop:				#The string is now on the strack, if we pop it
						#off a character at a time we can copy it into
						#the buffer and be done.

movl ST_BUFFER(%ebp), %edx			#Get the pointer to the buffer in %edx


copy_reversing_loop:		
popl %eax					#We pushed a whole register, but we only need
movb %al, (%edx)				#the last byte. So we are going to pop off to
						#the entire %eax register, but then only move the
						#small part (%al) into the character string.

decl %ecx					#Decreasing %ecx so we know when we are finished

incl %edx					#Increaing %edx so that it will be pointing to 
						#the next byte

cmpl $0, %ecx					#Check to see if we are finished

je end_copy_reversing_loop			#If so, jump to end of function

jmp copy_reversing_loop				#Otherwise, repeat the loop



end_copy_reversing_loop:
movb $0, (%edx)					#Strings should end with a 0

movl %ebp, %esp
popl %ebp
ret
