#PURPOSE: Demonstrates how to call printf
#

.section .data

firststring:
.ascii "Hello! %s is a %s who loves the number %d\n\0"
name:
.ascii "Jonathan\0"
personstring:
.ascii "person\0"
numberloved:
.long 3

.section .text
.globl _start
_start:
pushl numberloved		# %d
pushl $personstring		# %s
pushl $name			# %s
pushl $firststring		# Actual string
call printf

pushl $0
call exit
