% Author:         Xiuge Chen <xiugec@student.unimelb.edu.au>
% Created on: 2020.05.15
% Last Modified on: 2020.05.15

% ensure the program load the correct library for matrix transpose
:- ensure_loaded(library(clpfd)).

puzzle_solution(Puzzle, WordList).

%
insert_word(Matrix, Word) :-
    insert_to_matrix(Matrix, Word) ;
    (   transpose(Matrix, MatrixT),
        insert_to_matrix(MatrixT, Word),
        transpose(MatrixT, Matrix)
    ).

%
insert_to_matrix([Row|Matrix], Word) :-
    insert_to_row(Row, Word) ;
    insert_to_matrix(Matrix, Word).

% 
insert_to_row([], []).
insert_to_row([R|Rs], []) :-
    ( R == #
    -> insert_to_row(Rs, [])
    ).
insert_to_row([R|Rs], [W|Ws]) :-
    (   R == #
    ->  insert_to_row(Rs, [W|Ws])
    ;   R = W
    ->  insert_to_row(Rs, Ws)
    ).