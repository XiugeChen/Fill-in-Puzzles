% Author:         Xiuge Chen <xiugec@student.unimelb.edu.au>
% Created on: 2020.05.15
% Last Modified on: 2020.05.15

% ensure the program load the correct library for matrix transpose
:- ensure_loaded(library(clpfd)).

puzzle_solution(Puzzle, WordList) :-
    sort_by_len_occur(WordList, WordList1),
    insert(Puzzle, WordList1).

% 
sort_by_len_occur(Lst, SortGpLst) :-
    sort_by_len(Lst, SortLst),
    group_pairs_by_key(SortLst, GpLst),
    remove_key(GpLst, GpLst1), 
    sort_by_len(GpLst1, SortGpLst0),
    remove_key(SortGpLst0, SortGpLst1),
    down_dim(SortGpLst1, SortGpLst).

% 
sort_by_len(Lst, SortLst) :-
    gen_len_key(Lst, LstLen),
    keysort(LstLen, SortLst).

%
gen_len_key([], []).
gen_len_key([X|Xs], [Y|Ys]) :-
    length(X, Len),
    Y = Len-X,
    gen_len_key(Xs, Ys).

% 
remove_key([], []).
remove_key([_-Y|Xs], [Y|Ys]) :-
    remove_key(Xs, Ys).

%
down_dim([], []).
down_dim([[]|Xss], Ys) :-
    down_dim(Xss, Ys).
down_dim([[X|Xs]|Xss], [X|Ys]) :-
    down_dim([Xs|Xss], Ys).

% 
insert(_, []).
insert(Matrix, [Word|Words]) :-
    insert_word(Matrix, Word),
    insert(Matrix, Words).

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
insert_to_row(Row, Word) :-
        Word = Row
    ;
    (   append(Word, [X|_], Row), 
        X == # )
    ;
    (   append(Lst, Word, Row),
        append(_, [X], Lst),
        X == # )
    ;
    (   append(Front, [X|_], Row),
        X == #,
        append(Lst, Word, Front),
        append(_, [Y], Lst),
        Y == #
    )
    .