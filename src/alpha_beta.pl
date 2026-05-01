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
        (Player = attacker -> Score is -RawScore ; Score = RawScore)
    ).

count_pieces(Board, Piece, Count) :-
    findall(1, (
        nth0(_, Board, Row),
        nth0(_, Row, Piece)
    ), List),
    length(List, Count).

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
