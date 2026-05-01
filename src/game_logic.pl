initial_board([
    [e, e, e, a, a, a, e, e, e],
    [e, e, e, e, a, e, e, e, e],
    [e, e, e, e, d, e, e, e, e],
    [a, e, e, e, d, e, e, e, a],
    [a, a, d, d, k, d, d, a, a],
    [a, e, e, e, d, e, e, e, a],
    [e, e, e, e, d, e, e, e, e],
    [e, e, e, e, a, e, e, e, e],
    [e, e, e, a, a, a, e, e, e]
]).

path_is_clear(Board, R, C1, R, C2) :-
    MinC is min(C1, C2) + 1, MaxC is max(C1, C2) - 1,
    forall(between(MinC, MaxC, C), (nth0(R, Board, Row), nth0(C, Row, e))).

path_is_clear(Board, R1, C, R2, C) :-
    MinR is min(R1, R2) + 1, MaxR is max(R1, R2) - 1,
    forall(between(MinR, MaxR, R), (nth0(R, Board, Row), nth0(C, Row, e))).

is_valid_move(Board, R1, C1, R2, C2) :-
    nth0(R1, Board, Row1), nth0(C1, Row1, Piece), Piece \= e,
    nth0(R2, Board, Row2), nth0(C2, Row2, e),
    (R1 = R2 ; C1 = C2),
    path_is_clear(Board, R1, C1, R2, C2).

move_piece(Board, R1, C1, R2, C2, NewBoard) :-
    is_valid_move(Board, R1, C1, R2, C2),
    nth0(R1, Board, R1Row), nth0(C1, R1Row, Piece),
    replace_in_board(Board, R1, C1, e, TempBoard),
    replace_in_board(TempBoard, R2, C2, Piece, NewBoard).

replace_in_board(Board, R, C, NewElem, NewBoard) :-
    nth0(R, Board, OldRow, RestRows),
    nth0(C, OldRow, _, RestElems),
    nth0(C, NewRow, NewElem, RestElems),
    nth0(R, NewBoard, NewRow, RestRows).