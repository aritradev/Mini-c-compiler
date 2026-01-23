# Simple C-Like Compiler

A basic compiler built using **Flex** (Lexical Analyzer) and **Bison** (Parser). It parses a C-like subset language and generates **Three Address Code (TAC)** and **x86-style Assembly (ASM)** code.

## Features
* **Data Types:** `int`, `float`, `double`
* **Control Structures:** `if-else`, `for` loop, `while` loop
* **Arithmetic Operations:** `+`, `-`, `*`, `/`
* **Comparisons:** `<` (Less than), `>` (Greater than)
* **Error Handling:** Basic syntax and lexical error reporting

---

## File Structure

| File | Description |
| :--- | :--- |
| `s.l` | Flex file defining the tokens (Lexer). |
| `s.y` | Bison file defining the grammar and TAC/ASM generation logic (Parser). |
| `main.c` | Driver program that manages file I/O and calls the parser. |
| `input.c` | Source code file to be compiled. |
| `compiler.exe` | The executable generated after compilation. |

### Output Files
| File | Description |
| :--- | :--- |
| `token.txt` | List of tokens identified by the Lexer. |
| `tac.txt` | Intermediate Three Address Code. |
| `assembly.asm` | Generated Assembly code. |
| `lex_error.txt` | Logs unknown characters. |
| `syntax_error.txt` | Logs syntax errors (e.g., missing semicolons). |

---

## Prerequisites
Ensure you have the following installed and added to your system PATH:
1.  **GCC** (GNU Compiler Collection) - MinGW recommended for Windows.
2.  **Flex** (Fast Lexical Analyzer Generator).
3.  **Bison** (Parser Generator).

---

## Build & Run Instructions

Open your terminal (PowerShell, CMD, or Git Bash) in the project directory and run the commands below in order.

### 1. Generate Lexer C Code
bash
flex s.l

### 2. Generate Parser C Code
Bash
bison -d s.y

### 3. Compile the Compiler
Bash
gcc lex.yy.c s.tab.c main.c -o compiler

### 4. Run the Compiler
Windows (PowerShell/CMD):

PowerShell
.\compiler.exe
Linux / macOS / Git Bash:

Bash
./compiler
