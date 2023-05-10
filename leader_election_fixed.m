--------------------------------------------------------------------------------
--  File:   leader_election_fixed.m                                           --
--  Author: Cayden Lund (cayden.lund@utah.edu)                                --
--          Student, University of Utah                                       --
--                                                                            --
--  Brief:  This is a Murphi model that encodes the leader election           --
--          algorithm developed by Dolev, Klawe, and Rodeh, as outlined by    --
--          Edmund M. Clarke.                                                 --
--------------------------------------------------------------------------------



--------------------
--  DESCRIPTION:  --
--------------------


--  The problem:
----------------

--  There are `N` processes. Each process has a unique number.
--
--  These processes form a ring; one process can receive a message from its left
--  and send a message to its right.
--
--  The goal is to find the largest unique number between the processes and
--  propagate it to all processes.


--  The algorithm:
------------------

--  Initially, each process is `active` and has a unique `value`.
--
--  Each process is responsible for some `max_value`, which may change during
--  execution.
--
--  A process becomes `passive` when it learns that it does not hold a
--  `max_value` that can be the actual maximum value.
--
--  A `passive` process can only pass messages from left to right.
--
--  Each `active` process sends its own value to the right and then waits to
--  receive the value of the closest active process on its left.
--  This message is tagged `one`.
--
--  If the value that an `active` process receives is not the same value that it
--  sent out, then it waits for the value of the second-closest active process
--  on its left. This message is tagged `two`. If the value of this process is
--  the largest of the three, then it keeps its value; otherwise, it becomes
--  `passive`.
--
--  If an `active` process receives the same value that it sent, then it can
--  conclude that it is the only `active` process and has the maximum value.
--
--  TODO: Discuss propagation.



------------------
--  CONSTANTS:  --
------------------

Const
    --  The number of processes.
    NUM_PROCESSES : 5;



--------------
--  TYPES:  --
--------------

Type
    --  The index of a process.
    proc_index_t : 0..(NUM_PROCESSES - 1);

    --  The value that a process can have.
    --  value_t : MIN_VALUE..MAX_VALUE;
    value_t : proc_index_t;

    --  The possible tags that a message can have.
    tag_t : Enum { ONE, TWO, FINAL };

    --  The possible states in which a process can be.
    proc_state_t : Enum {
            ACTIVE_READY,
            ACTIVE_AWAITING_ONE,
            ACTIVE_SEND_TWO,
            ACTIVE_AWAITING_TWO,
            PASSIVE,
            FINISHED
        };

    --  The possible states in which the message channel can be.
    chan_state_t : Enum { BUSY, FREE };



------------------
--  VARIABLES:  --
------------------

Var
    --  The state of each process.
    states : Array[proc_index_t] Of proc_state_t;

    --  The value of each process.
    values : Array[proc_index_t] Of value_t;

    --  The saved value of the last active process.
    previous_values : Array[proc_index_t] Of value_t;

    --  The channel of values.
    value_channel : Array[proc_index_t] Of value_t;

    --  The channel of tags.
    tag_channel : Array[proc_index_t] Of tag_t;

    --  The state of the message channel.
    chan_states : Array[proc_index_t] Of chan_state_t;



------------------
--  FUNCTIONS:  --
------------------

--  Swaps the two given values.
Procedure swap(Var left : value_t;
               Var right : value_t);
Var temp : value_t;
Begin
    temp := values[left];
    left := right;
    right := temp;
End;

--  Resets all the variables to their initial state.
Procedure reset_all(Var states : Array[proc_index_t] of proc_state_t;
                    Var values : Array[proc_index_t] of value_t;
                    Var previous_values : Array[proc_index_t] of value_t;
                    Var value_channel : Array[proc_index_t] of value_t;
                    Var tag_channel : Array[proc_index_t] of tag_t;
                    Var chan_states : Array[proc_index_t] of chan_state_t);
Var index_j : proc_index_t;
Begin
    For index : proc_index_t Do
        states[index] := ACTIVE_READY;
        values[index] := index;
        chan_states[index] := FREE;
    End;
    
    --  Shuffle the values array.
    --  TODO: This.
    --  For index_i : 2..(NUM_PROCESSES / 2) Do
    --      index_j := 1;
    --      While index_j != 0 Do
    --          swap(values[index_i], values[index_j]);
    --          index_j := (index_j + index_i) % NUM_PROCESSES;
    --      Endwhile;
    --  End;
End;



--------------
--  RULES:  --
--------------

Ruleset proc_index : proc_index_t Do
    Alias
    state : states[proc_index];
    val : values[proc_index];
    prev_val : previous_values[proc_index];

    in_val : value_channel[proc_index];
    in_tag : tag_channel[proc_index];
    in_state : chan_states[proc_index];

    next_index : (proc_index + 1) % NUM_PROCESSES;
    out_val : value_channel[next_index];
    out_tag : tag_channel[next_index];
    out_state : chan_states[next_index]
    Do

        --  The starting state.
        Startstate
            reset_all(states, values, previous_values,
                      value_channel, tag_channel, chan_states);
        Endstartstate;

        --  If this is a passive process, and the output message channel is
        --  free, and there's an incoming message, pass it along.
        Rule "Passive process: pass message"
            state = PASSIVE &
            in_state = BUSY &
            out_state = FREE &
            (in_tag = ONE | in_tag = TWO)
        ==>
        Begin
            out_val := in_val;
            out_tag := in_tag;
            in_state := FREE;
            out_state := BUSY;
        Endrule;
        
        --  If this is a passive process, and there's an incoming message, and
        --  the incoming message is a `FINAL` message, then we have found the
        --  max value.
        Rule "Passive process: found max value"
            state = PASSIVE &
            in_state = BUSY &
            out_state = FREE &
            in_tag = FINAL
        ==>
        Begin
            val := in_val;
            out_val := in_val;
            out_tag := FINAL;
            in_state := FREE;
            out_state := BUSY;
            state := FINISHED;
        Endrule;

        --  If this is a free active process, and the output channel is free,
        --  send its value to the right.
        Rule "Active process: free: send value"
            state = ACTIVE_READY &
            out_state = FREE
        ==>
        Begin
            out_val := val;
            out_tag := ONE;
            out_state := BUSY;
            state := ACTIVE_AWAITING_ONE;
        Endrule;

        --  If this is an active process awaiting the `ONE` message, and the
        --  input channel is sending a `ONE` message, accept it.
        Rule "Active process: awaiting `ONE`: accept value"
            state = ACTIVE_AWAITING_ONE &
            in_state = BUSY &
            in_tag = ONE &
            in_val != val
        ==>
        Begin
            prev_val := in_val;
            in_state := FREE;
            state := ACTIVE_SEND_TWO;
        Endrule;
        
        --  If this is an active process awaiting the `ONE` message, and the
        --  input channel is sending a `ONE` message with the same value as
        --  this process, then this process has the maximum value.
        Rule "Active process: awaiting `ONE`: found max value"
            state = ACTIVE_AWAITING_ONE &
            in_state = BUSY &
            in_tag = ONE &
            in_val = val
        ==>
        Begin
            state := FINISHED;
            in_state := FREE;
            out_val := val;
            out_tag := FINAL;
            out_state := BUSY;
        Endrule;
        
        --  If this is an active process ready to send the `TWO` message,
        --  and the output channel is free, send the `TWO` message.
        Rule "Active process: send `TWO`: send value"
            state = ACTIVE_SEND_TWO &
            out_state = FREE
        ==>
        Begin
            state := ACTIVE_AWAITING_TWO;
            out_val := prev_val;
            out_tag := TWO;
            out_state := BUSY;
        Endrule;
        
        --  If this is an active process awaiting the `TWO` message, and the
        --  input channel is sending a `TWO` message, accept it.
        Rule "Active process: awaiting `TWO`: accept value"
            state = ACTIVE_AWAITING_TWO &
            in_state = BUSY &
            in_tag = TWO
        ==>
        Begin
            If val > prev_val & val > in_val Then
                state := ACTIVE_READY;
            Else
                state := PASSIVE;
            End;
            in_state := FREE;
        Endrule;
        
        --  If this is a `FINISHED` process and there's an incoming message,
        --  then we run our assertions and reset the state.
        Rule "Finished process: incoming message: run assertions"
            state = FINISHED &
            in_state = BUSY &
            in_tag = FINAL
        ==>
        Begin
            in_state := FREE;
            For index : proc_index_t Do
                Assert "Clear message channel" chan_states[index] = FREE;
                Assert "Correct maximum value" values[index] = NUM_PROCESSES - 1;
            End;
            reset_all(states, values, previous_values,
                      value_channel, tag_channel, chan_states);
        Endrule;

    Endalias;
Endruleset;
