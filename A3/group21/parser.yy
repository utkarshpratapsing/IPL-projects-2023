%skeleton "lalr1.cc"
%require  "3.0.1"

%defines 
%define api.namespace {IPL}
%define api.parser.class {Parser}

%define parse.trace

%code requires{
    
   namespace IPL {
      class Scanner;
      class abstract_astnode;
      class statement_astnode;
      class exp_astnode;
      class empty_astnode;
      class seq_astnode;
      class assignS_astnode;
      class return_astnode;
      class proccall_astnode;
      class if_astnode;
      class while_astnode;
      class for_astnode;
      class op_binary_astnode;
      class op_unary_astnode;
      class assignE_astnode;
      class funcall_astnode;
      class floatconst_astnode;
      class intcosnt_astnode;
      class stringconst_astnode;
      class ref_astnode;
      class identifier_astnode;
      class member_astnode;
      class arrow_astnode;
      class arrayref_astnode;
      
      class Symbol;
      //class SymbolTable;
      class Type_Specifier;
      class Fun_Declarator;
      class Struct_Specifier;
      class Function_Definition;
      class Translation_Unit;
      class Declaration_List;
      class Compound_Statement;
      class Expression_List;
      class Declarator;
      class Declarator_List;
      enum class op_unary_type;
   }

}

%printer { std::cerr << $$; } IDENTIFIER
%printer { std::cerr << $$; } STRUCT
%printer { std::cerr << $$; } VOID
%printer { std::cerr << $$; } INT
%printer { std::cerr << $$; } MAIN
%printer { std::cerr << $$; } CONSTANT_INT
%printer { std::cerr << $$; } OP_OR
%printer { std::cerr << $$; } OP_AND
%printer { std::cerr << $$; } OP_EQ
%printer { std::cerr << $$; } OP_NEQ
%printer { std::cerr << $$; } OP_LTE
%printer { std::cerr << $$; } OP_GTE
%printer { std::cerr << $$; } OP_LT
%printer { std::cerr << $$; } OP_GT
%printer { std::cerr << $$; } OP_INC
%printer { std::cerr << $$; } OP_SUB
%printer { std::cerr << $$; } OP_NOT
%printer { std::cerr << $$; } OP_ADDR
%printer { std::cerr << $$; } OP_MUL
%printer { std::cerr << $$; } OP_PTR
%printer { std::cerr << $$; } OP_MEM
%printer { std::cerr << $$; } OP_DIV
%printer { std::cerr << $$; } OP_ADD
%printer { std::cerr << $$; } OP_ASSIGN
%printer { std::cerr << $$; } LRB
%printer { std::cerr << $$; } RRB
%printer { std::cerr << $$; } LSB
%printer { std::cerr << $$; } RSB
%printer { std::cerr << $$; } LCB
%printer { std::cerr << $$; } RCB
%printer { std::cerr << $$; } EOS
%printer { std::cerr << $$; } IF
%printer { std::cerr << $$; } ELSE
%printer { std::cerr << $$; } WHILE
%printer { std::cerr << $$; } FOR
%printer { std::cerr << $$; } CONSTANT_STR
%printer { std::cerr << $$; } COMMA
%printer { std::cerr << $$; } PRINTF
%printer { std::cerr << $$; } OTHERS
%printer { std::cerr << $$; } RETURN

%parse-param { Scanner  &scanner  }
%locations

%code{
   #include <iostream>
   #include <cstdlib>
   #include <fstream>
   #include <string>
   #include "ast.hh"
   #include "scanner.hh"
   #include <vector>
   #include <map> 
  using namespace std;
    using namespace IPL;
   class Symboltable{   
       public:
       int offset;
       int size;
       std::string type;
       Symboltable(int off, int sz, std::string type){
           offset = off;
           size = sz;
           type = type;
       }
   };
  string return_label = "";
  bool is_main = false;
   std::map<std::string,Symboltable*> strtoST;
   std::map<std::string,std::map<std::string,Symboltable*>> strtoLST;
   int totaltemp = 0;
   int nodeCount = 0;
   int offset = 0;
   int curr_offset =0;  
   int espindex = 0; 
   int total_labels = 0;
   vector<std::string> finalcode;
   vector<std::string> finalStrings;
    stack<string> labelstack;
   std::map<string,string> iden_type;
   std::map<string,IPL::Struct_Specifier*> get_structinfo;
   std::map<string,IPL::Fun_Declarator*> get_functioninfo;
   IPL::Function_Definition* curr_fun;
   IPL::SymbolTable  temp_gst;
   IPL::SymbolTable * temp_lst;
   
   std::string curr_func_type = "";
   std::string curr_struct = "";


  void printcode(vector<string> strings){
    for(auto item : strings){
      cout<<item<<endl;
    }
  }
 void printStrings(vector<string> strings){
    for(unsigned int i = 0;i<strings.size();i++){
      cout<<".LC"<<i<<":\n";
      cout<<".string " <<strings[i]<<endl;
    }
  }


#undef yylex
#define yylex IPL::Parser::scanner.yylex
#define yyloc IPL::Parser::scanner.loc
}




%define api.value.type variant
%define parse.assert

%start program



%token '\n'
%token <std::string> IDENTIFIER
%token <std::string> STRUCT
%token <std::string> VOID
%token <std::string> INT
%token <std::string> MAIN
%token <std::string> CONSTANT_INT
%token <std::string> OP_OR
%token <std::string> OP_AND
%token <std::string> OP_EQ
%token <std::string> OP_NEQ
%token <std::string> OP_LTE
%token <std::string> OP_GTE
%token <std::string> OP_LT
%token <std::string> OP_GT
%token <std::string> OP_INC
%token <std::string> OP_SUB
%token <std::string> OP_NOT
%token <std::string> OP_ADDR
%token <std::string> OP_MUL
%token <std::string> OP_PTR
%token <std::string> OP_MEM
%token <std::string> OP_DIV
%token <std::string> OP_ADD
%token <std::string> OP_ASSIGN
%token <std::string> LRB
%token <std::string> RRB
%token <std::string> LSB
%token <std::string> RSB
%token <std::string> LCB
%token <std::string> RCB
%token <std::string> EOS
%token <std::string> IF
%token <std::string> ELSE
%token <std::string> WHILE
%token <std::string> FOR
%token <std::string> CONSTANT_STR
%token <std::string> COMMA
%token <std::string> PRINTF
%token <std::string> OTHERS
%token <std::string> RETURN

%nterm <int> program
%nterm <Function_Definition*> main_definition
%nterm <Translation_Unit*> translation_unit
%nterm <Struct_Specifier*> struct_specifier
%nterm <Function_Definition*> function_definition
%nterm <Type_Specifier*> type_specifier
%nterm <Declaration_List*> declaration_list declaration parameter_list parameter_declaration
%nterm <Compound_Statement*> compound_statement
%nterm <Declarator*> declarator declarator_arr
%nterm <Declarator_List*> declarator_list
%nterm <seq_astnode*> statement_list
%nterm <statement_astnode*> statement selection_statement iteration_statement
%nterm <proccall_astnode*> procedure_call
%nterm <proccall_astnode*> printf_call
%nterm <assignE_astnode*> assignment_expression
%nterm <exp_astnode*> expression logical_and_expression equality_expression
%nterm <exp_astnode*> relational_expression additive_expression unary_expression multiplicative_expression postfix_expression primary_expression
%nterm <Expression_List*> expression_list
%nterm <op_unary_type> unary_operator   



%%
program
  : main_definition{
    finalcode.push_back(".globl main");
    finalcode[espindex] = "\tsubl\t$"+to_string(-1*offset)+", %esp"; 
    printStrings(finalStrings);
    printcode(finalcode);
    finalcode.clear();
  } // P1
  | translation_unit main_definition{
    finalcode.push_back(".globl main");
    finalcode[espindex] = "\tsubl \t$"+to_string(-1*offset)+", %esp"; 
    printStrings(finalStrings);
    printcode(finalcode);
    finalcode.clear();
    
  } // P3

translation_unit
  : struct_specifier{
    $$ = new Translation_Unit();
    $$->add_struct_specifier(*$1);
    $$->add_global_symbol(Symbol("struct " + $1->get_name(), SymbolType::Struct, Scope::Global, "-", $1->get_size(), 0));
  } // P4
  | function_definition{
    $$ = new Translation_Unit();
    $$->add_function_definition(*$1);
    $$->add_global_symbol(Symbol($1->get_name(), SymbolType::Function, Scope::Global, $1->get_type(), 0, 0)); 

    finalcode[espindex] = "\tsubl\t$"+to_string(-1*offset)+", %esp"; 
    printStrings(finalStrings);
    printcode(finalcode);
    finalcode.clear();
    strtoST.clear();
    

  } // P3
  | translation_unit struct_specifier{
    $$ = $1;
    $$->add_struct_specifier(*$2);
    $$->add_global_symbol(Symbol("struct " + $2->get_name(), SymbolType::Struct, Scope::Global, "-" , $2->get_size(), 0));
  } // P4
  | translation_unit function_definition{
    $$ = $1;
    $$->add_function_definition(*$2);
    finalcode[espindex] = "\tsubl\t$"+to_string(-1*offset)+", %esp"; 
    printStrings(finalStrings);
    printcode(finalcode);
    finalcode.clear();
    strtoST.clear();
    

  } // P3

/* Struct Declaration */

struct_specifier
  : STRUCT IDENTIFIER{curr_offset = 0;} LCB declaration_list RCB EOS{
 
    $$ = new Struct_Specifier($2);
    // ToDo:
	int tot_size = 0; 
    std::vector<Symbol> symbols = $5->get_symbols();
    
    for(unsigned int i = 0; i< symbols.size(); i++){
        $$->add_symbol(symbols[i], offset);

		tot_size += symbols[i].get_size();
        offset += symbols[i].get_size(); 
        
    }
	$$->set_size(tot_size);
    
  } // P4

/* Function Definition */

function_definition
  : type_specifier IDENTIFIER LRB RRB {
    
    //finalcode.push_back($2+":");
    is_main = false;
    
    offset = 0;

    return_label = "l"+to_string(total_labels++);


    finalcode.push_back($2+":");
    finalcode.push_back("\tpushl\t%ebp");
    finalcode.push_back("\tmovl\t%esp, %ebp");
    finalcode.push_back("");
    espindex = finalcode.size()-1;


  }compound_statement{
    finalcode.push_back(return_label+":");
    finalcode.push_back("\tleave");
    finalcode.push_back("\tret");
    

    $$ = new Function_Definition();
    $$->set_type($1->get_type());
    $$->set_name($2);
    vector<Symbol> symbols = $6->get_symbols();
    //int offset = 4;
    // for(unsigned int i = 0; i< symbols.size(); i++){
        // offset-=4;
        // offset -= symbols[i].get_size(); 
        // $$->add_symbol(symbols[i], offset);
        // strtoST[symbols[i].name]  = new Symboltable(offset,4,"int");
    // }

    $$->set_ast($6->get_ast());
  } // P3
  | type_specifier IDENTIFIER LRB parameter_list RRB {
    
    is_main = false;
    finalcode.push_back($2+":");
    finalcode.push_back("\tpushl\t%ebp");
    finalcode.push_back("\tmovl\t%esp, %ebp");
    finalcode.push_back("");
    espindex = finalcode.size()-1;
    
    offset = 0;

    return_label = "l"+to_string(total_labels++);
  } compound_statement{
  $$ = new Function_Definition();
    $$->set_type($1->get_type());
    $$->set_name($2);
    
    std::vector<Symbol> symbols = $4->get_symbols();
    for(unsigned int i = 0; i< symbols.size(); i++){

       $$->add_symbol(symbols[i], symbols[i].offset);
    }
    
    symbols = $7->get_symbols();
    finalcode.push_back(return_label+":");
    finalcode.push_back("\tleave");
    finalcode.push_back("\tret");

    // // for(unsigned int i = 0; i< symbols.size(); i++){
    //     offset-=4;
    //     offset -= symbols[i].get_size(); 
    //     $$->add_symbol(symbols[i], offset);
    //     strtoST[symbols[i].name]  = new Symboltable(offset,4,"int");
        
    // }
	
    $$->set_ast($7->get_ast());
} // P3

/* Main Function */

main_definition
  : INT MAIN LRB RRB {
    is_main = true;
    offset = 0;
    return_label = "l"+to_string(total_labels++);
    finalcode.push_back("main:");
    finalcode.push_back("\tpushl\t%ebp");
    finalcode.push_back("\tmovl\t%esp, %ebp");
    finalcode.push_back("");
    strtoST["return"] = new  Symboltable(4,4,"int");
    espindex = finalcode.size()-1;
    
  }compound_statement{
    finalcode.push_back(return_label+":");
    finalcode.push_back("\tleave");
    finalcode.push_back("\tret");
    
    $$ = new Function_Definition();
    $$->set_type("int");
    $$->set_name("main");
    std::vector<Symbol> symbols = $6->get_symbols();
    
    // for(unsigned int i = 0; i< symbols.size(); i++){
    //     offset -= symbols[i].get_size(); 
    //     $$->add_symbol(symbols[i], offset);
        
    // }
	
    $$->set_ast($6->get_ast());

  } // P1

/* Type Specifier */

type_specifier
  : VOID { $$ = new Type_Specifier("void");$$->set_size(4);}// P3
  | INT {
    $$ = new Type_Specifier("int");$$->set_size(4);
  }// P1
  | STRUCT IDENTIFIER{
    $$ = new Type_Specifier("struct "+$2,$2);
    if(get_structinfo["struct "+$2])$$->set_size(get_structinfo["struct "+$2]->get_size());
    else $$->set_size(4);
  } // P4

/* Declaration List */

declaration_list
  : declaration{
    
    $$ = new Declaration_List();
    std::vector<Symbol> symbols = $1->get_symbols();
    for(unsigned int i = 0; i< symbols.size(); i++){
    offset-=4;
    strtoST[symbols[i].name] = new  Symboltable(offset,symbols[i].size,"int");    
    $$->add_symbol(symbols[i]);
    nodeCount++;
    }
    //finalcode.push_back("subl $"+to_string(offset)+", %esp");
  } // P1
  | declaration_list declaration{
    //finalcode.push_back("subl $"+to_string(offset)+", %esp");
        $$ = $1;
    std::vector<Symbol> symbols = $2->get_symbols();
    for(unsigned int i = 0; i< symbols.size(); i++){
        offset-=4;
    strtoST[symbols[i].name] = new Symboltable(offset,symbols[i].size,"int");    
        $$->add_symbol(symbols[i]);
        nodeCount++;
    }
    //finalcode.push_back("subl $"+to_string(offset)+", %esp");
  } // P1

declaration
  : type_specifier declarator_list EOS{
    int size = 0;
    $$ = new Declaration_List();
    std::vector<Declarator> declarators = $2->get_declarators();
    //ToDo: Add size to symbol
    for(unsigned int i = 0; i< declarators.size(); i++){

        //offset-=4;
        //strtoST[symbols[i].name] = new  Symboltable(offset,symbols[i].size,"int"); 

        iden_type[declarators[i].get_name()] = $1->get_type()+declarators[i].get_stars();
        
        if(declarators[i].get_stars() != "" and declarators[i].get_stars()[0] == '*'){size = 4*(declarators[i].get_size());}
        else { size = $1->get_size()*declarators[i].get_size();}
        
       
        $$->add_symbol(Symbol(declarators[i].get_name(), SymbolType::Var, Scope::Local, $1->get_type()+declarators[i].get_stars(), size, 0));
        
    } 

  } // P1

declarator_list
  : declarator{
        $$ = new Declarator_List();

    $$->add_declarator(*$1);
  } // P1
  | declarator_list COMMA declarator{
        $$ = $1;
    $$->add_declarator(*$3);
  } // P1

declarator
  : declarator_arr{$$ = $1;} // P1
  | OP_MUL declarator{
    $$ = $2;
    $$->set_stars("*"+$$->get_stars());
  } // P5

declarator_arr
  : IDENTIFIER{
    $$ = new Declarator($1,1);

  } // P1
  | declarator_arr LSB CONSTANT_INT RSB{
    $$ = $1;
    $$->set_size(stoi($3)*$$->get_size());
	$$->set_stars($$->get_stars()+"["+$3+"]");
  } // P6


/* Parameter List */

parameter_list
  : parameter_declaration{
    $$ = new Declaration_List();
    int temp_offset = 4;
    std::vector<Symbol> symbols = $1->get_symbols();
    for(unsigned int i = 0; i< symbols.size(); i++){
        temp_offset+=4;
        //cout<<symbols[i].name<<" "<<temp_offset<<endl;
        strtoST[symbols[i].name] = new  Symboltable(temp_offset,symbols[i].size,"int"); 
        $$->add_symbol(symbols[i]);
    }
    
    temp_offset+=4;
    strtoST["return"] = new  Symboltable(temp_offset,4,"int");
    
  } // P3
  | parameter_list COMMA parameter_declaration{

    $$ = $1;
    int temp_offset = strtoST[$1->get_symbols().back().name]->offset;

	  vector<Symbol> symbols = $3->get_symbols();
	  for(unsigned int i = 0; i < symbols.size();i++){
    temp_offset+=4;
    //cout<<symbols[i].name<<" "<<temp_offset<<endl;
    strtoST[symbols[i].name] = new  Symboltable(temp_offset,symbols[i].size,"int"); 
		$$->add_symbol(symbols[i]);
    
	}
    
    temp_offset+=4;
    strtoST["return"] = new  Symboltable(temp_offset,4,"int");
  } // P3

parameter_declaration
  : type_specifier declarator{
    $$ = new Declaration_List();
    std::vector<Declarator> declarators = {*$2};
    //ToDo: Add size to symbol
    for(unsigned int i = 0; i< declarators.size(); i++){
        
        iden_type[declarators[i].get_name()] = $1->get_type()+declarators[i].get_stars();
        
        int size = 0;
        if(declarators[i].get_stars()!="" and declarators[i].get_stars()[0]=='*'){size = 4*declarators[i].get_size();}
        else {size = declarators[i].get_size()*($1->get_size());}
        $$->add_symbol(Symbol(declarators[i].get_name(), SymbolType::Var, Scope::Local, $1->get_type()+ declarators[i].get_stars(), size, 0));
    }
  } // P3

/* Statements */
compound_statement
  : LCB RCB { $$ = new Compound_Statement(); } // P1
  | LCB statement_list RCB {
    $$ = new Compound_Statement();
    $$->set_ast($2);
}// P1
  | LCB declaration_list statement_list RCB{
    $$ = new Compound_Statement();
    $$->set_ast($3);
    std::vector<Symbol> symbols = $2->get_symbols();
    for(unsigned int i = 0; i< symbols.size(); i++){
        
        $$->add_symbol(symbols[i]);}
} // P1

statement_list
  : statement{
    $$ = new seq_astnode();
    $$->add_statement($1);
} // P1
  | statement_list statement{
    $$ = $1;
    $$->add_statement($2);
    
} // P1

statement
  : EOS { $$ = new empty_astnode(); }// P1
  | LCB statement_list RCB{ $$ = $2;} // P1
  | assignment_expression EOS {$$ = new assignS_astnode($1->exp1,$1->exp2);} // P1
  | selection_statement { $$ = $1;}// P2
  | iteration_statement { $$ = $1;}// P2
  | procedure_call { $$ = $1;}// P3
  | printf_call { $$ = $1;}// P1
  | RETURN expression EOS { 
    $$ = new return_astnode($2);
    //finalcode.push_back("movl $0, %eax");
    
    finalcode.push_back("\tmovl\t"+to_string(strtoST[$2->temp_name]->offset)+"(%ebp), %eax" );
    if(!is_main){finalcode.push_back("\tmovl\t%eax, "+to_string(strtoST["return"]->offset)+"(%ebp)");}
    finalcode.push_back("\tjmp\t"+return_label);
    }// P1

/* Expressions */
assignment_expression
  : unary_expression OP_ASSIGN expression{
    $$ = new assignE_astnode($1,$3);
    
    finalcode.push_back("\tmovl\t"+to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %eax");
    finalcode.push_back("\tmovl\t%eax, "+to_string(strtoST[$1->temp_name]->offset)+"(%ebp)");
   
  } // P1

expression
  : logical_and_expression{
    $$ = $1;
    
  } // P1
  | expression OP_OR logical_and_expression {
    $$ = new op_binary_astnode($1,$3,op_binary_type::OR_OP);
    // cmpl with %0 1st operand
    //setne %al
    finalcode.push_back("\tmovl\t"+ to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
    finalcode.push_back("\tcmpl\t$0, %ebx");
    finalcode.push_back("\tsetne\t%al");
    finalcode.push_back("\tmovzbl\t%al, %ebx");

    finalcode.push_back("\tmovl\t"+ to_string(strtoST[$3->temp_name]->offset) + "(%ebp), %ecx");
    finalcode.push_back("\tcmpl\t$0, %ecx");
    finalcode.push_back("\tsetne\t%al");
    finalcode.push_back("\tmovzbl\t%al, %ecx");

    finalcode.push_back("\torl\t%ecx, %ebx");

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
    
    finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
    totaltemp++;
  }// P1

logical_and_expression
  : equality_expression {$$ = $1;}// P1
  | logical_and_expression OP_AND equality_expression{
    $$ = new op_binary_astnode($1,$3,op_binary_type::AND_OP);

     finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
    finalcode.push_back("\tcmpl\t$0, %ebx");
    finalcode.push_back("\tsetne\t%al");
    finalcode.push_back("\tmovzbl\t%al, %ebx");

    finalcode.push_back("\tmovl\t"+
    to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %ecx");
    finalcode.push_back("\tcmpl\t$0, %ecx");
    finalcode.push_back("\tsetne\t%al");
    finalcode.push_back("\tmovzbl\t%al, %ecx");

    finalcode.push_back("\tandl\t%ecx, %ebx");

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
    
    finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
    totaltemp++;
  } // P1

equality_expression
  : relational_expression { $$ = $1; }// P1
  | equality_expression OP_EQ relational_expression{
    $$ = new op_binary_astnode($1,$3,op_binary_type::EQ_OP_INT);$$->val_type = "int";

    

     finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
finalcode.push_back("\tmovl\t"+
    to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %ecx");

    finalcode.push_back("\tcmpl\t%ecx, %ebx");
    finalcode.push_back("\tsete\t%al");
    finalcode.push_back("\tmovzbl\t%al, %ebx");

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
    
    finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
    totaltemp++;

    } // P1
  | equality_expression OP_NEQ relational_expression{
    $$ = new op_binary_astnode($1,$3,op_binary_type::NE_OP_INT);$$->val_type = "int";
     finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
finalcode.push_back("\tmovl\t"+
    to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %ecx");

    finalcode.push_back("\tcmpl\t%ecx, %ebx");
    finalcode.push_back("\tsetne\t%al");
    finalcode.push_back("\tmovzbl\t%al, %ebx");

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
    
    //finalcode.push_back("movl %ebx , "+strtoST["Temp"+to_string(totaltemp)]+"(%ebp)");
    finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
    totaltemp++;
    } // P1

relational_expression
  : additive_expression { $$ = $1; }
  | relational_expression OP_LT additive_expression {
    $$ = new op_binary_astnode($1,$3,op_binary_type::LT_OP_INT);$$->val_type = "int";\
     finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
finalcode.push_back("\tmovl\t"+
    to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %ecx");


    finalcode.push_back("\tcmpl\t%ebx, %ecx");
    finalcode.push_back("\tsetg\t%al");
    finalcode.push_back("\tmovzbl\t%al, %ebx");

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
    //finalcode.push_back("movl %ebx , "+strtoST["Temp"+to_string(totaltemp)]+"(%ebp)");
    finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
    totaltemp++;
    } // P1
  | relational_expression OP_GT additive_expression {
    $$ = new op_binary_astnode($1,$3,op_binary_type::GT_OP_INT);$$->val_type = "int";
finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$3->temp_name]->offset) + "(%ebp), %ecx");

    finalcode.push_back("\tcmpl\t%ebx, %ecx");
    finalcode.push_back("\tsetl\t %al");
    finalcode.push_back("\tmovzbl\t %al, %ebx");

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
    
    //finalcode.push_back("movl %ebx , "+strtoST["Temp"+to_string(totaltemp)]+"(%ebp)");
    finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
    totaltemp++;
    }// P1
  | relational_expression OP_LTE additive_expression {
    $$ = new op_binary_astnode($1,$3,op_binary_type::LE_OP_INT);$$->val_type = "int";
     finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
finalcode.push_back("\tmovl\t"+
    to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %ecx");


    finalcode.push_back("\tcmpl\t%ebx, %ecx");
    finalcode.push_back("\tsetge\t%al");
    finalcode.push_back("\tmovzbl\t%al, %ebx");

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
   
    //finalcode.push_back("movl %ebx , "+strtoST["Temp"+to_string(totaltemp)]+"(%ebp)");
     finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
     totaltemp++;
    }// P1
  | relational_expression OP_GTE additive_expression {
    $$ = new op_binary_astnode($1,$3,op_binary_type::GE_OP_INT);$$->val_type = "int";
     finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
finalcode.push_back("\tmovl\t"+
    to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %ecx");


    finalcode.push_back("\tcmpl\t%ebx, %ecx");
    finalcode.push_back("\tsetle\t%al");
    finalcode.push_back("\tmovzbl\t%al, %ebx");

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
    
    //finalcode.push_back("movl %ebx , "+strtoST["Temp"+to_string(totaltemp)]+"(%ebp)");
    finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
    totaltemp++;
  }// P1

additive_expression
  : multiplicative_expression{$$ = $1;} // P1
  | additive_expression OP_ADD multiplicative_expression {
    $$ = new op_binary_astnode($1,$3,op_binary_type::PLUS_INT);$$->val_type = "int";
     finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
finalcode.push_back("\tmovl\t"+
    to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %ecx");


    finalcode.push_back("\taddl\t%ecx, %ebx");

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
    
    finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
    totaltemp++;
    } // P1
  | additive_expression OP_SUB multiplicative_expression {
    $$ = new op_binary_astnode($1,$3,op_binary_type::MINUS_INT);$$->val_type = "int";
     finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
finalcode.push_back("\tmovl\t"+
    to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %ecx");


    finalcode.push_back("\tsubl\t%ecx, %ebx");

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
    
    //finalcode.push_back("movl %ebx , "+strtoST["Temp"+to_string(totaltemp)]+"(%ebp)");
    finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
    totaltemp++;
    }// P1

multiplicative_expression
  : unary_expression{$$=$1;} // P1
  | multiplicative_expression OP_MUL unary_expression {
    $$ = new op_binary_astnode($1,$3,op_binary_type::MULT_INT);$$->val_type = "int";
     finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
finalcode.push_back("\tmovl\t"+
    to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %ecx");


    finalcode.push_back("\timul\t%ecx, %ebx");

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
    
    //finalcode.push_back("movl %ebx , "+strtoST["Temp"+to_string(totaltemp)]+"(%ebp)");
    finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
    totaltemp++;
    } // P1
  | multiplicative_expression OP_DIV unary_expression {
    $$ = new op_binary_astnode($1,$3,op_binary_type::DIV_INT);
    $$->val_type = "int";

     finalcode.push_back("\tmovl\t"+
   to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
finalcode.push_back("\tmovl\t"+
    to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %ecx");

  //cltd
  //idivl %ecx
  
    finalcode.push_back("\tmovl\t%ebx, %eax");
    finalcode.push_back("\tcltd");
    finalcode.push_back("\tidivl\t%ecx");
 

    offset-=4;
    strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
    $$->temp_name = "Temp"+to_string(totaltemp);
    
    //finalcode.push_back("movl %eax , "+strtoST["Temp"+to_string(totaltemp)]+"(%ebp)");
    finalcode.push_back("\tmovl\t%eax, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
    totaltemp++;

}// P1

unary_expression
  : postfix_expression {$$=$1;}// P1
  | unary_operator unary_expression {
    $$ = new op_unary_astnode($2,$1);
    if($1==op_unary_type::UMINUS){
      finalcode.push_back("\tmovl\t"+to_string(strtoST[$2->temp_name]->offset)+"(%ebp), %ebx");
      finalcode.push_back("\tneg\t%ebx");

      offset-=4;
      strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
      $$->temp_name = "Temp"+to_string(totaltemp);
      
      //finalcode.push_back("movl %ebx , "+strtoST["Temp"+to_string(totaltemp)]+"(%ebp)");
      finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
      totaltemp++;
    }
    if($1 == op_unary_type::NOT){
      finalcode.push_back("\tmovl\t"+to_string(strtoST[$2->temp_name]->offset)+"(%ebp), %ebx");
      finalcode.push_back("\tcmpl\t$0, %ebx");
      finalcode.push_back("\tsete\t%al");
      finalcode.push_back("\tmovzbl\t%al, %ebx");
      offset-=4;
      strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
      $$->temp_name = "Temp"+to_string(totaltemp);
      
      //finalcode.push_back("movl %ebx , "+strtoST["Temp"+to_string(totaltemp)]+"(%ebp)");
      finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
      totaltemp++;
    }
  }// P1

postfix_expression
  : primary_expression{$$=$1;} // P1
  | postfix_expression OP_INC{

    $$ = new op_unary_astnode($1,op_unary_type::PP);

    finalcode.push_back("\tmovl\t" + to_string(strtoST[$1->temp_name]->offset) + "(%ebp), %ebx");
      
      finalcode.push_back("\taddl\t$1, %ebx");

      offset-=4;
      strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
      $$->temp_name = "Temp"+to_string(totaltemp);
      
      //finalcode.push_back("movl %ebx , "+strtoST["Temp"+to_string(totaltemp)]+"(%ebp)");
      finalcode.push_back("\tmovl\t%ebx, "+to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
      totaltemp++;


    } // P1
  | IDENTIFIER LRB RRB{
    $$ = new funcall_astnode($1); 
    $$->val_type = iden_type[$1];
    finalcode.push_back("\tcall\t"+$1);
    finalcode.push_back("\tsubl\t$4, %esp");
    offset-=4;
    strtoST["Temp"+to_string(total_labels)] = new Symboltable(offset,4,"int");
    //finalcode.push_back("\tmovl\t%esp, "+to_string(strtoST["Temp"+to_string(total_labels)]->offset)+"(%ebp)");
    finalcode.push_back("\tpushl\t%eax");
    finalcode.push_back("\tmovl\t%eax, "+to_string(strtoST["Temp"+to_string(total_labels)]->offset)+"(%ebp)");
    $$->temp_name = "Temp"+to_string(total_labels);

    total_labels++;
    
    } // P3
  | IDENTIFIER LRB expression_list RRB{

    funcall_astnode* output = new funcall_astnode($1);
    std::vector<exp_astnode*> expressions = $3->get_expressions();
    reverse(expressions.begin(),expressions.end());
    finalcode.push_back("\tsubl\t$4,%esp");
    for (unsigned int i = 0; i < expressions.size(); i++) {
       output->add_argument(expressions[i]);
       finalcode.push_back("\tpushl\t"+to_string(strtoST[expressions[i]->temp_name]->offset)+"(%ebp)");
    }
    
    finalcode.push_back("\tcall\t"+$1);
    finalcode.push_back("\taddl\t$"+to_string(4*expressions.size())+", %esp");
    offset-=4;
    strtoST["Temp"+to_string(total_labels)] = new Symboltable(offset,4,"int");
    
    finalcode.push_back("\tpushl\t%eax");
    finalcode.push_back("\tmovl\t%eax, "+to_string(strtoST["Temp"+to_string(total_labels)]->offset)+"(%ebp)");
    
  
    $$ = output;
    $$->temp_name = "Temp"+to_string(total_labels);
    total_labels++;
    $$->val_type = iden_type[$1];
  } // P3
  | postfix_expression OP_MEM IDENTIFIER{
    Symbol S = get_structinfo[$1->val_type]->get_lst().get_symbol_by_name($3); 
    $$ = new member_astnode($1,new identifier_astnode($3));
    $$->val_type = S.get_semantic_type();
  } // P4
  | postfix_expression OP_PTR IDENTIFIER { 
    Symbol S = get_structinfo[$1->val_type]->get_lst().get_symbol_by_name($3); 
       $$ = new arrow_astnode($1,new identifier_astnode($3)); 
    $$->val_type = S.get_semantic_type();} // P5
  | postfix_expression LSB expression RSB{string derefed_tpye = $1->get_derefrenced_type();$$ = new arrayref_astnode($1,$3); 
    
        $$->val_type =derefed_tpye;
        } // P6

primary_expression
  : IDENTIFIER{
    $$ = new identifier_astnode($1);
    $$->temp_name = $1;
  } // P1
  | CONSTANT_INT{
    $$ = new intconst_astnode(stoi($1));
     offset-=4;
      strtoST["Temp"+to_string(totaltemp)]  = new Symboltable(offset,4,"int");
      $$->temp_name = "Temp"+to_string(totaltemp);
      
      finalcode.push_back("\tmovl\t$"+$1 +", " +to_string(strtoST["Temp"+to_string(totaltemp)]->offset)+"(%ebp)");
      totaltemp++;

  } // P1
  | LRB expression RRB { $$ = $2; $$->val_type = $2->val_type; }// P1

unary_operator
  : OP_SUB { $$ = op_unary_type::UMINUS;  }// P1
  | OP_NOT { $$ = op_unary_type::NOT; }// P1
  | OP_ADDR { $$ = op_unary_type::ADDRESS; } // P5
  | OP_MUL { $$ = op_unary_type::DEREF; }// P5

/* Selection Statement */
selection_statement
: IF LRB expression RRB{
  finalcode.push_back("\tmovl\t"+to_string(strtoST[$3->temp_name]->offset)+"(%ebp), %ebx");
  finalcode.push_back("\tcmpl\t$0, %ebx");
  finalcode.push_back("\tje\tl"+to_string(total_labels));
  labelstack.push("l"+to_string(total_labels));
  total_labels+=1;
} statement {
  
  finalcode.push_back("\tjmp\tl"+to_string(total_labels));
  finalcode.push_back(labelstack.top()+":");
  labelstack.pop();
  labelstack.push("l"+to_string(total_labels));
  total_labels+=1;

} ELSE statement { 
    $$ = new if_astnode($3,$6,$9); 
    finalcode.push_back(labelstack.top()+":");
    labelstack.pop();
    
  } // P2

/* Iteration Statement */
iteration_statement
  : WHILE {
    finalcode.push_back("l"+to_string(total_labels)+":");
    labelstack.push("l"+to_string(total_labels));
    total_labels+=1;
  } LRB expression RRB {
    finalcode.push_back("\tmovl\t"+to_string(strtoST[$4->temp_name]->offset)+"(%ebp), %ebx");
    finalcode.push_back("\tcmpl\t$0, %ebx");
    finalcode.push_back("\tje\tl"+to_string(total_labels));
    labelstack.push("l"+to_string(total_labels));
    total_labels+=1;
  }

  statement {
     $$ = new while_astnode($4,$7);
     string s1 = labelstack.top();
     labelstack.pop();
     finalcode.push_back("jmp\t"+labelstack.top());
     finalcode.push_back(s1+":");
     total_labels+=1;
     labelstack.pop();
    }
    
    // P2
  | FOR LRB assignment_expression{
    finalcode.push_back("l"+to_string(total_labels)+":");
    labelstack.push("l"+to_string(total_labels)); //0
    total_labels+=1;
  } EOS expression{
    finalcode.push_back("\tmovl\t"+to_string(strtoST[$6->temp_name]->offset)+"(%ebp), %ebx");
    finalcode.push_back("\tcmpl\t$0, %ebx");
    finalcode.push_back("\tje\tl"+to_string(total_labels+2));//3
    finalcode.push_back("\tjmp\tl"+to_string(total_labels+1));//2
    finalcode.push_back("l"+to_string(total_labels)+":"); //1
    string a = labelstack.top();
    labelstack.pop();
    labelstack.push("l"+to_string(total_labels+2));
    labelstack.push("l"+to_string(total_labels));
    labelstack.push("l"+to_string(total_labels+1));
    labelstack.push(a);
    total_labels+=3;
  } EOS assignment_expression{

    finalcode.push_back("\tjmp\t"+labelstack.top());//0
    labelstack.pop();
    finalcode.push_back(labelstack.top()+":");//2
    labelstack.pop();
    //total_labels+=1;
  } RRB statement{ 

	exp_astnode* a1 = $3;
	exp_astnode* a2 = $9;
	$$ = new for_astnode(a1,$6,a2,$12); 

  finalcode.push_back("\tjmp\t"+labelstack.top());//1
  labelstack.pop();
  finalcode.push_back(labelstack.top()+":");//3
  labelstack.pop();
  total_labels+=1;
}
 // P2

/* Expression List */
expression_list
  : expression { $$ = new Expression_List(); $$->add_expression($1); }// P1
  | expression_list COMMA expression { $$ = $1; $$->add_expression($3); }// P1

/* Procedure Call */
procedure_call
  : IDENTIFIER LRB RRB EOS{
    $$ = new proccall_astnode($1);
    finalcode.push_back("\tcall\t"+$1);
  } // P3
  | IDENTIFIER LRB expression_list RRB EOS{
    $$ = new proccall_astnode($1);
    
    std::vector<exp_astnode*> expressions = $3->get_expressions();
    reverse(expressions.begin(),expressions.end());
    for(unsigned int i = 0; i< expressions.size(); i++){
      $$->add_argument(expressions[i]);
      finalcode.push_back("\tpushl\t"+
      to_string(strtoST[expressions[i]->temp_name]->offset)+
      "(%ebp)");
      
    }

    finalcode.push_back("\tcall\t"+$1);
    finalcode.push_back("\taddl\t$"+to_string(4*expressions.size())+", %esp");

  } // P3

/* Printf Call */
printf_call
  : PRINTF LRB CONSTANT_STR RRB EOS{
    
    finalcode.push_back("\tpushl\t$.LC" + to_string(finalStrings.size()));
    finalStrings.push_back($3);
    finalcode.push_back("\tcall\tprintf");
    $$ = new proccall_astnode($1);
  } // P1
  | PRINTF LRB CONSTANT_STR COMMA expression_list RRB EOS{
    vector <exp_astnode*> temp = $5->get_expressions();
    reverse(temp.begin(),temp.end());
    for(unsigned int i =0 ;i <temp.size();i++){
      finalcode.push_back("\tpushl\t"+to_string(strtoST[temp[i]->temp_name]->offset)+"(%ebp)");
    }
    finalcode.push_back("\tpushl\t$.LC" + to_string(finalStrings.size()));
    finalStrings.push_back($3);
    finalcode.push_back("\tcall\tprintf");
    finalcode.push_back("\taddl\t$"+to_string(4*temp.size())+", %esp");
    $$ = new proccall_astnode($1);
    
    std::vector<exp_astnode*> expressions = $5->get_expressions();
    for(unsigned int i = 0; i< expressions.size(); i++){
      $$->add_argument(expressions[i]);
      
    }
  } // P1


%%
void IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cout << "Error at line " << l.begin.line <<": " <<err_message <<"\n";
   exit(1);
}


