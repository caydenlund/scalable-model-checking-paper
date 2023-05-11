#!/usr/bin/env make

.PHONY: clean leader_election_buggy leader_election_fixed tictactoe_buggy tictactoe_fixed

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

leader_election_buggy: leader_election_buggy.romp.out leader_election_buggy.rumur.out

leader_election_fixed: leader_election_fixed.romp.out leader_election_fixed.rumur.out

tictactoe_buggy: tictactoe_buggy.romp.out tictactoe_buggy.rumur.out

tictactoe_fixed: tictactoe_fixed.romp.out tictactoe_fixed.rumur.out
	
%.romp.out: %.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

%.rumur.out: %.c
	$(CC) $(CFLAGS) $< -o $@

%.cpp: %.m
	$(ROMP) $(ROMPFLAGS) $< -o $@

%.c: %.m
	$(RUMUR) $(RUMURFLAGS) $< -o $@
