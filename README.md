# [Scalable Model Checking: A Practical Exploration](https://github.com/caydenlund/scalable-model-checking-paper)

This repository contains the paper and all supporting documents.

The paper is the file named `scalable-model-checking.pdf`.

## Outline

* `scalable-model-checking.pdf`: The main paper. Read this!
* `Paper/`: Contains all LaTeX source files for the paper.
    * `main.tex`: The main document skeleton.
    * `introduction.tex`: The introductory section.
    * `tic-tac-toe.tex`: The section on the tic-tac-toe case study.
    * `leader-election.tex`: The section on the leader election case study.
    * `results-and-discussion.tex`: The section on the results of the
      experiments and some other discussion.
    * `conclusion.tex`: The concluding section.
* `Models/`: The accompanying models. The paper refers to these.
    * `Makefile`: A Makefile for building the models.
    * `tictactoe_buggy.m`: The buggy tic-tac-toe strategy.
    * `tictactoe_fixed.m`: The fixed tic-tac-toe strategy.
    * `leader_election_buggy.m`: The buggy leader election protocol.
    * `leader_election_fixed.m`: The fixed leader election protocol.

## Required Tools

* [rumur](https://github.com/Smattr/rumur)
* [romp](https://github.com/civic-fv/romp)
