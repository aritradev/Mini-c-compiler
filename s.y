%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();
extern int line_num;
extern FILE *synErrOut, *tacOut, *asmOut;

int temp_idx = 1;
int lbl_idx = 1;

char* make_temp() {
    char *buffer = malloc(16);
    sprintf(buffer, "T%d", temp_idx++);
    return buffer;
}

char* make_label() {
    char *buffer = malloc(16);
    sprintf(buffer, "L%d", lbl_idx++);
    return buffer;
}
%}

%code requires {
    typedef struct { 
        char *addr; 
        char *lbl_start;
        char *lbl_true;
        char *lbl_false;
        char *lbl_inc;
    } Data;
}

%union {
    char* text;
    Data* info;
}

/* Added DOUBLE and WHILE here */
%token <text> ID NUM_INT NUM_FLOAT
%token INT FLOAT DOUBLE IF ELSE FOR WHILE
%type <info> expression assignment condition

%left '+' '-'
%left '*' '/'

%%

start: code_block ;

code_block: 
    code_block statement 
    | /* empty */ 
    ;

statement: 
    declaration 
    | assignment ';' 
    | if_statement
    | loop_statement
    | while_statement  /* Added this rule */
    ;

/* Updated declaration to include DOUBLE */
declaration:
    type var_list ';'
    ;

type: INT | FLOAT | DOUBLE ;

var_list: ID | ID ',' var_list ;

assignment: 
    ID '=' expression { 
        fprintf(tacOut, "%s = %s\n", $1, $3->addr);
        fprintf(asmOut, "MOV AX, %s\nMOV %s, AX\n", $3->addr, $1);
        temp_idx = 1; 
    }
    ;

if_statement:
    IF '(' condition ')' 
    '{' 
        { 
             /* Condition logic handled in 'condition' rule */
        } 
        code_block 
    '}' 
    ELSE 
    '{' 
        {
            fprintf(tacOut, "goto L_EXIT\n");
            fprintf(asmOut, "JMP %s\n", $3->lbl_true); 
            
            fprintf(tacOut, "%s:\n", $3->lbl_false);
            fprintf(asmOut, "%s:\n", $3->lbl_false);
        } 
        code_block 
    '}'
    {
        fprintf(tacOut, "L_EXIT:\n");
        fprintf(asmOut, "%s:\n", $3->lbl_true);
    }
    ;

loop_statement:
    FOR '(' assignment ';' 
    { 
        $<info>$ = malloc(sizeof(Data));
        $<info>$->lbl_start = make_label(); 
        $<info>$->lbl_inc   = make_label(); 
        $<info>$->lbl_true  = make_label(); 
        $<info>$->lbl_false = make_label(); 

        fprintf(tacOut, "%s:\n", $<info>$->lbl_start);
        fprintf(asmOut, "%s:\n", $<info>$->lbl_start); 
    } 
    condition ';' 
    {
        fprintf(tacOut, "goto %s\n", $<info>5->lbl_true);
        fprintf(asmOut, "JMP %s\n", $<info>5->lbl_true);
        
        fprintf(tacOut, "%s:\n", $<info>5->lbl_inc);
        fprintf(asmOut, "%s:\n", $<info>5->lbl_inc);
    }
    assignment ')' 
    {
        fprintf(tacOut, "goto %s\n", $<info>5->lbl_start);
        fprintf(asmOut, "JMP %s\n", $<info>5->lbl_start);

        fprintf(tacOut, "%s:\n", $<info>5->lbl_true);
        fprintf(asmOut, "%s:\n", $<info>5->lbl_true);
    }
    '{' 
        code_block 
    '}' 
    {
        fprintf(tacOut, "goto %s\n", $<info>5->lbl_inc);
        fprintf(asmOut, "JMP %s\n", $<info>5->lbl_inc);

        fprintf(tacOut, "%s:\n", $<info>5->lbl_false);
        fprintf(asmOut, "%s:\n", $<info>5->lbl_false);
    }
    ;

/* NEW: While Loop Logic */
while_statement:
    WHILE 
    {
        /* 1. Marker before condition to jump back to */

        $<info>$ = malloc(sizeof(Data));
        $<info>$->lbl_start = make_label();
        fprintf(tacOut, "%s:\n", $<info>$->lbl_start);
        fprintf(asmOut, "%s:\n", $<info>$->lbl_start);
    }
    '(' condition ')' 
    '{' 
        code_block 
    '}' 
    {
        /* 2. End of loop: Jump back to start */
        
        fprintf(tacOut, "goto %s\n", $<info>2->lbl_start);
        fprintf(asmOut, "JMP %s\n", $<info>2->lbl_start);

        /* 3. Exit label (target if condition fails) */
        fprintf(tacOut, "%s:\n", $4->lbl_false);
        fprintf(asmOut, "%s:\n", $4->lbl_false);
    }
    ;

condition: 
    expression '<' expression {
        $$ = malloc(sizeof(Data));
        $$->lbl_true = make_label();  
        $$->lbl_false = make_label(); 

        fprintf(tacOut, "ifFalse %s < %s goto %s\n", $1->addr, $3->addr, $$->lbl_false);
        fprintf(asmOut, "MOV AX, %s\nCMP AX, %s\nJGE %s\n", $1->addr, $3->addr, $$->lbl_false);
    }
    | expression '>' expression {
        $$ = malloc(sizeof(Data));
        $$->lbl_true = make_label();  
        $$->lbl_false = make_label(); 

        fprintf(tacOut, "ifFalse %s > %s goto %s\n", $1->addr, $3->addr, $$->lbl_false);
        fprintf(asmOut, "MOV AX, %s\nCMP AX, %s\nJLE %s\n", $1->addr, $3->addr, $$->lbl_false);
    }
    ;

expression:
    NUM_INT { $$ = malloc(sizeof(Data)); $$->addr = strdup($1); }
    | NUM_FLOAT { $$ = malloc(sizeof(Data)); $$->addr = strdup($1); } /* Added Float support here */
    | ID { $$ = malloc(sizeof(Data)); $$->addr = strdup($1); }
    | expression '+' expression { 
        $$ = malloc(sizeof(Data)); $$->addr = make_temp();
        fprintf(tacOut, "%s = %s + %s\n", $$->addr, $1->addr, $3->addr);
        fprintf(asmOut, "MOV AX, %s\nADD AX, %s\nMOV %s, AX\n", $1->addr, $3->addr, $$->addr);
    }
    | expression '*' expression { 
        $$ = malloc(sizeof(Data)); $$->addr = make_temp();
        fprintf(tacOut, "%s = %s * %s\n", $$->addr, $1->addr, $3->addr);
        fprintf(asmOut, "MOV AX, %s\nMUL %s\nMOV %s, AX\n", $1->addr, $3->addr, $$->addr);
    }
    | expression '/' expression { 
        $$ = malloc(sizeof(Data)); $$->addr = make_temp();
        fprintf(tacOut, "%s = %s / %s\n", $$->addr, $1->addr, $3->addr);
        fprintf(asmOut, "MOV AX, %s\nDIV %s\nMOV %s, AX\n", $1->addr, $3->addr, $$->addr);
    }
    | expression '-' expression { 
        $$ = malloc(sizeof(Data)); $$->addr = make_temp();
        fprintf(tacOut, "%s = %s - %s\n", $$->addr, $1->addr, $3->addr);
        fprintf(asmOut, "MOV AX, %s\nSUB AX, %s\nMOV %s, AX\n", $1->addr, $3->addr, $$->addr);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(synErrOut, "Error [Line %d]: %s\n", line_num, s);
}