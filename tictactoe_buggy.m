--------------------------------------------------------------------------------
--  File:   tictactoe_buggy.m                                                 --
--  Author: Cayden Lund (cayden.lund@utah.edu)                                --
--          Student, University of Utah                                       --
--                                                                            --
--  Brief:  This is a Murphi model that tests a strategy for tic-tac-toe.     --
--          However, this strategy is flawed.                                 --
--          The model uses an `invariant` claim to assert that the opponent   --
--          never wins. This assertion fails because the strategy is flawed.  --
--------------------------------------------------------------------------------



--------------
--  TYPES:  --
--------------

Type
    --  Whose turn it is as the range [1, 2].
    --  Player 1 is 'X' and Player 2 is 'O'.
    turn_t : 1..2;

    --  The range [0, 2] for array indexing.
    index_range_t : 0..2;

    --  A box can be 'X', 'O', or empty.
    box_t : Enum { X, O, EMPTY };

    --  The type of a row. Each row has 3 columns.
    row_t : Array[index_range_t] Of box_t;

    --  The type of the board. Has three rows.
    board_t : Array[index_range_t] Of row_t;

    --  An enumeration of all patterns that should be countered.
    --
    --  ACROSS:
    --  -------
    --      +---+---+---+
    --      | X |   |   |
    --      +---+---+---+
    --      |   |   |   |
    --      +---+---+---+
    --      |   |   | O |
    --      +---+---+---+
    --
    --  ARROW:
    --  ------
    --      +---+---+---+   +---+---+---+
    --      | X |   |   |   | X |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   | X | O |   |   | X |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   | O |   |   | O | O |
    --      +---+---+---+   +---+---+---+
    --
    --  CORNERS:
    --  --------
    --      +---+---+---+   +---+---+---+
    --      | X | O | X |   | X |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   |   |   | O |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   | O |   | X |   | O |
    --      +---+---+---+   +---+---+---+
    --
    --  CROSS:
    --  ------
    --      +---+---+---+   +---+---+---+
    --      | X |   | O |   | X |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   | O |   |   |   | O |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   | X |   | O |   | X |
    --      +---+---+---+   +---+---+---+
    --
    --  CURVE:
    --  ------
    --
    --      +---+---+---+   +---+---+---+
    --      | X | O |   |   | X |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   | O |   |   |   | O |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   | X |   |   | O | X |
    --      +---+---+---+   +---+---+---+
    --
    --      +---+---+---+   +---+---+---+
    --      | X |   |   |   | X |   |   |
    --      +---+---+---+   +---+---+---+
    --      | O | O |   |   |   | O | O |
    --      +---+---+---+   +---+---+---+
    --      |   |   | X |   |   |   | X |
    --      +---+---+---+   +---+---+---+
    --
    --  MIDDLE:
    --  -------
    --      +---+---+---+   +---+---+---+
    --      | X | O |   |   | X |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   |   |   | O |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   |   |   |   |   |   |
    --      +---+---+---+   +---+---+---+
    --
    --      +---+---+---+   +---+---+---+
    --      | X |   |   |   | X |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   | O |   |   |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   |   |   |   | O |   |
    --      +---+---+---+   +---+---+---+
    --
    --  SEVEN:
    --  ------
    --
    --      +---+---+---+
    --      | X | X | O |
    --      +---+---+---+
    --      | O |   | X |
    --      +---+---+---+
    --      |   |   | O |
    --      +---+---+---+
    --
    --  SPLIT:
    --  ------
    --
    --      +---+---+---+   +---+---+---+
    --      | X | O |   |   | X |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   | X |   |   | O | X |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   | O |   |   |   | O |
    --      +---+---+---+   +---+---+---+
    --
    --  TOGETHER:
    --  ---------
    --
    --      +---+---+---+   +---+---+---+
    --      | X |   | 0 |   | X |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   |   |   |   |   |   |
    --      +---+---+---+   +---+---+---+
    --      |   |   |   |   | 0 |   |   |
    --      +---+---+---+   +---+---+---+


    pattern_t : Enum { ACROSS, ARROW, CORNERS, CROSS, CURVE, MIDDLE, SPLIT, TOGETHER };



------------------
--  VARIABLES:  --
------------------

Var
    --  The current state of the board as a 3x3 matrix.
    board : board_t;

    --  Whose turn it is.
    turn : turn_t;



------------------
--  FUNCTIONS:  --
------------------

--  Initializes the given board by setting every cell to `EMPTY`.
Procedure initialize_board(Var board : board_t);
Begin
    For row_index : index_range_t Do
        For col_index : index_range_t Do
            board[row_index][col_index] := EMPTY;
        End;
    End;
End;


--  Reports whether the given board is empty.
Function all_free(board : board_t) : boolean;
Begin
    For row_index : index_range_t Do
        For col_index : index_range_t Do
            If board[row_index][col_index] != EMPTY Then
                Return false;
            Endif;
        End;
    End;
    Return true;
End;


--  Reports whether the given board is full.
Function all_full(board : board_t) : boolean;
Begin
    For row_index : index_range_t Do
        For col_index : index_range_t Do
            If board[row_index][col_index] = EMPTY Then
                Return false;
            Endif;
        End;
    End;
    Return true;
End;


--  Reports whether the given box is the blank of a two-in-a-row of the given
--  box type in the given board.
Function is_blank_of_two(board : board_t; box_type : box_t; row_index, col_index : index_range_t) : boolean;
Begin
    --  The box must be empty.
    If board[row_index][col_index] != EMPTY Then
        Return false;
    Endif;

    --  Check the diagonals.
    If row_index = col_index Then
        --  The downwards diagonal. ('\')
        If board[(row_index + 1) % 3][(col_index + 1) % 3] = box_type
         & board[(row_index + 2) % 3][(col_index + 2) % 3] = box_type Then
            Return true;
        Endif;
    Endif;
    If row_index + col_index = 2 Then
        --  The upwards diagonal. ('\')
        If board[(row_index + 1) % 3][(col_index + 2) % 3] = box_type
         & board[(row_index + 2) % 3][(col_index + 1) % 3] = box_type Then
            Return true;
        Endif;
    Endif;

    --  Check the row.
    If board[row_index][(col_index + 1) % 3] = box_type
     & board[row_index][(col_index + 2) % 3] = box_type Then
        Return true;
    Endif;

    --  Check the column.
    If board[(row_index + 1) % 3][col_index] = box_type
     & board[(row_index + 2) % 3][col_index] = box_type Then
        Return true;
    Endif;

    Return false;
End;


--  Reports whether the given set of three boxes is a two-in-a-row of the given
--  box type.
Function two_in_a_row_boxes(box_a, box_b, box_c, box_type : box_t) : boolean;
Begin
    Return (box_a = EMPTY & box_b = box_type & box_c = box_type)
         | (box_a = box_type & box_b = EMPTY & box_c = box_type)
         | (box_a = box_type & box_b = box_type & box_c = EMPTY);
End;


--  Reports whether the given box type has a two-in-a-row on the board.
Function two_in_a_row(board : board_t; box_type : box_t) : boolean;
Begin
    --  Check every row and column:
    For index : index_range_t Do
        If two_in_a_row_boxes(board[index][0], board[index][1], board[index][2], box_type)
         | two_in_a_row_boxes(board[0][index], board[1][index], board[2][index], box_type)
        Then
            Return true;
        Endif;
    End;

    --  Check diagonals:
    Return two_in_a_row_boxes(board[0][0], board[1][1], board[2][2], box_type)
         | two_in_a_row_boxes(board[0][2], board[1][1], board[2][0], box_type);
End;


--  Reports whether the given box type has a three-in-a-row on the board.
Function three_in_a_row(board : board_t; box_type : box_t) : boolean;
Begin
    --  Check every row and column:
    For index : index_range_t Do
        If board[index][0] = box_type
         & board[index][1] = box_type
         & board[index][2] = box_type Then
            Return true;
        Endif;
        If board[0][index] = box_type
         & board[1][index] = box_type
         & board[2][index] = box_type Then
            Return true;
        Endif;
    End;

    --  Check diagonals:
    If board[0][0] = box_type
     & board[1][1] = box_type
     & board[2][2] = box_type Then
        Return true;
    Endif;
    If board[0][2] = box_type
     & board[1][1] = box_type
     & board[2][0] = box_type Then
        Return true;
    Endif;

    Return false;
End;


--  Reports whether the two given boards are equivalent.
Function boards_eq(left, right : board_t) : boolean;
Begin
    For row_index : index_range_t Do
        For col_index : index_range_t Do
            If left[row_index][col_index] != right[row_index][col_index] Then
                Return false;
            Endif;
        End;
    End;
    Return true;
End;


--  Reports whether the given board matches the `ACROSS` pattern.
--      +---+---+---+
--      | X |   |   |
--      +---+---+---+
--      |   |   |   |
--      +---+---+---+
--      |   |   | O |
--      +---+---+---+
Function board_matches_across(board : board_t) : boolean;
Var pattern : board_t;
Begin
    initialize_board(pattern);
    pattern[0][0] := X;
    pattern[2][2] := O;

    Return boards_eq(board, pattern);
End;


--  Reports whether the given board matches the `ARROW` pattern.
--      +---+---+---+   +---+---+---+
--      | X |   |   |   | X |   |   |
--      +---+---+---+   +---+---+---+
--      |   | X | O |   |   | X |   |
--      +---+---+---+   +---+---+---+
--      |   |   | O |   |   | O | O |
--      +---+---+---+   +---+---+---+
Function board_matches_arrow(board : board_t) : boolean;
Var left_pattern : board_t;
Var right_pattern : board_t;
Begin
    initialize_board(left_pattern);
    left_pattern[0][0] := X;
    left_pattern[1][1] := X;
    left_pattern[1][2] := O;
    left_pattern[2][2] := O;

    initialize_board(right_pattern);
    right_pattern[0][0] := X;
    right_pattern[1][1] := X;
    right_pattern[2][1] := O;
    right_pattern[2][2] := O;

    Return boards_eq(board, left_pattern) | boards_eq(board, right_pattern);
End;


--  Reports whether the given board matches the `CENTER` pattern.
--      +---+---+---+
--      | X |   |   |
--      +---+---+---+
--      |   | O |   |
--      +---+---+---+
--      |   |   |   |
--      +---+---+---+
Function board_matches_center(board : board_t) : boolean;
Var pattern : board_t;
Begin
    initialize_board(pattern);
    pattern[0][0] := X;
    pattern[1][1] := O;

    Return boards_eq(board, pattern);
End;


--  Reports whether the given board matches the `CORNERS` pattern.
--      +---+---+---+
--      | X | O | X |
--      +---+---+---+
--      |   |   |   |
--      +---+---+---+
--      |   |   | O |
--      +---+---+---+
Function board_matches_corners(board : board_t) : boolean;
Var pattern : board_t;
Begin
    initialize_board(pattern);
    pattern[0][0] := X;
    pattern[0][1] := O;
    pattern[0][2] := X;
    pattern[2][2] := O;

    Return boards_eq(board, pattern);
End;


--  Reports whether the given board matches the `CROSS` pattern.
--      +---+---+---+   +---+---+---+
--      | X |   | O |   | X |   |   |
--      +---+---+---+   +---+---+---+
--      |   | O |   |   |   | O |   |
--      +---+---+---+   +---+---+---+
--      |   |   | X |   | O |   | X |
--      +---+---+---+   +---+---+---+
Function board_matches_cross(board : board_t) : boolean;
Var left_pattern : board_t;
Var right_pattern : board_t;
Begin
    initialize_board(left_pattern);
    left_pattern[0][0] := X;
    left_pattern[0][2] := O;
    left_pattern[1][1] := O;
    left_pattern[2][2] := X;

    initialize_board(left_pattern);
    left_pattern[0][0] := X;
    left_pattern[1][1] := O;
    left_pattern[2][0] := O;
    left_pattern[2][2] := X;

    Return boards_eq(board, left_pattern) | boards_eq(board, right_pattern);
End;


--  Reports whether the given board matches the `MIDDLE` pattern.
--      +---+---+---+   +---+---+---+
--      | X | O |   |   | X |   |   |
--      +---+---+---+   +---+---+---+
--      |   |   |   |   | O |   |   |
--      +---+---+---+   +---+---+---+
--      |   |   |   |   |   |   |   |
--      +---+---+---+   +---+---+---+
--
--      +---+---+---+   +---+---+---+
--      | X |   |   |   | X |   |   |
--      +---+---+---+   +---+---+---+
--      |   |   | O |   |   |   |   |
--      +---+---+---+   +---+---+---+
--      |   |   |   |   |   | O |   |
--      +---+---+---+   +---+---+---+
Function board_matches_middle(board : board_t) : boolean;
Var top_left_pattern : board_t;
Var top_right_pattern : board_t;
Var bottom_left_pattern : board_t;
Var bottom_right_pattern : board_t;
Begin
    initialize_board(top_left_pattern);
    top_left_pattern[0][0] := X;
    top_left_pattern[0][1] := O;

    initialize_board(top_right_pattern);
    top_right_pattern[0][0] := X;
    top_right_pattern[1][0] := O;

    initialize_board(bottom_left_pattern);
    bottom_left_pattern[0][0] := X;
    bottom_left_pattern[1][2] := O;

    initialize_board(bottom_right_pattern);
    bottom_right_pattern[0][0] := X;
    bottom_right_pattern[2][1] := O;

    Return boards_eq(board, top_left_pattern)
         | boards_eq(board, top_right_pattern)
         | boards_eq(board, bottom_left_pattern)
         | boards_eq(board, bottom_right_pattern);
End;
        

--  This rule is fired when the board matches the `SEVEN` pattern.
--      +---+---+---+
--      | X | X | O |
--      +---+---+---+
--      | O |   | X |
--      +---+---+---+
--      |   |   | O |
--      +---+---+---+
Function board_matches_seven(board : board_t) : boolean;
Var pattern : board_t;
Begin
    initialize_board(pattern);
    pattern[0][0] := X;
    pattern[0][1] := X;
    pattern[0][2] := O;
    pattern[1][0] := O;
    pattern[1][2] := X;
    pattern[2][2] := O;

    Return boards_eq(board, pattern);
End;


--  Reports whether the given board matches the `SPLIT` pattern.
--      +---+---+---+   +---+---+---+
--      | X | O |   |   | X |   |   |
--      +---+---+---+   +---+---+---+
--      |   | X |   |   | O | X |   |
--      +---+---+---+   +---+---+---+
--      |   |   | O |   |   |   | O |
--      +---+---+---+   +---+---+---+
Function board_matches_split(board : board_t) : boolean;
Var left_pattern : board_t;
Var right_pattern : board_t;
Begin
    initialize_board(left_pattern);
    left_pattern[0][0] := X;
    left_pattern[0][1] := O;
    left_pattern[1][1] := X;
    left_pattern[2][2] := O;

    initialize_board(right_pattern);
    right_pattern[0][0] := X;
    right_pattern[1][0] := O;
    right_pattern[1][1] := X;
    right_pattern[2][2] := O;

    Return boards_eq(board, left_pattern) | boards_eq(board, right_pattern);
End;


--  Reports whether the given board matches the `TOGETHER` pattern.
--      +---+---+---+   +---+---+---+
--      | X |   | 0 |   | X |   |   |
--      +---+---+---+   +---+---+---+
--      |   |   |   |   |   |   |   |
--      +---+---+---+   +---+---+---+
--      |   |   |   |   | 0 |   |   |
--      +---+---+---+   +---+---+---+
Function board_matches_together(board : board_t) : boolean;
Var left_pattern : board_t;
Var right_pattern : board_t;
Begin
    initialize_board(left_pattern);
    left_pattern[0][0] := X;
    left_pattern[0][2] := O;

    initialize_board(right_pattern);
    right_pattern[0][0] := X;
    right_pattern[2][0] := O;

    Return boards_eq(board, left_pattern) | boards_eq(board, right_pattern);
End;



--------------
--  Rules:  --
--------------


--  Start state:
----------------

Ruleset INDEX : index_range_t Do
    Startstate
        --  Initialize all boxes to empty.
        initialize_board(board);

        --  Player 1 ('X') goes first.
        turn := 1;
    Endstartstate;
Endruleset;

--  Here, we define all the rules as transitions from one state to the next.
--  Player 1's rules are accompanied with ASCII charts of the tic-tac-toe board.
--
--  Key:
--    - '-': the square may be anything.
--    - ' ': the square must be empty.
--    - 'O': the square must have an 'O' in it.
--    - 'X': the square must have an 'X' in it.
--    - '#': this is the square that will be filled.

Ruleset row_index : index_range_t Do
    Ruleset col_index : index_range_t Do

        --  Asserts that Player 2 never wins.
        Invariant "Player 2 wins"
        !three_in_a_row(board, O);

        --  Resets the board and starts a new game.
        Rule "Full board"
        all_full(board)
        ==>
        Begin
        initialize_board(board);
        turn := 1;
        Endrule;


        --  Player 2:
        -------------

        --  Player 2 is the adversary, and can place an 'O' in any free square.
        --  For every row and every column, if that square is empty,
        --  Player 2 can go there.
        Rule "O"
        board[row_index][col_index] = EMPTY & turn = 2
        ==>
        Begin
        board[row_index][col_index] := O;
        turn := 1;
        Endrule;


        --  Player 1:
        -------------

        --  If Player 1 can win, then win.
        Rule "X: Win"
        turn = 1 & two_in_a_row(board, X)
        & is_blank_of_two(board, X, row_index, col_index)
        ==>
        Begin
        board[row_index][col_index] := X;
        --  Yay! We won.

        --  Reset the board to avoid deadlock.
        initialize_board(board);
        turn := 1;
        Endrule;


        --  If Player 2 has a two-in-a-row, block him.
        Rule "X: Block 2-in-a-row"
        turn = 1 & !two_in_a_row(board, X) & two_in_a_row(board, O)
        & is_blank_of_two(board, O, row_index, col_index)
        ==>
        Begin
        Assert board[row_index][col_index] = EMPTY
            "Overwriting a non-empty square!";
        board[row_index][col_index] := X;
        turn := 2;
        Endrule;


        --  This rule is fired when the board is empty
        --  (i.e., it's the first move of the game).
        --      +---+---+---+
        --      | # |   |   |
        --      +---+---+---+
        --      |   |   |   |
        --      +---+---+---+
        --      |   |   |   |
        --      +---+---+---+
        Rule "X: First move"
        turn = 1 & all_free(board)
        ==>
        Begin
        Assert board[0][0] = EMPTY "Overwriting a non-empty square!";
        board[0][0] := X;
        turn := 2;
        Endrule;


        --  This rule is fired when the board matches the `ACROSS` pattern.
        --      +---+---+---+
        --      | X | # |   |
        --      +---+---+---+
        --      |   |   |   |
        --      +---+---+---+
        --      |   |   | O |
        --      +---+---+---+
        Rule "X: ACROSS"
        turn = 1 & board_matches_across(board)
        ==>
        Begin
        Assert board[0][1] = EMPTY "Overwriting a non-empty square!";
        board[0][1] := X;
        turn := 2;
        Endrule;


        --  This rule is fired when the board matches the `ARROW` pattern.
        --      +---+---+---+   +---+---+---+
        --      | X |   | # |   | X |   |   |
        --      +---+---+---+   +---+---+---+
        --      |   | X | O |   |   | X |   |
        --      +---+---+---+   +---+---+---+
        --      |   |   | O |   | # | O | O |
        --      +---+---+---+   +---+---+---+
        Rule "X: ARROW"
        turn = 1 & board_matches_arrow(board)
        ==>
        Begin
        If board[1][2] = O Then
            --  Left pattern.
            Assert board[0][2] = EMPTY "Overwriting a non-empty square!";
            board[0][2] := X;
        Else
            --  Right pattern.
            Assert board[2][0] = EMPTY "Overwriting a non-empty square!";
            board[2][0] := X;
        Endif;
        turn := 2;
        Endrule;


        --  This rule is fired when the board matches the `CENTER` pattern.
        --      +---+---+---+
        --      | X |   |   |
        --      +---+---+---+
        --      |   | O |   |
        --      +---+---+---+
        --      |   |   | # |
        --      +---+---+---+
        Rule "X: CENTER"
        turn = 1 & board_matches_center(board)
        ==>
        Begin
        Assert board[2][2] = EMPTY "Overwriting a non-empty square!";
        board[2][2] := X;
        turn := 2;
        Endrule;


        --  This rule is fired when the board matches the `CORNERS` pattern.
        --      +---+---+---+
        --      | X | O | X |
        --      +---+---+---+
        --      |   |   |   |
        --      +---+---+---+
        --      | # |   | O |
        --      +---+---+---+
        Rule "X: CORNERS"
        turn = 1 & board_matches_corners(board)
        ==>
        Begin
        Assert board[2][0] = EMPTY "Overwriting a non-empty square!";
        board[2][0] := X;
        turn := 2;
        Endrule;


        --  This rule is fired when the board matches the `MIDDLE` pattern.
        --      +---+---+---+   +---+---+---+
        --      | X | O |   |   | X |   |   |
        --      +---+---+---+   +---+---+---+
        --      |   | # |   |   | O | # |   |
        --      +---+---+---+   +---+---+---+
        --      |   |   |   |   |   |   |   |
        --      +---+---+---+   +---+---+---+
        --
        --      +---+---+---+   +---+---+---+
        --      | X |   |   |   | X |   |   |
        --      +---+---+---+   +---+---+---+
        --      |   | # | O |   |   | # |   |
        --      +---+---+---+   +---+---+---+
        --      |   |   |   |   |   | O |   |
        --      +---+---+---+   +---+---+---+
        Rule "X: MIDDLE"
        turn = 1 & board_matches_middle(board)
        ==>
        Begin
        Assert board[1][1] = EMPTY "Overwriting a non-empty square!";
        board[1][1] := X;
        turn := 2;
        Endrule;


        --  This rule is fired when the board matches the `SEVEN` pattern.
        --      +---+---+---+
        --      | X | X | O |
        --      +---+---+---+
        --      | O | # | X |
        --      +---+---+---+
        --      |   |   | O |
        --      +---+---+---+
        Rule "X: SEVEN"
        turn = 1 & board_matches_seven(board)
        ==>
        Begin
        Assert board[1][1] = EMPTY "Overwriting a non-empty square!";
        board[1][1] := X;
        turn := 2;
        Endrule;


        --  This rule is fired when the board matches the `SPLIT` pattern.
        --      +---+---+---+   +---+---+---+
        --      | X | O |   |   | X |   | # |
        --      +---+---+---+   +---+---+---+
        --      |   | X |   |   | O | X |   |
        --      +---+---+---+   +---+---+---+
        --      | # |   | O |   |   |   | O |
        --      +---+---+---+   +---+---+---+
        Rule "X: SPLIT"
        turn = 1 & board_matches_split(board)
        ==>
        Begin
        If board[0][1] = O Then
            --  Left pattern.
            Assert board[2][0] = EMPTY "Overwriting a non-empty square!";
            board[2][0] := X;
        Else
            --  Right pattern.
            Assert board[0][2] = EMPTY "Overwriting a non-empty square!";
            board[0][2] := X;
        Endif;
        turn := 2;
        Endrule;


        --  This rule is fired when the board matches the `TOGETHER` pattern.
        --      +---+---+---+   +---+---+---+
        --      | X |   | 0 |   | X |   |   |
        --      +---+---+---+   +---+---+---+
        --      |   |   |   |   |   |   |   |
        --      +---+---+---+   +---+---+---+
        --      |   |   | # |   | 0 |   | # |
        --      +---+---+---+   +---+---+---+
        Rule "X: TOGETHER"
        turn = 1 & board_matches_together(board)
        ==>
        Begin
        Assert board[2][2] = EMPTY "Overwriting a non-empty square!";
        board[2][2] := X;
        turn := 2;
        Endrule;

    Endruleset;
Endruleset;
