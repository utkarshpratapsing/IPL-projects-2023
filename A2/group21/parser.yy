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
      class SymbolTable;
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

  // # ifndef YY_NULLPTR
  // #  if defined __cplusplus && 201103L <= __cplusplus
  // #   define YY_NULLPTR nullptr
  // #  else
  // #   define YY_NULLPTR 0
  // #  endif
  // # endif

}

%printer { std::cerr << $$; } IDENTIFIER
%printer { std::cerr << $$; } STRUCT
%printer { std::cerr << $$; } VOID
%printer { std::cerr << $$; } INT
%printer { std::cerr << $$; } FLOAT
%printer { std::cerr << $$; } INT_CONSTANT
%printer { std::cerr << $$; } FLOAT_CONSTANT
%printer { std::cerr << $$; } OR_OP
%printer { std::cerr << $$; } AND_OP
%printer { std::cerr << $$; } EQ_OP
%printer { std::cerr << $$; } NE_OP
%printer { std::cerr << $$; } LE_OP
%printer { std::cerr << $$; } GE_OP
%printer { std::cerr << $$; } INC_OP
%printer { std::cerr << $$; } PTR_OP
%printer { std::cerr << $$; } IF
%printer { std::cerr << $$; } ELSE
%printer { std::cerr << $$; } WHILE
%printer { std::cerr << $$; } FOR
%printer { std::cerr << $$; } STRING_LITERAL
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
   int nodeCount = 0;
   map<string,string> iden_type;
   map<string,IPL::Struct_Specifier*> get_structinfo;
   map<string,IPL::Fun_Declarator*> get_functioninfo;
   IPL::Function_Definition* curr_fun;
   IPL::SymbolTable  temp_gst;
   IPL::SymbolTable * temp_lst;
   int offset = 0;
   string curr_func_type = "";
   string curr_struct = "";
#undef yylex
#define yylex IPL::Parser::scanner.yylex
#define yyloc IPL::Parser::scanner.loc
}




%define api.value.type variant
%define parse.assert

%start complete_code



%token '\n'
%token <std::string> IDENTIFIER
%token <std::string> STRUCT
%token <std::string> VOID
%token <std::string> INT
%token <std::string> FLOAT
%token <std::string> INT_CONSTANT
%token <std::string> FLOAT_CONSTANT
%token <std::string> OR_OP
%token <std::string> AND_OP
%token <std::string> EQ_OP
%token <std::string> NE_OP
%token <std::string> LE_OP
%token <std::string> GE_OP
%token <std::string> INC_OP
%token <std::string> PTR_OP
%token <std::string> IF
%token <std::string> ELSE
%token <std::string> WHILE
%token <std::string> FOR
%token <std::string> STRING_LITERAL
%token <std::string> RETURN
%token <std::string> OTHERS
%token ',' ':' '(' ')' '+' '>' '<' '&' '-' '!' '/' ']' '[' '{' '}' ';' '*' '='



%nterm <int> complete_code
%nterm <Translation_Unit*> translation_unit
%nterm <Struct_Specifier*> struct_specifier
%nterm <Function_Definition*> function_definition
%nterm <Type_Specifier*> type_specifier
%nterm <Fun_Declarator*> fun_declarator
%nterm <Declaration_List*> declaration_list declaration parameter_list parameter_declaration
%nterm <Compound_Statement*> compound_statement
%nterm <Declarator*> declarator declarator_arr
%nterm <Declarator_List*> declarator_list
%nterm <seq_astnode*> statement_list
%nterm <statement_astnode*> statement selection_statement iteration_statement
%nterm <proccall_astnode*> procedure_call
%nterm <assignE_astnode*> assignment_expression
%nterm <assignS_astnode*> assignment_statement
%nterm <exp_astnode*> expression logical_and_expression equality_expression
%nterm <exp_astnode*> relational_expression additive_expression unary_expression multiplicative_expression postfix_expression primary_expression
%nterm <Expression_List*> expression_list
%nterm <op_unary_type> unary_operator   



%%
complete_code:
translation_unit {$1->print();}

translation_unit:
struct_specifier {

    
    $$ = new Translation_Unit();
    $$->add_struct_specifier(*$1);
    Symbol s = $$->get_gst().get_symbol_by_name("struct " + $1->get_name());
    
    if(s.get_name()!="") { error(@1,"Redclaration of struct");}
    
    iden_type[$1->get_name()] = "struct " + $1->get_name();
    //cout<<"struct " << $1->get_name() <<"size:"<<$1->get_size()<<endl;
    $$->add_global_symbol(Symbol("struct " + $1->get_name(), SymbolType::Struct, Scope::Global, "-", $1->get_size(), 0));   
    temp_gst = $$->get_gst();
}
| function_definition{
    $$ = new Translation_Unit();
    $$->add_function_definition(*$1);
    Symbol s = $$->get_gst().get_symbol_by_name($1->get_name());
    if(s.get_name()!=""){error(@1,"Redclaration of Function");}
    iden_type[$1->get_name()] = $1->get_type();
    $$->add_global_symbol(Symbol($1->get_name(), SymbolType::Function, Scope::Global, $1->get_type(), 0, 0)); 
    temp_gst = $$->get_gst();  
}
| translation_unit struct_specifier{
    $$ = $1;
    $$->add_struct_specifier(*$2);
    Symbol s = $$->get_gst().get_symbol_by_name("struct " + $2->get_name());
    if(s.get_name()!=""){error(@2,"Redclaration of struct");}
    iden_type[$2->get_name()] = "struct " + $2->get_name();
    $$->add_global_symbol(Symbol("struct " + $2->get_name(), SymbolType::Struct, Scope::Global, "-" , $2->get_size(), 0));   
    temp_gst = $$->get_gst();
}
| translation_unit function_definition {
    $$ = $1;
    $$->add_function_definition(*$2);
    Symbol s = $$->get_gst().get_symbol_by_name( $2->get_name() );
    if(s.get_name()!=""){error(@2 , "Redclaration of Function"); }
    iden_type[$2->get_name()] = $2->get_type();
    $$->add_global_symbol(Symbol($2->get_name(), SymbolType::Function, Scope::Global, $2->get_type(), 0, 0)); 
    temp_gst = $$->get_gst();
}

struct_specifier: 
STRUCT IDENTIFIER {curr_struct = $2 ; offset = 0; } '{' declaration_list '}' ';'{
    //temp_lst = new SymbolTable();
    $$ = new Struct_Specifier($2);
    // ToDo:
	int tot_size = 0; 
    std::vector<Symbol> symbols = $5->get_symbols();
    //cout<<$2<<":"<<endl;
    for(unsigned int i = 0; i< symbols.size(); i++){
        $$->add_symbol(symbols[i], offset);
        //cout<<"name : "<<symbols[i].get_name()<<" size : "<< symbols[i].get_size()<<endl;
        //cout<<"type : "<< symbols[i].get_type() <<endl;
		tot_size += symbols[i].get_size();
        offset += symbols[i].get_size(); 
        
    }
	$$->set_size(tot_size);
    
    //cout<<"size here : "<<$$->get_size()<<endl;
    get_structinfo["struct "+$2] = $$;
    curr_struct = "";
    //cout<<"THIS here"<<endl;
}

function_definition:
type_specifier {curr_func_type = $1->get_type();} fun_declarator { offset = 0;} compound_statement {
    

    $$ = new Function_Definition();
    $$->set_type($1->get_type());
    $$->set_name($3->get_name());
    
    std::vector<Symbol> symbols = $3->get_symbols();
    for(unsigned int i = 0; i< symbols.size(); i++){

       $$->add_symbol(symbols[i], symbols[i].offset);
    }
    
    symbols = $5->get_symbols();
    
    for(unsigned int i = 0; i< symbols.size(); i++){
        offset -= symbols[i].get_size(); 
        $$->add_symbol(symbols[i], offset);
        
    }
	
    $$->set_ast($5->get_ast());
    get_functioninfo[$3->get_name()] = $3;    
    temp_lst = nullptr;
    curr_func_type = "";
}

type_specifier: 
VOID { $$ = new Type_Specifier("void");$$->set_size(4);}
| INT {$$ = new Type_Specifier("int");$$->set_size(4);}
| FLOAT {$$ = new Type_Specifier("float");$$->set_size(4);}
| STRUCT IDENTIFIER {

if(temp_gst.get_symbol_by_name("struct "+$2).get_name()=="")
{
    if($2 != curr_struct){
        error(@2,"TYPE NOT DEFINED");
    }
}
$$ = new Type_Specifier("struct "+$2,$2);

if(get_structinfo["struct "+$2])$$->set_size(get_structinfo["struct "+$2]->get_size());
else $$->set_size(4);
//cout<<"Size of Struct "<<$2<<" = "<<$$->get_size()<<endl;
}

fun_declarator:
IDENTIFIER '('{ offset = 12;} parameter_list ')' {
    
    temp_lst = new SymbolTable();
    $$ = new Fun_Declarator($1);
    std::vector<Symbol> symbols = $4->get_symbols();
    
    for( int i = symbols.size()-1; i >= 0; i--){
        symbols[i].scope = Scope::Param;
        bool k = temp_lst->add_symbol(symbols[i]);
        if(!k) {error(@3,"MUltiple function parameters with same name");}
        $$->add_symbol(symbols[i], offset);
        offset += symbols[i].get_size();  
    }
    reverse(temp_lst->symbols.begin(),temp_lst->symbols.end());
    reverse($$->symbols.begin(),$$->symbols.end());



}
| IDENTIFIER '(' ')' {
    temp_lst = new SymbolTable();
    $$ = new Fun_Declarator($1);
    offset = 0;
}

parameter_list:
parameter_declaration {
    $$ = new Declaration_List();
    std::vector<Symbol> symbols = $1->get_symbols();
    for(unsigned int i = 0; i< symbols.size(); i++){
        $$->add_symbol(symbols[i]);
    }
}
| parameter_list ',' parameter_declaration{
	$$ = $1;
	vector<Symbol> symbols = $3->get_symbols();
	for(unsigned int i = 0; i < symbols.size();i++){
		$$->add_symbol(symbols[i]);
	}
}

parameter_declaration:
type_specifier declarator {
    $$ = new Declaration_List();
    std::vector<Declarator> declarators = {*$2};
    //ToDo: Add size to symbol
    for(unsigned int i = 0; i< declarators.size(); i++){
        //std::cout<<declarators[i].get_name()<<std::endl;
        iden_type[declarators[i].get_name()] = $1->get_type()+declarators[i].get_stars();
        
        int size = 0;
        if(declarators[i].get_stars()!="" and declarators[i].get_stars()[0]=='*'){size = 4*declarators[i].get_size();}
        else {size = declarators[i].get_size()*($1->get_size());}
        $$->add_symbol(Symbol(declarators[i].get_name(), SymbolType::Var, Scope::Local, $1->get_type()+ declarators[i].get_stars(), size, 0));
    }
}

declaration_list:
declaration {
    $$ = new Declaration_List();
    std::vector<Symbol> symbols = $1->get_symbols();
    for(unsigned int i = 0; i< symbols.size(); i++){
        
        $$->add_symbol(symbols[i]);
    }
}
| declaration_list declaration {
    $$ = $1;
    std::vector<Symbol> symbols = $2->get_symbols();
    for(unsigned int i = 0; i< symbols.size(); i++){
        
        $$->add_symbol(symbols[i]);
    }
}

declaration:
type_specifier declarator_list ';' {
    int size = 0;
    $$ = new Declaration_List();
    std::vector<Declarator> declarators = $2->get_declarators();
    //ToDo: Add size to symbol
    for(unsigned int i = 0; i< declarators.size(); i++){
        if($1->get_type()+declarators[i].get_stars() == "void") {error(@1,"void");}
        iden_type[declarators[i].get_name()] = $1->get_type()+declarators[i].get_stars();
        if(temp_lst){
            bool k = temp_lst->add_symbol(Symbol(declarators[i].get_name(), SymbolType::Var, Scope::Local, $1->get_type()+declarators[i].get_stars(), declarators[i].get_size()*($1->get_size()), 0));
            if(!k) {error(@1,"MUltiple function parameters with same name");}
        }
        if(declarators[i].get_stars() != "" and declarators[i].get_stars()[0] == '*'){size = 4*(declarators[i].get_size());}
        else { size = $1->get_size()*declarators[i].get_size();}
        
        //cout<<"Name  : "<<declarators[i].get_name()<<" here_size : "<<declarators[i].get_size()<<declarators[i]<<endl;
        $$->add_symbol(Symbol(declarators[i].get_name(), SymbolType::Var, Scope::Local, $1->get_type()+declarators[i].get_stars(), size, 0));
        //curr_offset += declarators[i].get_size()*size;
    } 
    
}

declarator_list:
declarator {
    $$ = new Declarator_List();

    $$->add_declarator(*$1);
}
| declarator_list ',' declarator {
    $$ = $1;
    $$->add_declarator(*$3);
}

declarator_arr:
IDENTIFIER {
    $$ = new Declarator($1,1);
    //cout<<"This one"<<$$->get_size()<<endl;
}
| declarator_arr '[' INT_CONSTANT ']' {
    $$ = $1;
    $$->set_size(stoi($3)*$$->get_size());
	$$->set_stars($$->get_stars()+"["+$3+"]");
}

declarator:
declarator_arr {
    $$ = $1;
}
| '*' declarator{
    $$ = $2;
    $$->set_stars("*"+$$->get_stars());
}

compound_statement:
'{' '}' { $$ = new Compound_Statement(); }
| '{' statement_list '}' {
    $$ = new Compound_Statement();
    $$->set_ast($2);
}
| '{' declaration_list '}' {
    $$ = new Compound_Statement();
    std::vector<Symbol> symbols = $2->get_symbols();
    
    for(unsigned int i = 0; i< symbols.size(); i++){
        
        $$->add_symbol(symbols[i]);
    }
}
| '{' declaration_list statement_list '}' {
    $$ = new Compound_Statement();
    $$->set_ast($3);
    std::vector<Symbol> symbols = $2->get_symbols();
    for(unsigned int i = 0; i< symbols.size(); i++){
        
        $$->add_symbol(symbols[i]);
    }

}

statement_list:
statement {
    $$ = new seq_astnode();
    $$->add_statement($1);
}
| statement_list statement{
    $$ = $1;
    $$->add_statement($2);
    
}

statement:
';' { $$ = new empty_astnode(); }
| '{' statement_list '}' { $$ = $2;}
| selection_statement { $$ = $1;}
| iteration_statement { $$ = $1;}
| assignment_statement { $$ = $1;}
| procedure_call { $$ = $1;}
| RETURN expression ';' 
{
    //cout<<"debugging this"<<curr_func_type<<"   "<<$2->val_type<<endl;
    if(temp_lst == nullptr){error(@1,"cannot return form non function");} 
    else if(curr_func_type == "int" and $2->val_type == "float"){
        //cout<<"Got here"<<endl;
        op_unary_astnode* temp = new op_unary_astnode($2,op_unary_type::TO_INT);
        
        $$ = new return_astnode(temp);
        
    }
    else if(curr_func_type == "float" and $2->val_type == "int"){
        op_unary_astnode* temp = new op_unary_astnode($2,op_unary_type::TO_FLOAT);
        $$ = new return_astnode(temp);
    }
    else if(curr_func_type != $2->val_type){
        error(@2,"Wrong return type current : " + curr_func_type +" got: "+$2->val_type);
    }
    else $$ = new return_astnode($2);
}

assignment_expression:
unary_expression '=' expression { 

    

    if($1->islval){
        if($1->val_type == $3->val_type){
            $$ = new assignE_astnode($1,$3);
        }
        else if($1->val_type == "int" and $3->val_type == "float"){
            op_unary_astnode* temp = new op_unary_astnode($3,op_unary_type::TO_INT);
            $$ = new assignE_astnode($1,temp);
        }
        else if($3->val_type == "int" and $1->val_type == "float"){
            op_unary_astnode* temp = new op_unary_astnode($3,op_unary_type::TO_FLOAT);
            $$ = new assignE_astnode($1,temp);
        }
        else {
            if($1->val_type == "int" and $3->get_derefrenced_type()!=""){
                $$ = new assignE_astnode($1,$3);
            }
            else if($1->get_derefrenced_type() != "" and $1->get_derefrenced_type().back() != ']'){
                //cout<<"this"<<endl;
                if($3->astnode_type == typeExp::intconst_astnode){
                exp_astnode * temp = $3;
                int val = temp->cval;
                if(val == 0){
                    $$ = new assignE_astnode($1,$3);
                }
                else{
                    error(@2,"Cannot assign this "+ $3->val_type + " to " + $1->val_type);
                }
                
            }
            
            else if($1->get_derefrenced_type() == "void"){
                if($3->get_derefrenced_type()!="")
                {
                    $$ = new assignE_astnode($1,$3);
                }
                else{
                    error(@2,"Cannot assign this"+ $3->val_type + " to " + $1->val_type);
                }
            }
            else if($3->get_derefrenced_type()=="void"){
                if($1->get_derefrenced_type()!="")
                {
                    $$ = new assignE_astnode($1,$3);
                }
                else{
                    error(@2,"Cannot assign this"+ $3->val_type + " to " + $1->val_type);
                }
                $$ = new assignE_astnode($1,$3);
            }
            else{
                //cout<<$1->val_type<<endl;
                if($1->get_derefrenced_type() == $3->get_derefrenced_type()){
                    $$ = new assignE_astnode($1,$3);
                }
                else{
                    error(@2,"Cannot assign this"+ $3->val_type + " to " + $1->val_type);
                }
            }
        }
        else if($1->val_type != $3->val_type){

            error(@2,"Cannot assign this"+ $3->val_type + " to " + $1->val_type);
        }
        
        }
    }
    else{
        error(@2,"Cannot assign to a non-lvalue");
    }
}

assignment_statement:
assignment_expression ';' { 
    
        $$ = new assignS_astnode($1->exp1,$1->exp2); 
    
}

procedure_call:
IDENTIFIER '(' ')' ';' {
    if($1!="printf" and $1!="scanf"){ 
        if(temp_gst.get_symbol_by_name($1).get_name() == "") {error(@1,"FUNCTION NOT DEFINED");}
        if(get_functioninfo[$1]->get_symbols().size() !=0 ){error(@1,"NOt Enough Arguments");}
    }
    $$ = new proccall_astnode($1); }
| IDENTIFIER '(' expression_list ')' ';' {
    if($1!="printf" and $1!="scanf"){
        if(temp_gst.get_symbol_by_name($1).get_name() == "") {error(@1,"FUNCTION NOT DEFINED");}
    }
    $$ = new proccall_astnode($1);
    unsigned int count = 0;
    std::vector<exp_astnode*> expressions = $3->get_expressions();
    for(unsigned int i = 0; i< expressions.size(); i++){
        if($1!="printf" and $1!="scanf"){

        string derefed = get_functioninfo[$1]->get_symbols()[i].get_deref_sem_type();
        string derefed2 = expressions[i]->get_derefrenced_type();
        if(get_functioninfo[$1]->get_symbols()[i].get_semantic_type()!=expressions[i]->val_type){
            if(get_functioninfo[$1]->get_symbols()[i].get_semantic_type() == "float" and expressions[i]->val_type == "int"){
                expressions[i] = new op_unary_astnode(expressions[i],op_unary_type::TO_FLOAT);
            }
            else if(get_functioninfo[$1]->get_symbols()[i].get_semantic_type() == "int" and expressions[i]->val_type == "float"){
                expressions[i] = new op_unary_astnode(expressions[i],op_unary_type::TO_INT);
            }
            else if((derefed == "void" or derefed2 == derefed) and derefed2 != ""){}
            else if((derefed2 == "void" or derefed2 == derefed) and derefed != ""){}
            
            else { error(@3,"type mistach" + get_functioninfo[$1]->get_symbols()[i].get_semantic_type() + " "+expressions[i]->val_type); }

        }
        }
        
        $$->add_argument(expressions[i]);
        count = count +1;
    }
    if($1!="printf" and $1!="scanf"){
    if(count != get_functioninfo[$1]->get_symbols().size()) {error(@1,"NOT ENough Arguments");}
    }
    

}

expression:
logical_and_expression { $$ = $1; }
| expression OR_OP logical_and_expression {
    //if(($1->val_type == "int" || $1->val_type == "float") && ($3->val_type == "int" || $3->val_type == "float"))
     if($1->val_type.substr(0,6)!="struct")
    {
        $$ = new op_binary_astnode($1,$3,op_binary_type::OR_OP);
        $$->val_type = "int";
    }
else {
    error(@1,"Operand is Struct");
    }
$$->islval=false;
}

logical_and_expression:
    equality_expression {$$ = $1;}
| logical_and_expression AND_OP equality_expression {
    if($1->val_type.substr(0,6)!="struct")
    {
        $$ = new op_binary_astnode($1,$3,op_binary_type::AND_OP);
        $$->val_type = "int";
    }
else {error(@1,"Operand is struct");}
$$->islval = false;
}
   
equality_expression:
relational_expression { $$ = $1; }
| equality_expression EQ_OP relational_expression {if($1->val_type == "int" && $3->val_type == "int"){$$ = new op_binary_astnode($1,$3,op_binary_type::EQ_OP_INT);$$->val_type = "int";}
else if($1->val_type == "int" && $3->val_type == "float") {exp_astnode * temp = new op_unary_astnode($1,op_unary_type::TO_FLOAT);  $$ = new op_binary_astnode(temp,$3,op_binary_type::EQ_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "int") {exp_astnode * temp = new op_unary_astnode($3,op_unary_type::TO_FLOAT);$$ = new op_binary_astnode($1,temp,op_binary_type::EQ_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "float"){$$ = new op_binary_astnode($1,$3,op_binary_type::EQ_OP_FLOAT);$$->val_type = "float";}
else if($1->get_derefrenced_type() != "" and $3->get_derefrenced_type()!= "" ){
    $$ = new op_binary_astnode($1,$3,op_binary_type::EQ_OP_INT);
    $$->val_type = "int";
}
else {error(@1,"type mis_match");}
$$->islval=false;
 }

| equality_expression NE_OP relational_expression {if($1->val_type == "int" && $3->val_type == "int"){$$ = new op_binary_astnode($1,$3,op_binary_type::NE_OP_INT);$$->val_type = "int";}
else if($1->val_type == "int" && $3->val_type == "float") {exp_astnode * temp = new op_unary_astnode($1,op_unary_type::TO_FLOAT);  $$ = new op_binary_astnode(temp,$3,op_binary_type::NE_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "int") {exp_astnode * temp = new op_unary_astnode($3,op_unary_type::TO_FLOAT);$$ = new op_binary_astnode($1,temp,op_binary_type::NE_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "float"){$$ = new op_binary_astnode($1,$3,op_binary_type::NE_OP_FLOAT);$$->val_type = "float";}
else if($1->get_derefrenced_type() != "" and $3->get_derefrenced_type()!= "" ){
    $$ = new op_binary_astnode($1,$3,op_binary_type::NE_OP_INT);
    $$->val_type = "int";
}
else {error(@1,"type mis_match");}
$$->islval=false;
}

relational_expression:
additive_expression { $$ = $1; }
| relational_expression '<' additive_expression {if($1->val_type == "int" && $3->val_type == "int"){$$ = new op_binary_astnode($1,$3,op_binary_type::LT_OP_INT);$$->val_type = "int";}
else if($1->val_type == "int" && $3->val_type == "float") {exp_astnode * temp = new op_unary_astnode($1,op_unary_type::TO_FLOAT);  $$ = new op_binary_astnode(temp,$3,op_binary_type::LT_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "int") {exp_astnode * temp = new op_unary_astnode($3,op_unary_type::TO_FLOAT);$$ = new op_binary_astnode($1,temp,op_binary_type::LT_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "float"){$$ = new op_binary_astnode($1,$3,op_binary_type::LT_OP_FLOAT);$$->val_type = "float";}
else if($1->get_derefrenced_type() != "" and $3->get_derefrenced_type()!= "" ){
    $$ = new op_binary_astnode($1,$3,op_binary_type::LT_OP_INT);
    $$->val_type = "int";
}
else {error(@1,"type mis_match");}

$$->islval=false;
 }

| relational_expression '>' additive_expression {if($1->val_type == "int" && $3->val_type == "int"){$$ = new op_binary_astnode($1,$3,op_binary_type::GT_OP_INT);$$->val_type = "int";}
else if($1->val_type == "int" && $3->val_type == "float") {exp_astnode * temp = new op_unary_astnode($1,op_unary_type::TO_FLOAT);  $$ = new op_binary_astnode(temp,$3,op_binary_type::GT_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "int") {exp_astnode * temp = new op_unary_astnode($3,op_unary_type::TO_FLOAT);$$ = new op_binary_astnode($1,temp,op_binary_type::GT_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "float"){$$ = new op_binary_astnode($1,$3,op_binary_type::GT_OP_FLOAT);$$->val_type = "float";}
else if($1->get_derefrenced_type() != "" and $3->get_derefrenced_type()!= "" ){
    $$ = new op_binary_astnode($1,$3,op_binary_type::GT_OP_INT);
    $$->val_type = "int";
}
else {error(@1,"type mis_match");}
$$->islval=false;
 }

| relational_expression LE_OP additive_expression {if($1->val_type == "int" && $3->val_type == "int"){$$ = new op_binary_astnode($1,$3,op_binary_type::LE_OP_INT);$$->val_type = "int";}
else if($1->val_type == "int" && $3->val_type == "float") {exp_astnode * temp = new op_unary_astnode($1,op_unary_type::TO_FLOAT);  $$ = new op_binary_astnode(temp,$3,op_binary_type::LE_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "int") {exp_astnode * temp = new op_unary_astnode($3,op_unary_type::TO_FLOAT);$$ = new op_binary_astnode($1,temp,op_binary_type::LE_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "float"){$$ = new op_binary_astnode($1,$3,op_binary_type::LE_OP_FLOAT);$$->val_type = "float";}
else if($1->get_derefrenced_type() != "" and $3->get_derefrenced_type()!= "" ){
    $$ = new op_binary_astnode($1,$3,op_binary_type::LE_OP_INT);
    $$->val_type = "int";
}
else {error(@1,"type mis_match");}
$$->islval=false;
 }

| relational_expression GE_OP additive_expression {if($1->val_type == "int" && $3->val_type == "int"){$$ = new op_binary_astnode($1,$3,op_binary_type::GE_OP_INT);$$->val_type = "int";}
else if($1->val_type == "int" && $3->val_type == "float") {exp_astnode * temp = new op_unary_astnode($1,op_unary_type::TO_FLOAT);  $$ = new op_binary_astnode(temp,$3,op_binary_type::GE_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "int") {exp_astnode * temp = new op_unary_astnode($3,op_unary_type::TO_FLOAT);$$ = new op_binary_astnode($1,temp,op_binary_type::GE_OP_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "float"){$$ = new op_binary_astnode($1,$3,op_binary_type::GE_OP_FLOAT);$$->val_type = "float";}
else if($1->get_derefrenced_type() != "" and $3->get_derefrenced_type()!= "" ){
    $$ = new op_binary_astnode($1,$3,op_binary_type::GE_OP_INT);
    $$->val_type = "int";
}
else {error(@1,"type mis_match");}
$$->islval=false;
 }

additive_expression:
multiplicative_expression { $$ = $1; }
| additive_expression '+' multiplicative_expression { 
    if($1->val_type == "int" && $3->val_type == "int"){$$ = new op_binary_astnode($1,$3,op_binary_type::PLUS_INT);$$->val_type = "int";}
else if($1->val_type == "int" && $3->val_type == "float") {exp_astnode * temp = new op_unary_astnode($1,op_unary_type::TO_FLOAT);  $$ = new op_binary_astnode(temp,$3,op_binary_type::PLUS_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "int") {exp_astnode * temp = new op_unary_astnode($3,op_unary_type::TO_FLOAT);$$ = new op_binary_astnode($1,temp,op_binary_type::PLUS_FLOAT);$$->val_type = "float";}
else if($1->val_type == "int" && ($3->val_type.back()=='*' or $3->val_type.back()==']')) {$$ = new op_binary_astnode($1,$3,op_binary_type::PLUS_INT) ; $$->val_type = $3->val_type; }
else if($3->val_type == "int" && ($1->val_type.back()=='*' or $1->val_type.back()==']')) {$$ = new op_binary_astnode($1,$3,op_binary_type::PLUS_INT) ; $$->val_type = $1->val_type; }
else if($1->val_type == "float" && $3->val_type == "float"){$$ = new op_binary_astnode($1,$3,op_binary_type::PLUS_FLOAT);$$->val_type = "float";}
else if(($3->val_type.back()=='*' or $3->val_type.back()==']') and ($1->val_type.back()=='*' or $1->val_type.back()==']')){$$ = new op_binary_astnode($1,$3,op_binary_type::PLUS_INT) ; $$->val_type = $1->val_type;}
else {error(@1,"type mis_match");}
$$->islval=false;
 }
| additive_expression '-' multiplicative_expression {if($1->val_type == "int" && $3->val_type == "int"){$$ = new op_binary_astnode($1,$3,op_binary_type::MINUS_INT);$$->val_type = "int";}
else if($1->val_type == "int" && $3->val_type == "float") {exp_astnode * temp = new op_unary_astnode($1,op_unary_type::TO_FLOAT);  $$ = new op_binary_astnode(temp,$3,op_binary_type::MINUS_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "int") {exp_astnode * temp = new op_unary_astnode($3,op_unary_type::TO_FLOAT);$$ = new op_binary_astnode($1,temp,op_binary_type::MINUS_FLOAT);$$->val_type = "float";}
else if($1->val_type == "int" && ($3->val_type.back()=='*' or $3->val_type.back()==']')) {$$ = new op_binary_astnode($1,$3,op_binary_type::MINUS_INT) ; $$->val_type = $3->val_type; }
else if($3->val_type == "int" && ($1->val_type.back()=='*' or $1->val_type.back()==']')) {$$ = new op_binary_astnode($1,$3,op_binary_type::MINUS_INT) ; $$->val_type = $1->val_type; }
else if($1->val_type == "float" && $3->val_type == "float"){$$ = new op_binary_astnode($1,$3,op_binary_type::MINUS_FLOAT);$$->val_type = "float";}
else if(($3->val_type.back()=='*' or $3->val_type.back()==']') and ($1->val_type.back()=='*' or $1->val_type.back()==']')){$$ = new op_binary_astnode($1,$3,op_binary_type::MINUS_INT) ; $$->val_type = $1->val_type;}
else {error(@1,"type mis_match");}
$$->islval=false;
 }

unary_expression:
postfix_expression { $$ = $1; }
| unary_operator unary_expression { 
$$ = new op_unary_astnode($2,$1); 

if($1 == op_unary_type::UMINUS){
    if($2->val_type == "int" or $2->val_type == "float"){
        $$->val_type = $2->val_type;
    }
    else {error(@1,"Operand Not Scalar");}
    $$->islval = false;
}
else if($1 == op_unary_type::NOT){
    if($2->val_type == "int" or $2->val_type == "float" or $2->get_derefrenced_type() != ""){
        $$->val_type = "int";
    }
    else {error(@1,"Operand Not Scalar");}
    $$->islval = false;
}
else if($1 == op_unary_type::ADDRESS){
    if($2->islval){
    string temp = $2->val_type;
    int index = temp.find('[');
    if(index!= (int) string::npos){
        temp.insert(index,"*");
    }
    else{
        temp = temp + "*";
    }
    $$->val_type = temp;
    $$->islval = false;
    }
    else{
        error(@2,"Operater of & should have an lvalue");
    }
}
else if($1 == op_unary_type::DEREF){
    if($2->val_type.back()=='*'){
        $$->val_type = $2->val_type.substr( 0, $2->val_type.length()-1);
    }
    else {error(@1,"Not A refrence");}
    $$->islval = true;
}
else if($1 == op_unary_type::TO_INT){
    if($2->val_type != "int" or $2->val_type != "float"){
        error(@2,"Operand should be int or float recieved " + $2->val_type);
    }
    $$->val_type = "int";
    $$->islval = true;
}
else if($1 == op_unary_type::TO_FLOAT){
    if($2->val_type != "int" or $2->val_type != "float"){
        error(@2,"Operand should be int or float recieved " + $2->val_type);
    }
    $$->val_type = "float";
    $$->islval = true;
}
else if($1 == op_unary_type::PP){
    
}
else{
    error(@2,"Invalid Unary Operator");
}
}

multiplicative_expression:
unary_expression {$$ = $1;}
| multiplicative_expression '*' unary_expression {if($1->val_type == "int" && $3->val_type == "int"){$$ = new op_binary_astnode($1,$3,op_binary_type::MULT_INT);$$->val_type = "int";}
else if($1->val_type == "int" && $3->val_type == "float") {exp_astnode * temp = new op_unary_astnode($1,op_unary_type::TO_FLOAT);  $$ = new op_binary_astnode(temp,$3,op_binary_type::MULT_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "int") {exp_astnode * temp = new op_unary_astnode($3,op_unary_type::TO_FLOAT);$$ = new op_binary_astnode($1,temp,op_binary_type::MULT_FLOAT);$$->val_type = "float";}
else if($1->val_type == "float" && $3->val_type == "float"){$$ = new op_binary_astnode($1,$3,op_binary_type::MULT_FLOAT);$$->val_type = "float";}
else {error(@1,$1->val_type+" "+$3->val_type);}
$$->islval=false;
 }

| multiplicative_expression '/' unary_expression {
if($1->val_type == "int" && $3->val_type == "int"){
    $$ = new op_binary_astnode($1,$3,op_binary_type::DIV_INT);
    $$->val_type = "int";
}
else if($1->val_type == "int" && $3->val_type == "float")
{
    exp_astnode * temp = new op_unary_astnode($1,op_unary_type::TO_FLOAT);
    $$ = new op_binary_astnode(temp,$3,op_binary_type::DIV_FLOAT);
    $$->val_type = "float";
}
else if($1->val_type == "float" && $3->val_type == "int")
{
    exp_astnode * temp = new op_unary_astnode($3,op_unary_type::TO_FLOAT);
    $$ = new op_binary_astnode($1,temp,op_binary_type::DIV_FLOAT);
    $$->val_type = "float";
}
else if($1->val_type == "float" && $3->val_type == "float"){
    $$ = new op_binary_astnode($1,$3,op_binary_type::DIV_FLOAT);
    $$->val_type = "float";
}
else 
{
    error(@1,"type mis_match Operend 1: "+$1->val_type + " Operand 2: "+$3->val_type);
}
$$->islval=false;
}


postfix_expression:
primary_expression { $$ = $1; }
| postfix_expression '[' expression ']' 
{ 
    string derefed_tpye = $1->get_derefrenced_type();
    if(derefed_tpye == ""){
        error(@1,"First OPerand of [] should be pointer or array. Recieved type : " +  $1->val_type);
    }
    else if($3->val_type != "int")
    {
        error(@3,"Array subscript is not an integer");
    }
    else{
    
        $$ = new arrayref_astnode($1,$3); 
    
        $$->val_type =derefed_tpye;
        $$->islval = true;
    
    }
}
| IDENTIFIER '(' ')' {
    if(temp_gst.get_symbol_by_name($1).get_name() == ""){error(@1,"FUNCTION NOT DEFINED");}
    if(get_functioninfo[$1]->get_symbols().size() !=0 ){error(@1,"NOt Enough Arguments");} 
    $$ = new funcall_astnode($1); 
    $$->val_type = iden_type[$1];
    $$->islval = "false";
}
| IDENTIFIER '(' expression_list ')' {
    if(temp_gst.get_symbol_by_name($1).get_name() == "") {error(@1,"FUNCTION NOT DEFINED");}
    
    std::vector<exp_astnode*> expressions = $3->get_expressions();
    //$$ = new funcall_astnode($1);
    
	funcall_astnode* output = new funcall_astnode($1);
    if(expressions.size() != get_functioninfo[$1]->get_symbols().size()) {error(@1,"NOT ENough Arguments");}
    for (unsigned int i = 0; i < expressions.size(); i++) {

            if(get_functioninfo[$1]->get_symbols()[i].get_semantic_type() == expressions[i]->val_type){
                output->add_argument(expressions[i]);
            }
            else if(get_functioninfo[$1]->get_symbols()[i].get_semantic_type() == "float" and expressions[i]->val_type == "int"){
                expressions[i] = new op_unary_astnode(expressions[i],op_unary_type::TO_FLOAT);
                output->add_argument(expressions[i]);
                
            }
            else if(get_functioninfo[$1]->get_symbols()[i].get_semantic_type() == "int" and expressions[i]->val_type == "float"){
                expressions[i] = new op_unary_astnode(expressions[i],op_unary_type::TO_INT);
                output->add_argument(expressions[i]);
                
            }
            else if(get_functioninfo[$1]->get_symbols()[i].get_semantic_type() == expressions[i]->val_type){
                output->add_argument(expressions[i]);
                
            }
            else { error(@3,"type mistach " + get_functioninfo[$1]->get_symbols()[i].get_semantic_type() + " "+expressions[i]->val_type); }

        

        
    }
    
	$$ = output;
    $$->val_type = iden_type[$1];
    $$->islval = true;
}

| postfix_expression '.' IDENTIFIER 
{
    if($1->val_type.substr(0,6) != "struct" or $1->get_derefrenced_type()!="")
    {
        error(@1,"First operand of . should be a struct got " + $1->get_derefrenced_type());
    } 
    Symbol S = get_structinfo[$1->val_type]->get_lst().get_symbol_by_name($3); 
    if(S.get_name()=="")
    {
        error(@1,"Identidier : "+ $3 + " Not Declared");
    } 
    $$ = new member_astnode($1,new identifier_astnode($3));
    $$->val_type = S.get_semantic_type();
    $$->islval = true;
}
| postfix_expression PTR_OP IDENTIFIER 
{ 
    if($1->get_derefrenced_type().substr(0,6) != "struct")
    {
        error(@1,"First Operand of -> should be pointer to a struct ");
    }
    //cout<<$1->val_type.substr(0,$1->val_type.length()-1)<<endl;
    Symbol S = get_structinfo[$1->get_derefrenced_type()]->get_lst().get_symbol_by_name($3);
    $$ = new arrow_astnode($1,new identifier_astnode($3)); 
    $$->val_type = S.get_semantic_type();
    $$->islval = true;
}
| postfix_expression INC_OP { 
    if($1->islval){
    if($1->val_type!="int" and $1->val_type != "float" and $1->get_derefrenced_type() == ""){
        error(@1,"Operand of ++ must be int , float or pointer");
    } 
    $$ = new op_unary_astnode($1,op_unary_type::PP);
    $$->val_type = $1->val_type;
    $$->islval = false;

    }
    else{
        error(@1,"Operand of ++ must be an lvalue");
    }
}

primary_expression:
IDENTIFIER { 
    Symbol S = temp_lst->get_symbol_by_name($1); 
    //cout<<temp_lst->get_name()<<endl;
    if(S.get_name()==""){error(@1,"NOT DECLARED "+$1);} $$ = new identifier_astnode($1); 
    $$->val_type = iden_type[$1];
    $$->islval = true;
}
| INT_CONSTANT { 
    $$ = new intconst_astnode(stoi($1));
    $$->val_type = "int"; 
    $$->islval = false;
    $$->cval = stoi($1);
}
| FLOAT_CONSTANT { 
    $$ = new floatconst_astnode(stof($1));
    $$->val_type = "float";
    $$->islval = false;
    
}
| STRING_LITERAL { 
    $$ = new stringconst_astnode($1);
    $$->val_type = "string";
    $$->islval = false;
}
| '(' expression ')' { $$ = $2; $$->val_type = $2->val_type; }

expression_list:
expression { $$ = new Expression_List(); $$->add_expression($1); }
| expression_list ',' expression { $$ = $1; $$->add_expression($3); }

unary_operator:
'-' { $$ = op_unary_type::UMINUS;  }
| '!' { $$ = op_unary_type::NOT; }
| '&' { $$ = op_unary_type::ADDRESS; }
| '*' { $$ = op_unary_type::DEREF; }

selection_statement:
IF '(' expression ')' statement ELSE statement { $$ = new if_astnode($3,$5,$7); }

iteration_statement:
WHILE '(' expression ')' statement { $$ = new while_astnode($3,$5); }
| FOR '(' assignment_expression ';' expression ';' assignment_expression ')' statement { 

	exp_astnode* a1 = $3;
	exp_astnode* a2 = $7;
	$$ = new for_astnode(a1,$5,a2,$9); 
}


%%
void IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cout << "Error at line " << l.begin.line <<": " <<err_message <<"\n";
   exit(1);
}



