import os
import re
import subprocess
import tkinter as tk
from tkinter import ttk, messagebox

# =========================
# Python GUI linked with Prolog logic
# =========================

SWIPL_PATH = r"C:\Program Files\swipl\bin\swipl.exe"

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

PROLOG_FILES = [
    os.path.join(BASE_DIR, "game_logic.pl"),
    os.path.join(BASE_DIR, "alpha_beta.pl"),
    os.path.join(BASE_DIR, "main.pl"),
]

BOARD_SIZE = 9

board_term = None
buttons = []
selected = None

human_side = "defender"
ai_side = "attacker"
current_turn = "attacker"


def run_prolog(query):
    command = [SWIPL_PATH, "-q"]

    for file in PROLOG_FILES:
        command.extend(["-s", file])

    command.extend(["-g", f"({query}),halt."])

    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        cwd=BASE_DIR
    )

    if result.returncode != 0:
        error_text = result.stderr.strip() or result.stdout.strip()
        raise RuntimeError(error_text)

    return result.stdout.strip()


def get_initial_board():
    return run_prolog("initial_board(B),write_canonical(B)")


def parse_board(term):
    rows = re.findall(r"\[([aedk](?:,[aedk])*)\]", term)
    board = []
    for row in rows:
        board.append(row.split(","))
    return board


def update_gui():
    board = parse_board(board_term)

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

    info_label.config(
        text=f"Human: {human_side} | Computer: {ai_side} | Difficulty: {difficulty_var.get()}"
    )
    turn_label.config(text=f"Current Turn: {current_turn}")


def switch_turn():
    global current_turn
    current_turn = "defender" if current_turn == "attacker" else "attacker"


def check_winner():
    try:
        defender_result = run_prolog(
            f"(defenders_win({board_term})->write(yes);write(no))"
        )

        attacker_result = run_prolog(
            f"(attackers_win({board_term})->write(yes);write(no))"
        )

        if defender_result == "yes":
            messagebox.showinfo("Game Over", "Defenders Win! The King reached a corner.")
            return True

        if attacker_result == "yes":
            messagebox.showinfo("Game Over", "Attackers Win! The King is surrounded.")
            return True

    except Exception as e:
        messagebox.showerror("Winner Check Error", str(e))

    return False


def make_move(r1, c1, r2, c2):
    global board_term

    query = f"move_piece({board_term},{r1},{c1},{r2},{c2},NB),write_canonical(NB)"
    new_board = run_prolog(query)
    board_term = new_board


def ai_play():
    global board_term

    try:
        difficulty = difficulty_var.get()

        query = f"get_best_move({board_term},{difficulty},{ai_side},M),write_canonical(M)"
        move_text = run_prolog(query)

        nums = re.findall(r"\d+", move_text)

        if len(nums) != 4:
            raise RuntimeError("AI did not return a valid move.")

        r1, c1, r2, c2 = map(int, nums)

        make_move(r1, c1, r2, c2)

        update_gui()

        messagebox.showinfo("AI Move", f"AI played: {r1}-{c1}-{r2}-{c2}")

        if check_winner():
            return

        switch_turn()
        update_gui()

    except Exception as e:
        messagebox.showerror("AI Error", str(e))


def piece_belongs_to_human(piece):
    if human_side == "attacker":
        return piece == "a"
    return piece == "d" or piece == "k"


def get_piece_at(r, c):
    board = parse_board(board_term)
    return board[r][c]


def cell_clicked(r, c):
    global selected

    if current_turn != human_side:
        messagebox.showwarning("Wait", "It is computer turn.")
        return

    if selected is None:
        piece = get_piece_at(r, c)

        if piece_belongs_to_human(piece):
            selected = (r, c)
            buttons[r][c].config(bg="#6aa84f")
        else:
            messagebox.showwarning("Invalid Selection", "Choose your own piece.")

        return

    r1, c1 = selected
    r2, c2 = r, c
    selected = None

    try:
        make_move(r1, c1, r2, c2)
        update_gui()

        if check_winner():
            return

        switch_turn()
        update_gui()

        root.after(700, ai_play)

    except Exception:
        messagebox.showerror("Invalid Move", "This move is not valid according to Prolog game logic.")
        update_gui()


def start_game():
    global board_term, human_side, ai_side, current_turn, selected

    selected = None

    human_side = side_var.get()
    ai_side = "defender" if human_side == "attacker" else "attacker"
    current_turn = "attacker"

    try:
        board_term = get_initial_board()
        update_gui()

        if current_turn == ai_side:
            root.after(700, ai_play)

    except Exception as e:
        messagebox.showerror("Start Error", str(e))


# =========================
# GUI Design
# =========================

root = tk.Tk()
root.title("Hnefatafl GUI - Human vs Computer")
root.geometry("650x750")

top = tk.Frame(root)
top.pack(pady=10)

tk.Label(top, text="Choose Side:").grid(row=0, column=0, padx=5)
side_var = tk.StringVar(value="defender")
side_box = ttk.Combobox(
    top,
    textvariable=side_var,
    values=["attacker", "defender"],
    state="readonly"
)
side_box.grid(row=0, column=1, padx=5)

tk.Label(top, text="Difficulty:").grid(row=0, column=2, padx=5)
difficulty_var = tk.StringVar(value="easy")
difficulty_box = ttk.Combobox(
    top,
    textvariable=difficulty_var,
    values=["easy", "medium", "hard"],
    state="readonly"
)
difficulty_box.grid(row=0, column=3, padx=5)

start_btn = tk.Button(top, text="Start Game", command=start_game)
start_btn.grid(row=0, column=4, padx=5)

info_label = tk.Label(
    root,
    text="Human: - | Computer: - | Difficulty: -",
    font=("Arial", 12)
)
info_label.pack(pady=5)

turn_label = tk.Label(
    root,
    text="Current Turn: -",
    font=("Arial", 13, "bold")
)
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

root.mainloop()
