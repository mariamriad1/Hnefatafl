throne(4, 4).
throne_cell(4, 4).
corner(0, 0). 
corner(0, 8). 
corner(8, 0). 
corner(8, 8).
special_cell(R, C) :- corner(R, C).

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
    path_is_clear(Board, R1, C1, R2, C2),
    ( (special_cell(R2, C2) ; throne_cell(R2, C2)) -> Piece = k ; true ).

move_piece(Board, R1, C1, R2, C2, FinalBoard) :-
    is_valid_move(Board, R1, C1, R2, C2),
    nth0(R1, Board, R1Row), nth0(C1, R1Row, Piece),
    replace_in_board(Board, R1, C1, e, TempBoard),
    replace_in_board(TempBoard, R2, C2, Piece, BoardAfterMove),
    capture_if_sandwiched(BoardAfterMove, R2, C2, Piece, FinalBoard).

replace_in_board(Board, R, C, NewElem, NewBoard) :-
    nth0(R, Board, OldRow, RestRows),
    nth0(C, OldRow, _, RestElems),
    nth0(C, NewRow, NewElem, RestElems),
    nth0(R, NewBoard, NewRow, RestRows).

opponent(a, d).
opponent(a, k).
opponent(d, a).



is_dangerous_cell(Board, R, C, _) :-
    throne(R, C),  nth0(R, Board, Row), nth0(C, Row, e).

is_dangerous_cell(Board, R, C, _) :-
    corner(R, C),  nth0(R, Board, Row), nth0(C, Row, e).

is_dangerous_cell(Board, R, C, Piece) :-
    nth0(R, Board, Row),
    nth0(C, Row, Other),
    Other \= e,
    opponent(Other, Piece).

is_sandwiched(Board, R, C, Piece) :-
    C1 is C-1, C2 is C+1,
    is_dangerous_cell(Board, R, C1, Piece),
    is_dangerous_cell(Board, R, C2, Piece).

is_sandwiched(Board, R, C, Piece) :-
    R1 is R-1, R2 is R+1,
    is_dangerous_cell(Board, R1, C, Piece),
    is_dangerous_cell(Board, R2, C, Piece).




neighbor(R, C, R, C2):-C2 is C+1.
neighbor(R, C, R, C2):-C2 is C-1.
neighbor(R, C, R2, C):-R2 is R+1.
neighbor(R, C, R2, C):-R2 is R-1.




capture_if_sandwiched(Board, R, C, Piece, FinalBoard) :-
    (Piece \= k, is_sandwiched(Board, R, C, Piece) ->
        remove_captured(Board, [R-C], TempBoard2)
    ;
        TempBoard2 = Board
    ),
    findall(R2-C2, (
        neighbor(R, C, R2, C2),
        nth0(R2, TempBoard2, Row),
        nth0(C2, Row, Target),
        Target \= e,
        Target \= k,
        opponent(Piece, Target),
        is_sandwiched(TempBoard2, R2, C2, Target)
    ), Captured),
    remove_captured(TempBoard2, Captured, FinalBoard).

remove_captured(Board, [], Board).
remove_captured(Board, [R-C|Rest], FinalBoard) :-
    replace_in_board(Board, R, C, e, TempBoard),
    remove_captured(TempBoard, Rest, FinalBoard).




defenders_win(Board) :-
    corner(R, C),
    nth0(R, Board, Row),
    nth0(C, Row, k).

attackers_win(Board) :-
    search_king(Board, R, C),
    check_king_surrounded(Board, R, C).

search_king(Board, R, C) :-
    nth0(R, Board, Row),
    nth0(C, Row, k).

check_king_surrounded(Board, R, C) :-
    R1 is R-1, R2 is R+1,
    C1 is C-1, C2 is C+1,
    (R1 < 0 -> true ; is_attack(Board,R1,C)),
    (R2 > 8 -> true ; is_attack(Board, R2, C)),
    (C1 < 0 -> true ; is_attack(Board, R, C1)),
    (C2 > 8 -> true ; is_attack(Board, R, C2)).

is_attack(B,R,C):-
 nth0(R,B,ROW),
 nth0(C,ROW,a).



show_board([]).
show_board([Row|Rest]) :-show_row(Row), nl,
 show_board(Rest).

show_row([]).
show_row([Cell|Rest]) :-
write(Cell), write(' '),show_row(Rest).






