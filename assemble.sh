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
echo ""
echo "		Assembling matrix.asm..."
echo ""
mips-linux-gnu-as main.asm -o main.o
echo ""
echo "		Assembling file_reader.asm..."
echo ""
mips-linux-gnu-as file_read.asm -o file_read.o
echo ""
echo "		Assembling object.asm..."
echo ""
mips-linux-gnu-as object.asm -o object.o
echo ""
echo "		Assembling parse.asm..."
echo ""
mips-linux-gnu-as parse.asm -o parse.o
echo ""
echo "		Assembling symbol_pool.asm..."
echo ""
mips-linux-gnu-as symbol_pool.asm -o symbol_pool.o
echo ""
echo "		Linking all assembled files..."
echo ""
mips-linux-gnu-ld main.o file_read.o symbol_pool.o parse.o object.o -o matrix


