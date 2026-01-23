%{
#include <stdio.h>
#include <string.h>
#include "s.tab.h"

int line_num = 1;

extern FILE *tokenOut; 
extern FILE *lexErrOut;

char *strdup(const char *s); 
%}

%option noyywrap

%%

[ \t]       ; 
[\n]        { line_num++; }

"int"       { fprintf(tokenOut, "<KEYWORD, int>\n"); return INT; }
"float"     { fprintf(tokenOut, "<KEYWORD, float>\n"); return FLOAT; }
"double"    { fprintf(tokenOut, "<KEYWORD, double>\n"); return DOUBLE; }
"if"        { fprintf(tokenOut, "<KEYWORD, if>\n"); return IF; }
"else"      { fprintf(tokenOut, "<KEYWORD, else>\n"); return ELSE; }
"for"       { fprintf(tokenOut, "<KEYWORD, for>\n"); return FOR; }
"while"     { fprintf(tokenOut, "<KEYWORD, while>\n"); return WHILE; }

[0-9]+      { 
    fprintf(tokenOut, "<CONST_INT, %s>\n", yytext);
    yylval.text = strdup(yytext); 
    return NUM_INT; 
}

[0-9]+"."[0-9]+ { 
    fprintf(tokenOut, "<CONST_FLOAT, %s>\n", yytext);
    yylval.text = strdup(yytext); 
    return NUM_FLOAT; 
}

[a-zA-Z_][a-zA-Z0-9_]* { 
    fprintf(tokenOut, "<ID, %s>\n", yytext);
    yylval.text = strdup(yytext); 
    return ID; 
}

"="         { fprintf(tokenOut, "<OP, =>\n"); return '='; }
"+"         { fprintf(tokenOut, "<OP, +>\n"); return '+'; }
"-"         { fprintf(tokenOut, "<OP, ->\n"); return '-'; }
"*"         { fprintf(tokenOut, "<OP, *>\n"); return '*'; }
"/"         { fprintf(tokenOut, "<OP, />\n"); return '/'; }
"<"         { fprintf(tokenOut, "<REL_OP, <>\n"); return '<'; }
">"         { fprintf(tokenOut, "<REL_OP, >>\n"); return '>'; }
";"         { fprintf(tokenOut, "<PUNCT, ;>\n"); return ';'; }
","         { fprintf(tokenOut, "<PUNCT, ,>\n"); return ','; }
"("         { fprintf(tokenOut, "<PUNCT, (>\n"); return '('; }
")"         { fprintf(tokenOut, "<PUNCT, )>\n"); return ')'; }
"{"         { fprintf(tokenOut, "<PUNCT, {>\n"); return '{'; }
"}"         { fprintf(tokenOut, "<PUNCT, }>\n"); return '}'; }

.           { 
    fprintf(lexErrOut, "Unknown character at line %d: %s\n", line_num, yytext); 
}

%%