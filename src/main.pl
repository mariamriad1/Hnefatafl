start_game :-
    initial_board(Board),
    write(' user please Choose your side (attacker/defender): '),
    read(Human_role),
    write('please Choose difficulty of ai  (easy/medium/hard): '),
    read(Difficulty),
    play_loop(Board, attacker, Human_role,Difficulty).

play_loop(Board, Curr_player, Human_role,Difficulty) :-
    show_board(Board),
    (defenders_win(Board) ->  write('Defenders Win') ;

    attackers_win(Board) ->  write('Attackers Win') ;
    take_turn(Board, Curr_player, Human_role,Difficulty, NewBoard),
    switch_player(Curr_player, Next_player),
    play_loop(NewBoard, Next_player, Human_role,Difficulty)).

switch_player(attacker, defender).
switch_player(defender, attacker).

take_turn(Board, Curr_player, Curr_player,_, NewBoard) :-
    write('please enter your move (R1-C1-R2-C2): '),
    read(R1-C1-R2-C2),
      nth0(R1, Board, Row),
    nth0(C1, Row, Piece),
    (Curr_player = attacker -> Piece = a ;(Piece = d ; Piece = k) ),
    move_piece(Board, R1, C1, R2, C2, NewBoard).
  

take_turn(Board, Curr_player, Human_role,Difficulty, NewBoard) :-
    Curr_player \= Human_role,
    get_best_move(Board, Difficulty,Curr_player, move(R1,C1,R2,C2)),
    move_piece(Board, R1, C1, R2, C2,NewBoard),
format('ai played : ~w-~w-~w-~w~n', [R1,C1,R2,C2]).
