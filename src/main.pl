play :-
    initial_board(Board),
    write('Choose your side (attacker/defender): '),
    read(HumanSide),
    game_loop(Board, attacker, HumanSide).

game_loop(Board, Curr_player, HumanSide) :-
    print_board(Board),
    (defenders_win(Board) -> 
        write('Defenders Win!') ;
    attackers_win(Board) -> 
        write('Attackers Win!') ;
    take_turn(Board, Curr_player, HumanSide, NewBoard),
    switch_player(Curr_player, Next_player),
    game_loop(NewBoard, Next_player, HumanSide)).

switch_player(attacker, defender).
switch_player(defender, attacker).

take_turn(Board, Curr_player, Curr_player, NewBoard) :-
    write(' please enter Your move (R1-C1-R2-C2): '),
    read(R1-C1-R2-C2),
    move_piece(Board, R1, C1, R2, C2, TempBoard),
    nth0(R2, TempBoard, Row),
    nth0(C2, Row, Moved_Piece),
    capture_if_sandwiched(TempBoard, R2, C2, Moved_Piece, NewBoard).

take_turn(Board, Curr_player, HumanSide, NewBoard) :- %ai_turn
