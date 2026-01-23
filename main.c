#include <stdio.h>
#include <stdlib.h>

/* Define filenames */
#define SRC_FILE "input.c"
#define OUT_TOK "token.txt"
#define ERR_LEX "lex_error.txt"
#define ERR_SYN "syntax_error.txt"
#define OUT_TAC "tac.txt"
#define OUT_ASM "assembly.asm"

/* External declarations */
extern int yyparse();
extern FILE *yyin;

/* Global pointers (Must match externs in .l and .y) */
FILE *tokenOut, *lexErrOut, *synErrOut, *tacOut, *asmOut;

void close_resources() {
    if (yyin) fclose(yyin);
    if (tokenOut) fclose(tokenOut);
    if (lexErrOut) fclose(lexErrOut);
    if (synErrOut) fclose(synErrOut);
    if (tacOut) fclose(tacOut);
    if (asmOut) fclose(asmOut);
}

int main() {
    // Attempt to open source file
    yyin = fopen(SRC_FILE, "r");
    if (!yyin) {
        fprintf(stderr, "[Fatal] Cannot open source file: %s\n", SRC_FILE);
        return EXIT_FAILURE;
    }

    // Initialize output streams
    tokenOut   = fopen(OUT_TOK, "w");
    lexErrOut  = fopen(ERR_LEX, "w");
    synErrOut  = fopen(ERR_SYN, "w");
    tacOut     = fopen(OUT_TAC, "w");
    asmOut     = fopen(OUT_ASM, "w");

    if (!tokenOut || !lexErrOut || !synErrOut || !tacOut || !asmOut) {
         fprintf(stderr, "[Fatal] Failed to create output files.\n");
         return EXIT_FAILURE;
    }

    // User Feedback
    printf(">> Initializing Compiler...\n");
    printf(">> Processing '%s'...\n", SRC_FILE);

    // Start Parsing
    yyparse();

    //  Success Message
    printf(">> Build Complete.\n");
    printf(">> Outputs generated: %s, %s, %s\n", OUT_TAC, OUT_ASM, OUT_TOK);

    // Cleanup
    close_resources();

    return EXIT_SUCCESS;
}