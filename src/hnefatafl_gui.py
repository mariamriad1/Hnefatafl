import tkinter as tk
from tkinter import ttk, messagebox

BOARD_SIZE = 9

initial_board = [
    ["e", "e", "e", "a", "a", "a", "e", "e", "e"],
    ["e", "e", "e", "e", "a", "e", "e", "e", "e"],
    ["e", "e", "e", "e", "d", "e", "e", "e", "e"],
    ["a", "e", "e", "e", "d", "e", "e", "e", "a"],
    ["a", "a", "d", "d", "k", "d", "d", "a", "a"],
    ["a", "e", "e", "e", "d", "e", "e", "e", "a"],
    ["e", "e", "e", "e", "d", "e", "e", "e", "e"],
    ["e", "e", "e", "e", "a", "e", "e", "e", "e"],
    ["e", "e", "e", "a", "a", "a", "e", "e", "e"]
]

board = []
buttons = []
selected = None
human_side = "defender"
ai_side = "attacker"
current_turn = "attacker"


def reset_board():
    global board
    board = [row[:] for row in initial_board]


def piece_belongs_to_player(piece, player):
    if player == "attacker":
        return piece == "a"
    return piece == "d" or piece == "k"


def is_clear_path(r1, c1, r2, c2):
    if r1 != r2 and c1 != c2:
        return False

    if r1 == r2:
        step = 1 if c2 > c1 else -1
        for c in range(c1 + step, c2, step):
            if board[r1][c] != "e":
                return False

    if c1 == c2:
        step = 1 if r2 > r1 else -1
        for r in range(r1 + step, r2, step):
            if board[r][c1] != "e":
                return False

    return board[r2][c2] == "e"


def is_valid_move(r1, c1, r2, c2, player):
    if not (0 <= r1 < 9 and 0 <= c1 < 9 and 0 <= r2 < 9 and 0 <= c2 < 9):
        return False

    piece = board[r1][c1]

    if not piece_belongs_to_player(piece, player):
        return False

    if piece == "e":
        return False

    return is_clear_path(r1, c1, r2, c2)


def update_gui():
    for r in range(BOARD_SIZE):
        for c in range(BOARD_SIZE):
            piece = board[r][c]

            if piece == "a":
                buttons[r][c].config(text="A", bg="#222222", fg="white")
            elif piece == "d":
                buttons[r][c].config(text="D", bg="#f2f2f2", fg="black")
            elif piece == "k":
                buttons[r][c].config(text="K", bg="#d4af37", fg="black")
            else:
                buttons[r][c].config(text="", bg="#8fbc8f", fg="black")

    turn_label.config(text=f"Current Turn: {current_turn}")
    info_label.config(
        text=f"Human: {human_side} | Computer: {ai_side} | Difficulty: {difficulty_var.get()}"
    )


def switch_turn():
    global current_turn
    current_turn = "defender" if current_turn == "attacker" else "attacker"


def get_all_ai_moves():
    moves = []
    for r1 in range(9):
        for c1 in range(9):
            if piece_belongs_to_player(board[r1][c1], ai_side):
                for r2 in range(9):
                    for c2 in range(9):
                        if is_valid_move(r1, c1, r2, c2, ai_side):
                            moves.append((r1, c1, r2, c2))
    return moves


def ai_play():
    global current_turn

    moves = get_all_ai_moves()

    if not moves:
        messagebox.showinfo("Game Over", "Computer has no valid moves.")
        return

    r1, c1, r2, c2 = moves[0]

    board[r2][c2] = board[r1][c1]
    board[r1][c1] = "e"

    messagebox.showinfo("AI Move", f"AI played: {r1}-{c1}-{r2}-{c2}")

    switch_turn()
    update_gui()


def cell_clicked(r, c):
    global selected, current_turn

    if current_turn != human_side:
        messagebox.showwarning("Wait", "It is computer turn.")
        return

    if selected is None:
        if piece_belongs_to_player(board[r][c], human_side):
            selected = (r, c)
            buttons[r][c].config(bg="#6aa84f")
        else:
            messagebox.showwarning("Invalid Selection", "Choose your own piece.")
        return

    r1, c1 = selected
    r2, c2 = r, c
    selected = None

    if is_valid_move(r1, c1, r2, c2, human_side):
        board[r2][c2] = board[r1][c1]
        board[r1][c1] = "e"

        update_gui()
        switch_turn()
        update_gui()

        root.after(700, ai_play)
    else:
        messagebox.showerror("Invalid Move", "This move is not valid.")
        update_gui()


def start_game():
    global human_side, ai_side, current_turn, selected

    selected = None
    reset_board()

    human_side = side_var.get()
    ai_side = "defender" if human_side == "attacker" else "attacker"

    current_turn = "attacker"

    update_gui()

    if current_turn == ai_side:
        root.after(700, ai_play)


root = tk.Tk()
root.title("Hnefatafl GUI - Human vs Computer")
root.geometry("650x750")

top = tk.Frame(root)
top.pack(pady=10)

tk.Label(top, text="Choose Side:").grid(row=0, column=0, padx=5)
side_var = tk.StringVar(value="defender")
side_box = ttk.Combobox(top, textvariable=side_var, values=["attacker", "defender"], state="readonly")
side_box.grid(row=0, column=1, padx=5)

tk.Label(top, text="Difficulty:").grid(row=0, column=2, padx=5)
difficulty_var = tk.StringVar(value="easy")
difficulty_box = ttk.Combobox(top, textvariable=difficulty_var, values=["easy", "medium", "hard"], state="readonly")
difficulty_box.grid(row=0, column=3, padx=5)

start_btn = tk.Button(top, text="Start Game", command=start_game)
start_btn.grid(row=0, column=4, padx=5)

info_label = tk.Label(root, text="Human: - | Computer: - | Difficulty: -", font=("Arial", 12))
info_label.pack(pady=5)

turn_label = tk.Label(root, text="Current Turn: -", font=("Arial", 13, "bold"))
turn_label.pack(pady=5)

board_frame = tk.Frame(root)
board_frame.pack(pady=10)

for r in range(BOARD_SIZE):
    row_buttons = []
    for c in range(BOARD_SIZE):
        btn = tk.Button(
            board_frame,
            text="",
            width=5,
            height=2,
            font=("Arial", 14, "bold"),
            command=lambda r=r, c=c: cell_clicked(r, c)
        )
        btn.grid(row=r, column=c, padx=1, pady=1)
        row_buttons.append(btn)
    buttons.append(row_buttons)

legend = tk.Label(
    root,
    text="A = Attacker | D = Defender | K = King | Green = Empty Cell",
    font=("Arial", 11)
)
legend.pack(pady=10)

instruction = tk.Label(
    root,
    text="Click your piece, then click the destination cell.",
    font=("Arial", 11)
)
instruction.pack(pady=5)

reset_board()
update_gui()

root.mainloop()
