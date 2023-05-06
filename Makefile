#!/usr/bin/env make

.PHONY: clean dining_philosophers tictactoe_buggy tictactoe_fixed

CC=gcc
CFLAGS=-lpthread -march=native -O3 -fwhole-program -mcx16

CXX=g++
CXXFLAGS=-fpermissive

ROMP=romp
ROMPFLAGS=-S

RUMUR=rumur
RUMURFLAGS=

clean:
	rm -rf *.c *.cpp *.out traces

dining_philosophers: dining_philosophers.romp.out dining_philosophers.rumur.out

tictactoe_buggy: tictactoe_buggy.romp.out tictactoe_buggy.rumur.out

tictactoe_fixed: tictactoe_fixed.romp.out tictactoe_fixed.rumur.out
	
%.romp.out: %.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

%.rumur.out: %.c
	$(CC) $(CFLAGS) $< -o $@

%.cpp: %.m
	$(ROMP) $(ROMPFLAGS) -S $< -o $@

%.c: %.m
	$(RUMUR) $(RUMURFLAGS) $< -o $@
