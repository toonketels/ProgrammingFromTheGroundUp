.include "linux.s"
.include "record-def.s"

.section .data
file_name:
.ascii "test.dat\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE

.section .text
.globl _start
_start:
.equ ST_INPUT_DESCRIPTOR, -4
.equ ST_OUTPUT_DESCRIPTOR, -8

movl %esp, %ebp
subl $8, %esp					#Make room for local vars

movl $SYS_OPEN, %eax				#Open the file
movl $file_name, %ebx
movl $0, %ecx					#Open read-only
movl $0666, %edx
int $LINUX_SYSCALL

movl %eax, ST_INPUT_DESCRIPTOR(%ebp)		#Save file descriptor

movl $STDOUT, ST_OUTPUT_DESCRIPTOR(%ebp)	#Save output file descriptor
						#makes it easy to change to diff file

record_read_loop:
pushl ST_INPUT_DESCRIPTOR(%ebp)
pushl $record_buffer
call read_record
addl $8, %esp

cmpl $RECORD_SIZE, %eax				#returns number of bytes read
jne finished_reading 				#if it's not the same number as requested
						#its and end of file or error, so quit
pushl $RECORD_FIRSTNAME + record_buffer		#print out first name, first know its size
call count_chars
addl $4, %esp
movl %eax, %edx
movl ST_OUTPUT_DESCRIPTOR(%ebp), %ebx
movl $SYS_WRITE, %eax
movl $RECORD_FIRSTNAME + record_buffer, %ecx
int $LINUX_SYSCALL

push ST_OUTPUT_DESCRIPTOR(%ebp)
call write_newline
addl $4, %esp

jmp record_read_loop

finished_reading:
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL
