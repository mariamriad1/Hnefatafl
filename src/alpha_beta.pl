within_board(R, C) :- R >= 0, R =< 8, C >= 0, C =< 8.

directions([(0,1),(0,-1),(1,0),(-1,0)]).

throne(4,4).

game_over(Board, defender_wins) :- defenders_win(Board).
game_over(Board, attacker_wins) :- attackers_win(Board).
utility(Board, Player, Score) :-
    (   game_over(Board, defender_wins)
    ->  (Player = defender -> Score = 10000 ; Score = -10000)
    ;   game_over(Board, attacker_wins)
    ->  (Player = attacker -> Score = 10000 ; Score = -10000)
    ;   count_pieces(Board, d, Defenders),
        count_pieces(Board, a, Attackers),
        find_king(Board, KR, KC),
        king_distance_score(KR, KC, DistScore),
        king_danger_score(Board, KR, KC, DangerScore),
        king_mobility_score(Board, KR, KC, MobilityScore),
        RawScore is (Defenders * 10)
                  - (Attackers * 5)
                  + DistScore
                  - DangerScore
                  + MobilityScore,
        (Player = attacker -> Score is -RawScore ; Score is RawScore)
    ).

count_pieces(Board, Piece, Count) :-
    findall(1, (
        nth0(_, Board, Row),
        nth0(_, Row, Piece)
    ), List),
    length(List, Count).

find_king(Board, R, C) :-
    nth0(R, Board, Row),
    nth0(C, Row, k).

king_distance_score(KR, KC, Score) :-
    corners(Corners),
    findall(Dist, (
        member(corner(CR, CC), Corners),
        Dist is abs(KR - CR) + abs(KC - CC)
    ), Dists),
    min_list(Dists, MinDist),
    Score is (16 - MinDist) * 15.

king_danger_score(Board, KR, KC, Score) :-
    directions(Dirs),
    findall(1, (
        member((DR, DC), Dirs),
        NR is KR + DR,
        NC is KC + DC,
        within_board(NR, NC),
        nth0(NR, Board, Row),
        nth0(NC, Row, a)
    ), Dangers),
    length(Dangers, DangerCount),
    Score is DangerCount * 20.

king_mobility_score(Board, KR, KC, Score) :-
    findall(1, (
        between(0, 8, R2),
        between(0, 8, C2),
        is_valid_move(Board, KR, KC, R2, C2)
    ), Moves),
    length(Moves, MoveCount),
    Score is MoveCount * 8.

difficulty(easy, 1).
difficulty(medium, 3).
difficulty(hard, 5).

get_best_move(Board, Difficulty, attacker, BestMove) :-
    difficulty(Difficulty, Depth),
    findall(move(R1,C1,R2,C2), (
        nth0(R1, Board, Row), nth0(C1, Row, a),
        is_valid_move(Board, R1, C1, R2, C2)), Moves),
    Moves \= [],
    findall(V-M, (
        member(M, Moves), M = move(R1,C1,R2,C2),
        move_piece(Board, R1, C1, R2, C2, NB),
        alphabeta(NB, Depth, -10001, 10001, defender, V)
    ), Scored),
    max_member(_-BestMove, Scored).

get_best_move(Board, Difficulty, defender, BestMove) :-
    difficulty(Difficulty, Depth),
    findall(move(R1,C1,R2,C2), (
        nth0(R1, Board, Row), nth0(C1, Row, P), (P=d ; P=k),
        is_valid_move(Board, R1, C1, R2, C2)), Moves),
    Moves \= [],
    findall(V-M, (
        member(M, Moves), M = move(R1,C1,R2,C2),
        move_piece(Board, R1, C1, R2, C2, NB),
        alphabeta(NB, Depth, -10001, 10001, attacker, V)
    ), Scored),
    min_member(_-BestMove, Scored).

alphabeta(Board, 0, _A, _B, _Player, Value) :- !,
    utility(Board, attacker, Value).

alphabeta(Board, _D, _A, _B, _Player, Value) :-
    (   defenders_win(Board) -> Value = -10000
    ;   attackers_win(Board) -> Value = 10000
    ), !.

alphabeta(Board, D, A, B, attacker, Value) :-
    D > 0,
    findall(move(R1,C1,R2,C2), (
        nth0(R1, Board, Row), nth0(C1, Row, a),
        is_valid_move(Board, R1, C1, R2, C2)), Moves),
    (   Moves = []
    ->  Value = -10000
    ;   D1 is D-1,
        ab_max(Moves, Board, D1, A, B, Value)
    ).

alphabeta(Board, D, A, B, defender, Value) :-
    D > 0,
    findall(move(R1,C1,R2,C2), (
        nth0(R1, Board, Row), nth0(C1, Row, P), (P=d ; P=k),
        is_valid_move(Board, R1, C1, R2, C2)), Moves),
    (   Moves = []
    ->  Value = 10000
    ;   D1 is D-1,
        ab_min(Moves, Board, D1, A, B, Value)
    ).

ab_max([], _, _, A, _, A).
ab_max([move(R1,C1,R2,C2)|Rest], Board, D, A, B, Value) :-
    move_piece(Board, R1, C1, R2, C2, NB),
    alphabeta(NB, D, A, B, defender, V),
    NA is max(A, V),
    (   NA >= B
    ->  Value = NA
    ;   ab_max(Rest, Board, D, NA, B, Value)
    ).

ab_min([], _, _, _, B, B).
ab_min([move(R1,C1,R2,C2)|Rest], Board, D, A, B, Value) :-
    move_piece(Board, R1, C1, R2, C2, NB),
    alphabeta(NB, D, A, B, attacker, V),
    NB2 is min(B, V),
    (   A >= NB2
    ->  Value = NB2
    ;   ab_min(Rest, Board, D, A, NB2, Value)
    ).
