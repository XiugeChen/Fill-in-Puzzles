:- ensure_loaded(library(clpfd)).

puzzle_solution(Puzzle, WordList) :-
    gen_var_list(Puzzle, VarLists),
    unify_list(VarLists, WordList).

% 
gen_var_list(Puzzle, VarLists) :-
    traverse(Puzzle, Front),
    transpose(Puzzle, PuzzleT),
    traverse(PuzzleT, Back),
    append(Front, Back, VarLists).

% 
traverse([], []).
traverse([Row|Puzzle], List) :-
    row_traverse(Row, Front),
    traverse(Puzzle, Back),
    append(Front, Back, List).

% 
row_traverse([], []).
row_traverse([Elem|Row], List) :-
    partition([Elem|Row], #, Prefix, Suffix),
    length(Prefix, N),
    (   N > 1
    ->  List = [Prefix|Rest]
    ;   List = Rest
    ),
    row_traverse(Suffix, Rest).
    
% 
partition([], _, [], []).
partition([X|Xs], Elem, Prefix, Suffix) :-
    (   X == Elem
    ->  Suffix = Xs,
        (   var(Prefix)
        ->  Prefix = []
        )
    ;   Prefix = [X|Rest],
        partition(Xs, Elem, Rest, Suffix)
    ).

% 
filter(_, [], []).
filter(Goal, [X|Xs], NewList) :-
    ( call(Goal, X)
    -> NewList = [X|Rest]
    ; NewList = Rest
    ),
    filter(Goal, Xs, Rest).

% 
longer_than_one(List) :- 
    length(List, N),
    N > 1. 

% 
unify_list(_, []).
unify_list([Var|VarList], WordList) :-
    sort_by_match([Var|VarList], WordList, [SVar|SVarList], Len),
    length(WordList, N),
    Len >= N,
    unify(SVar, WordList),
    select(SVar, WordList, NewWordList),
    unify_list(SVarList, NewWordList).

%
unify(Var, [Word|WordList]) :-
    Var = Word ;
    unify(Var, WordList).

% 
sort_by_match(VarLists, WordList, SortVarLists, Len) :-
    calculate_match(VarLists, WordList, MatchLists, Len),
    keysort(MatchLists, SortMatchLists),
    remove_key(SortMatchLists, SortVarLists).

% 
calculate_match([], _, [], 0).
calculate_match([V|VarLists], WordLists, [C-M|MatchLists], Len) :-
    calculate_match(VarLists, WordLists, MatchLists, Len1),
    count_match(V, WordLists, 0, C-M), 
    (   C < 99
    ->  Len is Len1 + 1
    ;   Len is Len1
    ).

% 
count_match(VarList, [], Count, Count1-VarList) :-
    (   Count == 0
    ->  Count1 = 99
    ;   Count1 = Count
    ).
count_match(VarList, [Word|WordList], Count, Match) :-
    (   unifiable(VarList, Word, _)
    ->  Count1 is Count + 1,
        count_match(VarList, WordList, Count1, Match)
    ;   count_match(VarList, WordList, Count, Match)
    ).

% 
remove_key([], []).
remove_key([_-Y|Xs], [Y|Ys]) :-
    remove_key(Xs, Ys).