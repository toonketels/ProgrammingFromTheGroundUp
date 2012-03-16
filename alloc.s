#PURPOSE: Program to manage memory usage - allocates
#	  and deallocates memoery as requested
#
#NOTES:	  The programs using these routeines will ask
#	  for a certain size of memory. We actually
#	  use more than that size, but we put it
#	  at the beginning, before the pointer 
#	  we hand back. We add a size field and
#	  an AVAILABLE/UNAVAILABLE marker. So, the
#	  memory looks like this
#
# #########################################################
# #Available Marker#Size of memory#Actual memory locations#
# #########################################################
#                                 l__ Returned pointer 
#				      points here
#	  The pointer we return only points to the actual
#	  locatios requested to make it easier for the
#	  calling program. It also allows us to change our
# 	  structurewithout the calling program having to
#	  change at all.

.section .data

############GLOBAL VARIABLES################################

heap_begin:			#This points to the beginning of the 
.long 0				#memory we are managing

current_break:			#This points to one location past the 
.long 0				#memory we are managing



############STRUCTURE INFORMATION##########################

.equ HEADER_SIZE, 8		#Size of space for memory region header
.equ HDR_AVAIL_OFFSET, 0	#Location of the "available" flag in header
.equ HDR_SIZE_OFFSET, 4		#Location fo the size field in the header



###########CONSTANTS#######################################

.equ UNAVAILABLE, 0		#Number to represent the unavailable flag
				#space has been given out
.equ AVAILABLE, 1		#Number to respresent the available flag
				#space that has been returned and available
				#for giving
.equ SYS_BRK, 45		#System call number for beak sys call
.equ LINUX_SYSCALL, 0x80



.section .text

############FUNCTIONS######################################

#alloc_init
#
#PURPOSE: call this function to initialize the functions 
#	  (specifically, this sets heap_begin and current_break).
#	  This has no parameters and no return value.

.globl allocate_init
.type allocate_init, @function
allocate_init:
pushl %ebp			#Standard function stuff
movl %esp, %ebp

				#Calling brk system call with 0 in %ebx,
				# returns the last valid usable address
movl $SYS_BRK, %eax		#Find out where the break is
movl $0, %ebx
int $LINUX_SYSCALL

incl %eax			#%eax has the last valid adress, we want
				#memory location after that

movl %eax, current_break	#store the current break

movl %eax, heap_begin		#store the current break as first address
				#to cause the allocate function to get more
				#memory from Linux the first time run

movl %ebp, %esp
popl %ebp
ret


#allocate
#PURPOSE:	Grabs a section of memory. It first checks for free memory
#		blocks, and if none available, asks Linux for a new one.
#
#PARAMETERS:	One param - the size of the memory block we want to allocate.
#
#RETURN VALUE:	This function returns the address fo the allocated memory in %eax.
#		If no memory available, returns 0 in %eax.
#
#VARIABLES USED:
#
#	%ecx - size requested memory (first/only param)
#	%eax - current memory region beiing examined
#	%ebx - current break position
#	%edx - size of current memory region
#
#We scan through each memory region starting with heap_geign. We look at the size
#of  each one, and if it has been allocated. If it's big enough for the requested
#size, and its available, it grabs that one. If it does not find a region large
#enough, it asks Linux for more memory and move current_break up.

.globl allocate
.type allocate, @function
.equ ST_MEM_SIZE, 8		#stack position of the memory size to allocate

allocate:
pushl %ebp
movl %esp, %ebp

movl ST_MEM_SIZE(%ebp), %ecx	#holds size
movl heap_begin, %eax		#holds current search position
movl current_break, %ebx	

alloc_loop_begin:		#iterate through each memory region

cmpl %ebx, %eax			#if equal needs more memory
je move_break

movl HDR_SIZE_OFFSET(%eax), %edx#grab memory size

				#if space unavlaible jump to next one
cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
je next_location

cmpl %edx, %ecx			#if space is availab,e compare the size
jle allocate_here


next_location:
addl $HEADER_SIZE, %eax		#The total size of the memoryregion is
addl %edx, %eax			#the sum of the size + 8 bytes for headers

jmp alloc_loop_begin		#go to next location


allocate_here:			#we should allocate here
				
				#mark as unavailable
movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
addl $HEADER_SIZE, %eax		#go the address usable memory, we return that

movl %ebp, %esp			#return from the function
popl %ebp
ret


move_break:			#Grab more memory
				#%ebx holds the current endpoint of the data
				#%ecx holds tis size

				#we need to increase %ebx, to where we want memory
				#to end, so we
addl $HEADER_SIZE, %ebx		#add space for headers structure
addl %ecx, %ebx			#add space to the break for data requested

				#ask Linux for memory
pushl %eax
pushl %ecx
pushl %ebx

movl $SYS_BRK, %eax		#reset the break
int $LINUX_SYSCALL

cmpl $0, %eax			#check for error (returned 0)
je error

popl %ebx			#restore saved registers
popl %ecx
popl %eax

				#Set memory as unavaliable, because we giving ti away now
movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
movl %ecx, HDR_SIZE_OFFSET(%eax)#sie of memory

addl $HEADER_SIZE, %eax		#go to actual block of memory.

movl %ebx, current_break	#save new break

movl %ebp, %esp			#reeturn the fucntion
popl %ebp
ret


error:
movl $0, %eax			#on error, return zero
movl %ebp, %esp
popl %ebp
ret



#deallocate
#PURPOSE:	Give back the region of memory to the pool after we're done
#		using it.
#
#PARAMETERS	one - address of memory we want to return to the pool.
#
#RETURN VALUE:	none
#
#PROCESSING	We hand back the actual usafull memory location. Need to set
#		as available 8 bytes before.

.globl deallocate
.type deallocate, @function
.equ ST_MEMORY_SEG, 4		#stack pos memory region to free

deallocate:
				#since function is so simple, we don't need
				#any fancy function stuf

				#get the address of the memory to free
				#(normally this is 8(%ebp), but since
				#we didn't push %ebp or move %esp to 
				#%ebp, we can just do 4(%esp)
movl ST_MEMORY_SEG(%esp), %eax

				#point to real beginning of memory
subl $HEADER_SIZE, %eax
				
				#mark as available
movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)

ret
