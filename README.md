# Hnefatafl

♟️ A digital implementation of **Hnefatafl** (also known as *Viking Chess* or *The King's Table*), an ancient Norse strategy board game. The game logic and AI are written in **Prolog**, with a **Python (Tkinter)** graphical interface that lets a human player face off against the computer.

## About the Game

Hnefatafl is an asymmetric two-player strategy game that predates chess. One side (the **attackers**) tries to capture the king, while the other side (the **defenders**) tries to help the king escape to one of the board's four corners.

- **Board:** 9×9 grid
- **Attackers:** 8 pieces, positioned around the edges of the board
- **Defenders:** 8 pieces surrounding the king in the center
- **King:** 1 piece, starts on the central throne
- **Movement:** All pieces move like a rook in chess — any number of squares horizontally or vertically, but never diagonally, and never through other pieces
- **Captures:** A piece is captured when it is sandwiched between two opposing pieces (or an opposing piece and a corner/throne tile) along a row or column
- **Special tiles:** The throne (center) and the four corners are restricted — only the king may occupy them
- **Win conditions:**
  - **Defenders win** if the king reaches any corner tile
  - **Attackers win** if the king is surrounded on all four orthogonal sides

The attacker moves first.

## Features

- Full Hnefatafl rules implementation: legal move validation, custodian (sandwich) capture, throne/corner restrictions, and win detection
- An AI opponent powered by **minimax search with alpha-beta pruning** and a heuristic evaluation function (piece count, king distance to the nearest corner, king danger, and king mobility)
- Three selectable AI difficulty levels: `easy`, `medium`, and `hard` (controls the search depth)
- Play as either the attackers or the defenders
- Two ways to play:
  - A **Tkinter GUI** with a clickable board
  - A **text-based console** mode driven directly through Prolog

## Project Structure

```
Hnefatafl/
├── src/
│   ├── game_logic.pl     # Board representation, move validation, captures, win conditions
│   ├── alpha_beta.pl     # AI: minimax with alpha-beta pruning, heuristic evaluation, difficulty levels
│   ├── main.pl           # Console game loop (human vs. AI)
│   └── hnefatafl_gui.py  # Tkinter GUI that drives the Prolog engine as a subprocess
├── team_info.txt         # Project team information
└── README.md
```

## Requirements

- [SWI-Prolog](https://www.swi-prolog.org/download/stable) (provides the `swipl` executable)
- Python 3 (Tkinter is included with most standard Python installations)

## Setup

1. Install [SWI-Prolog](https://www.swi-prolog.org/download/stable) and make sure `swipl` is available on your system.
2. Clone the repository:
   ```bash
   git clone https://github.com/mariamriad1/Hnefatafl.git
   cd Hnefatafl
   ```
3. **GUI mode:** `hnefatafl_gui.py` currently points to a hardcoded Windows Prolog path:
   ```python
   SWIPL_PATH = r"C:\Program Files\swipl\bin\swipl.exe"
   ```
   If your `swipl` binary is installed elsewhere (or you're on macOS/Linux), update `SWIPL_PATH` in `src/hnefatafl_gui.py` to point to your local `swipl` executable, or set it to `"swipl"` if it's already on your `PATH`.

## How to Play

### GUI mode (recommended)

```bash
python src/hnefatafl_gui.py
```

Choose your side and difficulty in the interface, then click a piece and a destination tile to move. The board updates automatically after each turn, and the game announces a winner once the king escapes or is captured.

### Console mode

From the `src` directory, start SWI-Prolog and consult the game files:

```bash
swipl
?- ["game_logic.pl", "alpha_beta.pl", "main.pl"].
?- start_game.
```

You'll be prompted to choose your side (`attacker` or `defender`) and a difficulty (`easy`, `medium`, or `hard`). Enter moves in the format:

```
R1-C1-R2-C2.
```

where `R1-C1` is the row/column of the piece you're moving and `R2-C2` is its destination (rows and columns are 0-indexed, `0`–`8`).

## Board Legend

| Symbol | Meaning         |
|--------|-----------------|
| `a`    | Attacker piece  |
| `d`    | Defender piece  |
| `k`    | King            |
| `e`    | Empty square    |


