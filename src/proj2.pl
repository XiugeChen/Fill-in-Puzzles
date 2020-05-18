% Author:         Xiuge Chen <xiugec@student.unimelb.edu.au>
% Created on: 2020.05.15
% Last Modified on: 2020.05.18
%
% The puzzle consists of a grid of squares, most of which are empty 
% (represents in prolog as unbounded variables), into which letters or digits 
% are to be written, but some of which are filled in solid, and are not to be 
% written in (represents in prolog as the atom '#').
% For example, below is a 3*3 puzzle with all corners being solid.
% Puzzle = [[#, _, #], 
%           [_, _, _], 
%           [#, _, #]].
% 
% A grounded proper list of words to place in the puzzle is given, ex:
% WordList = [[h, a, t], [c, a, t]].
%
% The program need to solve the puzzles. It will place each word in the word 
% list exactly once in the puzzle, either left-to-right or top-to-bottom, 
% filling a maximal sequence of empty squares. Also, every maximal sequence 
% of non-solid squares that is more than one square long must have one word 
% written in it.
%
% The program will firstly generate a list of slots SlotList (a slot is a 
% maximal sequences of variables that is more than one square long) from 
% Puzzle, like:
%       SlotList = [[A,B,C], [X,B,Z]].
% then it will try to unify SlotList with the WordList, such that after 
% unification, WordList is a subset of SlotList, and all the remaining slots
% in SlotList are grounded. If succeed, corresponding variables in Puzzle 
% will be bounded with the solution. 

% ensure the program load the correct library for matrix transpose
:- ensure_loaded(library(clpfd)).

% Usage: puzzle_solution(+Puzzle, +WordList)
%
% Given a Puzzle (a proper list of proper list of sqaures, each sqaure is 
% either a unbounded variable or a atom '#'), and a WordList(a ground proper 
% list of words, each word is a list of atom characters).
%
% puzzle_solution will firstly generate a list of slots SlotList (a slot is a 
% maximal sequences of variables that is more than one square long) from 
% Puzzle, then try to unify SlotList with the WordList, such that after 
% unification, WordList is a subset of SlotList, and all the remaining slots
% in SlotList are grounded. If succeed, corresponding variables in Puzzle 
% will be bounded.
puzzle_solution(Puzzle, WordList) :-
    gen_slot_list(Puzzle, SlotList),
    unify_slot_list(SlotList, [], WordList).

% Usage: gen_slot_list(+Puzzle, -SlotList)
%
% Given a Puzzle (a proper list of proper list of sqaures, each sqaure is 
% either a unbounded variable or a atom '#').
%
% Output a list of all slots in Puzzle, where each slot is a maximal sequences
% of variables in Puzzle that is more than one square long. Slots will firstly
% be traversed row-wised from left to right, then be traversed column-wised
% from top to bottom.
gen_slot_list(Puzzle, SlotList) :-
    traverse_puzzle(Puzzle, RowTrav),
    transpose(Puzzle, PuzzleT),
    traverse_puzzle(PuzzleT, ColTrav),
    append(RowTrav, ColTrav, SlotList).

% Usage: traverse_puzzle(+Puzzle, -SlotList)
%
% Given a Puzzle (a proper list of proper list of sqaures, each sqaure is 
% either a unbounded variable or a atom '#')
% 
% Output a list of slots in Puzzle, traversed row by row from left to right, 
% where each slot is a maximal sequences of variables in Puzzle that is more 
% than one square long. 
traverse_puzzle([], []).
traverse_puzzle([Row|Puzzle], SlotList) :-
    traverse_row(Row, CurrtTrav),
    traverse_puzzle(Puzzle, RestTrav),
    append(CurrtTrav, RestTrav, SlotList).

% Usage: traverse_row(+Row, -SlotList)
%
% Given a Row in Puzzle (a proper list of sqaures, each sqaure is either a 
% unbounded variable or a atom '#').
% 
% Output a list of slots in Row, traversed from left to right, where each slot
% is a maximal sequences of variables in Row that is more than one square long
traverse_row([], []).
traverse_row([Elem|Row], SlotList) :-
    partition([Elem|Row], #, Slot, RemainRow),
    length(Slot, N),
    (   N > 1  % only output slots with length greater than 1
    ->  SlotList = [Slot|RemainSlotList]
    ;   SlotList = RemainSlotList
    ),
    traverse_row(RemainRow, RemainSlotList).
    
% Usage: partition(+List, +Element, -Prefix, -Suffix)
% 
% Given a proper List and a bounded element Elem.
%
% Find the first occurence of Elem in List (could be just a atom, or 
% variable bounded to Elem), output the Prefix as a list of elements in List
% before Elem, Suffix as a list of elements in List after Elem. Prefix will
% be [] if the first occurence of Elem is the first element in List, Suffix
% will be [] if the first occurence of Elem is the last element in List,
% or there is no such element Elem in List.
partition([], _, [], []).
partition([X|Xs], Elem, Prefix, Suffix) :-
    (   X == Elem
    ->  Suffix = Xs,
        (   var(Prefix) % initizlize prefix to be [] if prefix is unbounded
        ->  Prefix = []
        )
    ;   Prefix = [X|Rest],
        partition(Xs, Elem, Rest, Suffix)
    ).

% Usage: unify_slot_list(+SlotList, +NonMatchList, +WordList)
%
% Given a SlotList (a proper list of proper list of sqaures, each sqaure is 
% a variable), and a WordList (a ground proper list of words, each word is a
% list of atom characters).
% 
% Unify the slots in SlotList by the words in WordList sequentially. Firstly,
% it will get the slot that is unifiable with some words and has the smallest
% number of unifiable words. Slots that are not unifiable will be put into
% NonMatchList. Then it will unify that slot with the corresponding words, 
% remove both the slot and the word from the list, repeat until all words in 
% WordList are being unified with some slots. At the end, the PreNonMatch 
% should be grounded.
unify_slot_list([], NonMatchList, []) :-
    ground(NonMatchList).
unify_slot_list([S|SlotList], PreNonMatch, WordList) :-
    sort_by_match([S|SlotList], WordList, [Slot|SortSlotList], NewNonMatch),
    % the number of unifibale slots is less than the number of words 
    % imples no solution is possible
    longer_or_equal([Slot|SortSlotList], WordList), 
    unify_slot(Slot, WordList),
    select(Slot, WordList, NewWordList),
    append(PreNonMatch, NewNonMatch, NonMatchList),
    unify_slot_list(SortSlotList, NonMatchList, NewWordList).

% Usage: longer_or_equal(+List1, +List2)
%
% Given two proper lists List1 and List2
%
% True if the length of List1 is greater or equal than the length of List2.
longer_or_equal(List1, List2) :-
    length(List1, N1),
    length(List2, N2),
    N1 >= N2.

% Usage: unify_slot(+Slot, +WordList) :-
%
% Given a WordList(a ground proper list of words, each word is a list of atom
% characters), and a Slot (a proper list of of variables)
% 
% Unify the Slot with the first unifiable word in WordList.
% Fail if no word in WordList could be unified with Slot
unify_slot(Slot, [Word|WordList]) :-
    Slot = Word ;
    unify_slot(Slot, WordList).

% Usage: sort_by_match(+SlotList, +WordList, -SortSlotList, -NonMatchList)
%
% Given a SlotList (a proper list of proper list of variables), and a WordList
% (a ground proper list of words, each word is a list of atom characters).
%
% MatchList will contain all slots that are unifiable with some words in 
% WordList, ordered ascendingly by the number of unifiable words.
% NonMatchList is just a list that contain all slots that has no words
% unifiable in WordList. 
sort_by_match(SlotList, WordList, SortSlotList, NonMatchList) :-
    gen_slots_match(SlotList, WordList, MatchList, NonMatchList),
    keysort(MatchList, SortMatchList),
    remove_key(SortMatchList, SortSlotList).

% Usage: gen_slots_match(+SlotList, +WordList, -MatchList, -NonMatchList)
% 
% Given a SlotList (a proper list of proper list of variables), and a WordList
% (a ground proper list of words, each word is a list of atom characters).
%
% Generate a MatchList for SlotList, where each match in MatchList is a 
% key-value pair, such that the value is a slot in SlotList, and key is the
% number of words in WordList that are unifiable with this slot, all keys
% in MatchList should be greater than 0.
% NonMatchList is just a list that contain all slots that has no words
% unifiable in WordList. 
gen_slots_match([], _, [], []).
gen_slots_match([Slot|SlotList], WordList, MatchList, NonMatchList) :-
    count_slot_match(Slot, WordList, 0, C-M), 
    (   C == 0  % if the slot is not unifiable, put it in NonMatchList
    ->  MatchList = RestMatchList,
        NonMatchList = [M|RestNonMatchList]
    ;   MatchList = [C-M|RestMatchList],
        NonMatchList = RestNonMatchList
    ),
    gen_slots_match(SlotList, WordList, RestMatchList, RestNonMatchList).

% Usage: count_slot_match(+Slot, +WordList, +Count, -Match)
%
% Given a Slot (a proper list of variables), a WordList (a ground proper list
% of words, each word is a list of atom characters), and a grounded inital 
% Count (a number).
%
% Output a Match (key-value), where the value is the input Slot and the
% key is Count plus the number of words that are unifiable with the Slot.
count_slot_match(Slot, [], Count, Count-Slot).
count_slot_match(Slot, [Word|WordList], Count, Match) :-
    (   unifiable(Slot, Word, _) 
    ->  Count1 is Count + 1, % increment count by one if unifiable
        count_slot_match(Slot, WordList, Count1, Match)
    ;   count_slot_match(Slot, WordList, Count, Match)
    ).

% Usage: remove_key(+KeyList, -List)
%
% Given a proper list (KeyList) of key-value matches
% 
% Remove the key part for all. Both order and duplicate will be preserved.
remove_key([], []).
remove_key([_-Y|Xs], [Y|Ys]) :-
    remove_key(Xs, Ys).