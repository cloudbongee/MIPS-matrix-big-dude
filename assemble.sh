#!/bin/bash

echo "Assembling ASM Matrix"

echo "Checking you have all your Cross assembler requirements..."
echo "Finding binutils-mips-linux-gnu"

if ! dpkg -l | grep binutils-mips-linux-gnu ; then 
	echo "Installing..."
	sudo apt-get install binutils-mips-linux-gnu
else
	echo "Already exists :-)"
fi

echo "\n	Assembling matrix.asm...\n"
mips-linux-gnu-as main.asm -o main.o

echo "\n	Assembling file_reader.asm...\n"
mips-linux-gnu-as file_read.asm -o file_read.o

echo "\n	linking all assembled files...\n"
mips-linux-gnu-ld main.o file_read.o -o matrix


