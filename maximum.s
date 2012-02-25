#PURPUSE: This program finds the maximum number
#	  in a list of numbers.
#
#VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item being examined.
# %ebx - Largest data item found.
# %eax - Current data item.
#
# The following memory locations are used:
#
# data_items - contains the item data. a 0 is used to
#	       to determine the data.

.section .data

data_items:			#These are the data items
.long 3,67,34,222,45,65,45,47,98,143,44,66,0

.section .text

.globl _start
_start:
movl $0, %edi			# move 0 into the index register
movl data_items(,%edi,4), %eax	# load the first byte of data
movl %eax, %ebx			# since it's the first time, %eax
				# is the biggest
start_loop:			# start loop
cmpl $0, %eax			# check if we hit the end
je loop_exit
incl %edi			# load next value
movl data_items(,%edi,4), %eax
cmpl %ebx, %eax			# compare values
jle start_loop			# jump to beginning of loop if value
				# is smaller
movl %eax, %ebx			# is %eax is bigger, load it in the
				# %ebx register
jmp start_loop			# and start all over again
loop_exit:
# %ebx is the status code for the exit system call and also holds our value
# so on exit, we return this value (or we can retrieve it via echo $?).
	movl $1, %eax		#1 is the exit() call
	int $0x80
