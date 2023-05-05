%{
// This part goes directly into the generated parser

#include "scanner.hh"
#include "parser.tab.hh"

// YY_DECL is bound to the type of the scanner. The default is 
// #define YY_DECL int Scanner::yylex()
// which is generated anyway.

//If you want the type of the generated scanner to be different, do this

#undef  YY_DECL
#define YY_DECL int IPL::Scanner::yylex( IPL::Parser::semantic_type * const lval, IPL::Parser::location_type *loc )

//We want these to be the first action after a token is recognized. 

#define YY_USER_ACTION  loc->step(); loc->columns(yyleng);

// token_type is a short hand for IPL::Parser::token

using token_type = IPL::Parser::token;
bool prev = false;
%}

/* %option debug */
%option nodefault
%option yyclass="Scanner"
%option noyywrap
%option c++
%option yylineno
%%

%{ /** Code executed at the beginning of yylex **/

      yylval = lval;

     
%}


[ \t] {}                             //skip
"\n" {loc->lines(1);}
\/\*.*?\*\/ {}
\"([^\\\"]|\\\\|\\n|\\t|\\\")*\" {prev=false;yylval->emplace< std::string >( YYText() );
       return token_type::CONSTANT_STR;}
                                    
[1-9][0-9]*+|0[bB][01]*|0[xX][0-9a-fA-F]*|0[0-7]*  {yylval->emplace< std::string >( YYText() );
       return token_type::CONSTANT_INT;}
"main"  {yylval->emplace< std::string >( YYText() );
       return token_type::MAIN;}
"printf"  {yylval->emplace< std::string >( YYText() );
       return token_type::PRINTF;}
"void"  {prev = false;yylval->emplace< std::string >( YYText() );
       return token_type::VOID;}
"int"  {prev = false;yylval->emplace< std::string >( YYText() );
       return token_type::INT;}
"struct"  {yylval->emplace< std::string >( YYText() );
       return token_type::STRUCT;}
"return"  {yylval->emplace< std::string >( YYText() );
       return token_type::RETURN;}
"if"  {yylval->emplace< std::string >( YYText() );
       return token_type::IF;}
"else"  {yylval->emplace< std::string >( YYText() );
       return token_type::ELSE;}
"while"  {yylval->emplace< std::string >( YYText() );
       return token_type::WHILE;}
"for"  {yylval->emplace< std::string >( YYText() );
       return token_type::FOR;}
[a-zA-Z_][a-zA-Z0-9_]*  {yylval->emplace< std::string >( YYText() );prev = true;
       return token_type::IDENTIFIER;}
"++"  {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_INC;}
"->"  {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_PTR;}
"=="  {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_EQ;}
"!="  {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_NEQ;}
"&&"  {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_AND;}
"||"  {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_OR;}
"<="  {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_LTE;}
">="  {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_GTE;}
"="   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_ASSIGN;}
"<"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_LT;}
">"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_GT;}
"*"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_MUL;}
"/"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_DIV;}
"]"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::RSB;}
"["   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::LSB;}
";"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::EOS;}
"!"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_NOT;}
"-"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_SUB;}
"&"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_ADDR;}
"{"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::LCB;}
"}"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::RCB;}
"+"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_ADD;}
","   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::COMMA;}
"("   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::LRB;}
")"   {prev=false;yylval->emplace< std::string >( YYText() );return token_type::RRB;}
"."  {prev=false;yylval->emplace< std::string >( YYText() );return token_type::OP_MEM;}
 
<<EOF>>         yyterminate();
.		{yylval->emplace< std::string >( YYText() );
       return token_type::OTHERS;}		        ;

%%
