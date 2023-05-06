---------------------------------------------------------------------------
--  File:     dining_philosophers.m                                      --
--  Brief:    An encoding of the dining philosophers problem in Murphi.  --
--  Details:  This version has no tests.                                 --
--  Author:   Cayden Lund (cayden.lund@utah.edu)                         --
---------------------------------------------------------------------------



--  Constants:
--------------

Const
    NUM_PHIL : 5;



--  Types:
----------

Type
    fork_t : enum { IN_USE, FREE };
    philosopher_index_t : 0..(NUM_PHIL-1);



--  Variables:
--------------

Var
    forks : array[philosopher_index_t] of fork_t



--  Start state:
----------------

Ruleset philosopher_index : philosopher_index_t Do
    Startstate
        --  All forks are free at the beginning.
        For fork_index : philosopher_index_t Do
            forks[fork_index] := FREE;
        End;
    Endstartstate;
Endruleset;



--  Rules:
----------

Ruleset philosopher_index : philosopher_index_t Do
    Alias
    left_fork : forks[(philosopher_index) % 5];
    right_fork : forks[(philosopher_index + 1) % 5] Do

        -- If the left fork is free, pick it up.
        Rule "Pick up left fork"
        left_fork = FREE
        ==>
        Begin
        left_fork := IN_USE;
        Endrule;

        -- If holding the left fork, if the right fork is free, pick it up.
        Rule "Pick up right fork"
        left_fork = IN_USE & right_fork = FREE
        ==>
        Begin
        right_fork := IN_USE;
        Endrule;

        -- When holding both forks, eat a few bites and then set them down.
        Rule "Put down forks"
        left_fork = IN_USE & right_fork = IN_USE
        ==>
        Begin
        left_fork := FREE;
        right_fork := FREE;
        Endrule;

    Endalias;
Endruleset;
