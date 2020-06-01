# Fill-in Puzzles

## Introduction

* Project 2 for [COMP90048](https://handbook.unimelb.edu.au/2020/subjects/comp90048) (Declarative Programming) at the University of Melbourne, 2020 Sem1.

* A fill-in puzzle (sometimes called a fill-it-in) is like a crossword puzzle, except that instead of being given obscure clues telling us which words go where, you are given a list of all the words to place in the puzzle, but not told where they go.

* The puzzle consists of a grid of squares, most of which are empty, into which letters or digits are to be written, but some of which are filled in solid, and are not to be written in.

* A list of words to place in the puzzle is also given.
    
* The program must try to solve the puzzles. It will place each word in the word list exactly once in the puzzle, either left-to-right or top-to-bottom, filling a maximal sequence of empty squares. Also, every maximal sequence of non-solid squares that is more than one square long must have one word from the word list written in it. Many words cross one another, so many of the letters in a horizontal word will also be a letter in a vertical word.

* The program will firstly generate a list of slots SlotList (a slot is a maximal sequences of variables that is more than one square long) from Puzzle, then try to unify SlotList with the WordList, such that after unification, WordList is a subset of SlotList, and all the remaining slots in SlotList are grounded. If succeed, corresponding variables in Puzzle will be bounded with the solution.

* For detailed description please check out [project specification](docs/specification.pdf)

## Contribution
Xiuge Chen

xiugec@student.unimelb.edu.au

Subject: COMP90048 Declarative Programming

University of Melbourne