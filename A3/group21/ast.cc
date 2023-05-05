#include "ast.hh"
#include "bits/stdc++.h"

namespace IPL{
    

    string op_binary_map(op_binary_type e){
    switch(e){
        case op_binary_type::PLUS_INT    : return   "PLUS_INT"    ;     
        case op_binary_type:: MINUS_INT  : return   "MINUS_INT"   ;
        case op_binary_type::MULT_INT    : return   "MULT_INT"    ;
        case op_binary_type::DIV_INT     : return   "DIV_INT"     ;
        case op_binary_type::MINUS_FLOAT : return   "MINUS_FLOAT" ;
        case op_binary_type::MULT_FLOAT  : return   "MULT_FLOAT"  ;
        case op_binary_type::PLUS_FLOAT  : return   "PLUS_FLOAT"  ;
        case op_binary_type::DIV_FLOAT   : return   "DIV_FLOAT"   ;
        case op_binary_type::OR_OP       : return   "OR_OP"       ;     
        case op_binary_type::AND_OP      : return   "AND_OP"      ;
        case op_binary_type::EQ_OP_INT   : return   "EQ_OP_INT"   ;
        case op_binary_type::NE_OP_INT   : return   "NE_OP_INT"   ;
        case op_binary_type::LT_OP_INT   : return   "LT_OP_INT"   ;
        case op_binary_type::LE_OP_INT   : return   "LE_OP_INT"   ;
        case op_binary_type::GT_OP_INT   : return   "GT_OP_INT"   ;
        case op_binary_type::GE_OP_INT   : return   "GE_OP_INT"   ;
        case op_binary_type::EQ_OP_FLOAT : return   "EQ_OP_FLOAT" ;
        case op_binary_type::NE_OP_FLOAT : return   "NE_OP_FLOAT" ;
        case op_binary_type::LT_OP_FLOAT : return   "LT_OP_FLOAT" ;
        case op_binary_type::LE_OP_FLOAT : return   "LE_OP_FLOAT" ;
        case op_binary_type::GT_OP_FLOAT : return   "GT_OP_FLOAT" ;
        case op_binary_type::GE_OP_FLOAT : return   "GE_OP_FLOAT" ;

    }
    return "ERRORF";
}


string op_unary_map(op_unary_type e){
    switch (e) {
        case op_unary_type::TO_INT   : return "TO_INT"  ;    
        case op_unary_type::TO_FLOAT : return "TO_FLOAT";
        case op_unary_type::UMINUS   : return "UMINUS"  ;
        case op_unary_type::NOT      : return "NOT"     ;
        case op_unary_type::ADDRESS  : return "ADDRESS" ;
        case op_unary_type::DEREF    : return "DEREF"   ;
        case op_unary_type::PP       : return "PP"      ;    
    }
    return "ERROR\n";
}

bool comparebyname(const Function_Definition&a , const Function_Definition&b){
    return a.name < b.name;
}
bool symbolsort(const Symbol &a , const Symbol &b){
    return a.name < b.name;
}

    //AST classes
    empty_astnode :: empty_astnode (){
        astnode_type = typeExp::empty_astnode;
    }
    void empty_astnode::print(int blanks){
        //cout<<string(blanks,' ')
        cout<<"\"empty\""<<endl;
    }

    seq_astnode :: seq_astnode(){
        astnode_type = typeExp::seq_astnode;
    }
    void seq_astnode:: print(int blanks){
        
        //cout<<string(blanks,' ')<<"\"seq\" : ["<<endl;
        cout<<"{"<<endl;
        cout<<"\"seq\" : ["<<endl;
        for (unsigned int i =0; i<s1.size() ;i++){
            s1[i]->print(blanks+4);
            if(i!=s1.size()-1){
                cout<<",";
            }
        }
        cout<<"]\n";
        cout<<"}"<<endl;
    }
    void seq_astnode::add_statement(statement_astnode* s){
        s1.push_back(s);
    }

    //assignS_astnode

    assignS_astnode::assignS_astnode(exp_astnode* exp1, exp_astnode* exp2){
        astnode_type=typeExp::assignS_astnode;
        e1 = exp1;
        e2 = exp2;
    }
    void assignS_astnode::print(int blanks){
        //cout<<string(blanks,' ')<<"\"assignS\" : {"<<endl;
        cout<<"{"<<endl;
        cout<<"\"assignS\" : {"<<endl;
        cout<<"\"left\" : ";e1->print(blanks+4);cout<<",\n";
        cout<<"\"right\" : ";e2->print(blanks+4);cout<<"\n";
        cout<<"}\n}\n";
    }
    string exp_astnode::get_derefrenced_type(){
        string s = val_type;
        int i = 0;
        bool tr = false;
        for(i = s.length()-1;i>=0;i--){
            if(s[i] == '*' or s[i]=='['){
                tr = true;
                break;
            }
        
        }
        if(tr) s = s.substr(0,i);
        else s = "";
        return s;
    }
    //if_astnode
    if_astnode::if_astnode(exp_astnode* c, statement_astnode* t,statement_astnode*e){
        astnode_type = typeExp::if_astnode;
        cond_ = c;
        then_ = t;
        else_ = e;
    } 
    void if_astnode::print(int blanks){
        //cout<<string(blanks,' ')
        cout<<"{\n";
        cout<<"\"if\": {"<<endl;
        cout<<"\"cond\":\n";
        cond_->print(blanks+4);
        cout<<",\n";
        cout<<"\"then\":\n ";
        then_->print(blanks+4);
        cout<<",\n";
        cout<<"\"else\":\n ";
        else_->print(blanks+4);
        cout<<"}\n}\n";    
    }

    //while_astnode
    while_astnode::while_astnode(exp_astnode* s,statement_astnode* b){
        astnode_type=typeExp::while_astnode;
        cond_ = s;
        body_ = b;
    }
    void while_astnode::print(int blanks){
        //cout<<string(blanks,' ')
        cout<<"{\n";
        cout<<"\"while\": {"<<endl;
        cout<<"\"cond\":\n";
        cond_->print(blanks+4);
        cout<<",\n";
        cout<<"\"stmt\":\n ";
        body_->print(blanks+4);
        cout<<"}\n}\n";
    }
    //for 
    for_astnode::for_astnode(exp_astnode* i, exp_astnode* c, exp_astnode* u,statement_astnode* b){
        astnode_type=typeExp::for_astnode;
        init_   =   i;
        cond_   =   c;
        update_ =   u;
        body_   =   b;
    } 

    void for_astnode::print(int blanks){
        //cout<<string(blanks,' ')
        cout<<"{\n";
        cout<<"\"for\": {"<<endl;
        cout<<"\"init\":\n";
        init_->print(blanks+4);
        cout<<",\n";
        cout<<"\"guard\":\n ";
        cond_->print(blanks+4);
        cout<<",\n";
        cout<<"\"step\":\n ";
        update_->print(blanks+4);
        cout<<",\n";
        cout<<"\"body\":\n ";
        body_->print(blanks+4);
        cout<<"}\n}\n";
    }

    //return
    return_astnode::return_astnode(exp_astnode* exp){
        astnode_type = typeExp::return_astnode;
        e1 = exp;
        
        
    }
    void return_astnode:: print(int blanks){
        cout<<"{\n";
        cout<< string(blanks,' ');
        cout<<"\"return\":" << endl;
        e1->print(blanks+4);
        cout<<"}\n";
    }

    //procall
    proccall_astnode:: proccall_astnode(string name){
        astnode_type = typeExp::proccall_astnode;
        this->name = name;
        this->args = vector<exp_astnode*>();

    }
    void proccall_astnode:: print(int blanks){
        cout<<"{\n";
        cout<<string(blanks,' ')<< "\"proccall\": {\n";
        cout<<string(blanks+4,' ')<< "\"fname\": {\n";
        cout<<string(blanks+8,' ')<< "\"identifier\": \""<<name<<"\""<<endl;
        cout<<string(blanks+4,' ')<< "},\n"; 
        cout<<string(blanks+4,' ')<< "\"params\": [\n";
        for(unsigned int i = 0;i<args.size();i++){
            cout <<string(blanks+8,' ')<< "\n";
            args[i]->print(blanks+12);
            
            if(i!=args.size()-1){
                cout<<",";
            }
            cout<<"\n";
        }
        cout<<"]\n}\n}\n";
    }
    void proccall_astnode::add_argument(exp_astnode* argument){
        args.push_back(argument);
    }

    op_binary_astnode::op_binary_astnode(exp_astnode* e1, exp_astnode* e2,op_binary_type op){
        astnode_type = typeExp::op_binary_astnode;
        this->exp1 = e1;
        this->exp2 = e2;
        this->op = op;
    }
    void op_binary_astnode::print(int blanks){
        //cout<< string(blanks,' ')
        cout<<"{\n";
        cout<<"\"op_binary\": {" << endl;
        //cout<<string(blanks+4,' ')
        cout<<"\"op\": \""<<op_binary_map(op)<<"\"\n,\n";
        cout<<"\"left\":\n";
        exp1 -> print(blanks+4);
        cout<<"\n,\n\"right\":\n";
        exp2 -> print(blanks+4);
        cout<<"}\n}\n";
        //<<endl;
    }

    op_unary_astnode::op_unary_astnode(exp_astnode* e1,op_unary_type op){
        astnode_type = typeExp::op_unary_astnode;
        //cout<<"{op:";
        this->op = op;
        //cout<<"},";
        this->exp1 = e1;     
    }
    void op_unary_astnode::print(int blanks){
        
        //cout<< string(blanks,' ')
        cout<<"{\n";
        cout<<"\"op_unary\": {" << endl;
        //cout<<string(blanks+4,' ')
        cout<<"\"op\": \""<<op_unary_map(op)<<"\","<<endl;
        cout<<"\"child\":\n";
        exp1 -> print(blanks+4);
        cout<<"}";
        cout<<"}";
    }

    intconst_astnode::intconst_astnode(int value){
        astnode_type = typeExp::intconst_astnode;
        val = value;
    }
    void intconst_astnode::print(int blanks){
        //cout<<string(blanks,' ')
        cout<<"{\n";
        cout<<"\"intconst\" : " << val <<endl;
        cout<<"}\n";
    }

    floatconst_astnode::floatconst_astnode(float value){
        astnode_type = typeExp::floatconst_astnode;
        val = value;
    }
    void floatconst_astnode::print(int blanks){
        //cout<<string(blanks,' ')
        cout<<"{\n";
        cout<<"\"floatconst\" : "<< val <<endl;
        cout<<"}\n";
    }

    stringconst_astnode::stringconst_astnode(string value){
        astnode_type = typeExp::stringconst_astnode;
        val = value;
    }
    void stringconst_astnode::print(int blanks){
        //cout<<string(blanks,' ')
        cout<<"{\n";
        cout<<"\"stringconst\" : "<< val <<endl;
        cout<<"}\n";
        //cout<<string(blanks+4,' ')<<"Value: "<<val <<endl;
    }
    
    assignE_astnode::assignE_astnode(exp_astnode* exp1, exp_astnode* exp2){
        astnode_type=typeExp::assignE_astnode;
        this->exp1 = exp1;
        this->exp2 = exp2;
    }
    void assignE_astnode::print(int blanks){
        cout<<"{\n";
        cout<<string(blanks,' ')<<"\"assignE\": {"<<endl;
        cout<<"\"left\":\n";
        exp1->print(blanks+4);
        cout<<"\n,\n\"right\":\n";
        exp2->print(blanks+4);
        cout<<"}";
        cout<<"\n}\n";
    }

    //funcall
    funcall_astnode:: funcall_astnode(string name){
        astnode_type = typeExp::funcall_astnode;
        this->name = name;
        this->args = vector <exp_astnode*> ();

    }
    void funcall_astnode:: print(int blanks){
        //cout<< string(blanks,' ')
        cout<<"{\n";
        cout<<"\"funcall\": {\n\"fname\": {\n\"identifier\": \"";
        
        //cout<< string(blanks+4,' ')
        cout<<name <<"\""<< endl << "}," <<endl<<"\"params\": ["<<endl;
        for(unsigned int i = 0;i<args.size();i++){
            args[i]->print(blanks+4);
            if (i != args.size()-1){
                cout << ",";
            }
            cout << "\n";
        }
        cout<<"]\n}\n}\n";
    }
    void funcall_astnode::add_argument(exp_astnode* argument){
        args.push_back(argument);
    }

    identifier_astnode:: identifier_astnode(string name){
        astnode_type = typeExp::identifier_astnode;
        this->name = name;
    }
    void identifier_astnode:: print(int blanks){
        //cout<< string(blanks,' ')
        cout<<"{\n";
        cout<<"\"identifier\":";
        cout<<"\""<<name<<"\"" << endl; 
        cout<<"}\n";     
    }

    // member_astnode Class Methods
    member_astnode::member_astnode(exp_astnode* expression, identifier_astnode* name) {
        astnode_type = typeExp::member_astnode;
        this->expression = expression;
        this->name = name;
    }
    void member_astnode::print(int blanks) {
        //std::cout << std::string(blanks, ' ')
        cout<<"{\n";
        cout<< "\"member\" : {" << std::endl << "\"struct\": \n";
        this->expression->print(blanks + 4);
        cout<<",\n\"field\": \n";
        this->name->print(blanks + 4);
        cout<<"}\n}\n";
    }

    // array_astnode Class Methods
    arrayref_astnode::arrayref_astnode(exp_astnode* expression1, exp_astnode* expression2) {
        astnode_type = typeExp::arrayref_astnode;
        this->expression1 = expression1;
        this->expression2 = expression2;
    }
    void arrayref_astnode::print(int blanks) {
        //std::cout << std::string(blanks,' ')
        cout<<"{\n";
        cout << "\"arrayref\": {\n" <<std::endl;
        cout << "\"array\": \n" <<std::endl;
        expression1->print(blanks + 4);
        cout<<",\n";
        cout << "\"index\": \n" <<std::endl;
        expression2->print(blanks + 4);
        cout<<"}\n";
        cout<<"}\n";
    }

    // arrow_astnode Class Methods
    arrow_astnode::arrow_astnode(exp_astnode* expression, identifier_astnode* name) {
        astnode_type = typeExp::arrow_astnode;
        this->expression = expression;
        this->name = name;
    }
    void arrow_astnode::print(int blanks) {
        //std::cout << std::string(blanks,' ')
        cout<<"{\n";
        std::cout << "\"arrow\":{\n" <<std::endl;
        std::cout << "\"pointer\":\n";
        this->expression->print(blanks + 4);
        std::cout << "\n,";
        std::cout << "\"field\":\n";
        this->name->print(blanks + 4);
        std::cout << "}\n}\n";
    }


    //Symbol Class Methods
    Symbol::Symbol(std::string name, SymbolType type, Scope scope, std::string semantic_type, int size, int offset) {
        this->name = name;
        this->type = type;
        this->scope = scope;
        this->semantic_type = semantic_type;
        this->size = size;
        this->offset = offset;
    }
    std::string Symbol ::get_name() {
        return this->name;
    }
    SymbolType Symbol::get_type() {
        return this->type;
    }
    Scope Symbol::get_scope() {
        return this->scope;
    }
    std::string Symbol::get_type_name() {
        switch(this->type) {
            case SymbolType::Var:
                return "var";
            case SymbolType::Const:
                return "const";
            case SymbolType::Function:
                return "fun";
            case SymbolType::Struct:
                return "struct";
            default:
                return "unknown";       
        }
    }
    std::string Symbol::get_scope_name() {
        switch(this->scope) {
            case Scope::Global:
                return "global";
            case Scope::Local:
                return "local";
            case Scope::Param:
                return "param";
            default:
                return "unknown";       
        }
    }
    std::string Symbol::get_semantic_type() {
        return this->semantic_type;
    }
    std::string Symbol::get_deref_sem_type()
    {
        string s = this->semantic_type;
        int i = 0;
        bool tr = false;
        for(i = s.length()-1;i>=0;i--){
            if(s[i] == '*' or s[i]=='['){
                tr = true;
                break;
            }
        
        }
        if(tr) s = s.substr(0,i);
        else s = "";
        return s;
    }
    int Symbol::get_size() {
        return this->size;
    }
    int Symbol::get_offset() {
        return this->offset;
    }

    // SymbolTable Class Methods
    SymbolTable::SymbolTable() {
        this->symbols = std::vector<Symbol>();
    }
    bool SymbolTable::add_symbol(Symbol symbol) {
        Symbol s = get_symbol_by_name(symbol.get_name());
        if(s.get_name()!=""){return false;}
        this->symbols.push_back(symbol);
        return true;
    }
    Symbol SymbolTable::get_symbol(int index) {
        return this->symbols[index];
    }
    int SymbolTable::get_size() {
        return symbols.size();
    }
    Symbol SymbolTable::get_symbol_by_name(std::string name) {
        for(unsigned int i = 0; i < this->symbols.size(); i++) {
            if(this->symbols[i].get_name() == name) {
                return this->symbols[i];
            }
        }
        return Symbol("", SymbolType::Var, Scope::Global, "", 0, 0);
    }
    void SymbolTable::print() {
        //std::cout << "[";
        sort(symbols.begin(),symbols.end(),symbolsort);
        for(unsigned int i = 0; i<this->symbols.size(); i++){
            std::cout << "\t\t[\n";
            std::cout << "\"" << this->symbols[i].get_name() << "\",";
            std::cout << "\"" << this->symbols[i].get_type_name() << "\",";
            std::cout << "\"" << this->symbols[i].get_scope_name() << "\",";
            std::cout << "" << this->symbols[i].get_size() << ",";
            if(this->symbols[i].get_type_name() != "struct")std::cout << "" << this->symbols[i].get_offset() << ",";
            else std::cout << "" << "\"-\"" << ",";
            std::cout << "\"" << this->symbols[i].get_semantic_type() << "\"";
            if (i == this->symbols.size() - 1) {
                std::cout << "\n]";
            }
            else {
                std::cout << "\n],\n";
            }
        }
        //std::cout << "]\n";
    }

    // Translation-Unit Class Methods
    Translation_Unit::Translation_Unit() {
        gst = SymbolTable();
        struct_specifiers = std::vector<Struct_Specifier>();
        function_definitions = std::vector<Function_Definition>();    
    }
    void Translation_Unit::add_struct_specifier(Struct_Specifier struct_specifier) {
        struct_specifiers.push_back(struct_specifier);
    }
    void Translation_Unit::add_function_definition(Function_Definition function_definition) {
        function_definitions.push_back(function_definition);
    }
    void Translation_Unit::add_global_symbol(Symbol symbol) {
        gst.add_symbol(symbol);
    }
    void Translation_Unit::add_global_symbol2(Symbol symbol){
        gst2.add_symbol(symbol);
    }
    void Translation_Unit::print() {
        
        std::cout << "{";
        std::cout << "\"globalST\":\n";
        std::cout << "[";
        gst.print();
        //std::cout<<",\n";
        //gst2.print();
        std::cout << "\n]\n,\n";
        std::cout << "  \"structs\": [" << std::endl;
        for(unsigned int i = 0; i<struct_specifiers.size(); i++){
            std::cout << "{\n";
            std::cout << "\"name\": " << "\"struct " << struct_specifiers[i].get_name() << "\",\n";
            //std::cout << "\t\t\t\"" << struct_specifiers[i].get_size() << "\",";
            std::cout << "\"localST\": " << std::endl;
            std::cout << "[\n";
            struct_specifiers[i].get_lst().print();
            std::cout << "\n]\n}";
            if (i != struct_specifiers.size() - 1) {
                std::cout << ",";
            }
            std::cout << std::endl;
        }
        std::cout << "]\n," << std::endl;
        std::cout << "\"functions\": [" << std::endl;
        sort(function_definitions.begin(),function_definitions.end(),comparebyname);
        for( unsigned int i =0; i < function_definitions.size(); i++) {
            std::cout << "{\n";
            std::cout << "\"name\": \"" << function_definitions[i].get_name() << "\",";
            //std::cout << "\t\t\t\"type\": \"" << function_definitions[i].get_type() << "\",";
            std::cout << "\"localST\": " << std::endl;
            std::cout << "[\n";
            function_definitions[i].get_lst().print();
            std::cout << "],\n";
            std::cout << "\"ast\": " << std::endl;
            function_definitions[i].get_ast()->print(4);
            std::cout << "}\n";
            if (i !=function_definitions.size() - 1) {
                std::cout << ",";
            }
            std::cout << std::endl;
        }
        std::cout << "]\n";
        std::cout << "}" << std::endl;
    }
    SymbolTable Translation_Unit::get_gst() {
        return gst;
    }

    // Struct_Specifier Class Methods
    Struct_Specifier::Struct_Specifier() {
        this->name = "";
        this->lst = SymbolTable();
    }
    Struct_Specifier::Struct_Specifier(std::string name) {
        this->name = name;
        this->lst = SymbolTable();
    }
    string Struct_Specifier::get_name() {
        return this->name;
    }
    SymbolTable Struct_Specifier::get_lst() {
        return this->lst;
    }
    int Struct_Specifier::get_size() {
        return this->size;
    }
    void Struct_Specifier::add_symbol(Symbol symbol, int offset) {
        symbol.offset = offset;
        this->lst.add_symbol(symbol);
    }
    void Struct_Specifier::set_name(std::string name) {
        this->name = name;
    }
    void Struct_Specifier::set_size(int size) {
        this->size = size;
    }

    // Function_Definition Class Methods
    Function_Definition::Function_Definition() {
        this->name = "";
        this->type = "";
        this->lst = SymbolTable();
    }
    Function_Definition::Function_Definition(std::string name, std::string type) {
        this->name = name;
        this->type = type;
        this->lst = SymbolTable();
    }
    std::string Function_Definition::get_name() {
        return this->name;
    }
    std::string Function_Definition::get_type() {
        return this->type;
    }
    SymbolTable Function_Definition::get_lst() {
        return this->lst;
    }
    void Function_Definition::add_symbol(Symbol symbol, int offset) {
        symbol.offset = offset;
        this->lst.add_symbol(symbol);
    }
    void Function_Definition::set_name(std::string name) {
        this->name = name;
    }
    void Function_Definition::set_type(std::string type) {
        this->type = type;
    }
    void Function_Definition::set_gst(SymbolTable gst) {
        this->gst = gst;
    }
    SymbolTable Function_Definition::get_gst() {
        return this->gst;
    }
    void Function_Definition::set_ast(seq_astnode* ast) {
        this->ast = ast;
    }
    seq_astnode* Function_Definition::get_ast() {
        return this->ast;
    }

    // Type_Specifier Class Methods
    Type_Specifier::Type_Specifier() {
        this->type = "";
        this->name = "";
    }
    Type_Specifier::Type_Specifier(std::string type) {
        this->type = type;
        this->name = "";
    }
    Type_Specifier::Type_Specifier(std::string type, std::string name) {
        this->type = type;
        this->name = name;
    }
    std::string Type_Specifier::get_type() {
        return this->type;
    }
    std::string Type_Specifier::get_name() {
        return this->name;
    }
    void Type_Specifier::set_type(std::string type) {
        this->type = type;
    }
    void Type_Specifier::set_name(std::string name) {
        this->name = name;
    }
    void Type_Specifier::set_size(int size){
        this->size = size;
    }
    int Type_Specifier::get_size(){
        return this->size;
    }
    // Fun_Declarator Class Methods
    Fun_Declarator::Fun_Declarator() {
        this->name = "";
        this->symbols = std::vector<Symbol>();
    }
    Fun_Declarator::Fun_Declarator(std::string name) {
        this->name = name;
        this->symbols = std::vector<Symbol>();
    }
    std::string Fun_Declarator::get_name() {
        return this->name;
    }
    void Fun_Declarator::set_name(std::string name) {
        this->name = name;
    }
    void Fun_Declarator::add_symbol(Symbol symbol, int offset) {
        symbol.offset = offset;
        this->symbols.push_back(symbol);
    }
    std::vector<Symbol> Fun_Declarator::get_symbols() {
        return this->symbols;
    }

    //Declaration List Class Methods
    Declaration_List::Declaration_List() {
        this->symbols = std::vector<Symbol>();
    }
    void Declaration_List::add_symbol(Symbol symbol) {
        this->symbols.push_back(symbol);
    }
    std::vector<Symbol> Declaration_List::get_symbols() {
        return this->symbols;
    }

    // Declarator Class Methods
    Declarator::Declarator() {
        this->stars = "";
        this->name = "";
        size = 4;
    }
    Declarator::Declarator(std::string name) {
        this->stars = "";
        this->name = name;
        size = 4;
    }
    Declarator::Declarator(std::string name, int size) {
        this->stars = "";
        this->name = name;
        this->size = size;
    }
    std::string Declarator::get_name() {
        return this->name;
    }
    std::string Declarator::get_stars() {
        return this->stars;
    }
    int Declarator::get_size() {
        return this->size;
    }
    void Declarator::set_name(std::string name) {
        this->name = name;
    }
    void Declarator::set_stars(std::string stars) {
        this->stars = stars;
    }
    void Declarator::set_size(int size) {
        this->size = size;
    }

    // Declarator_List Class Methods
    Declarator_List::Declarator_List() {
        this->declarators = std::vector<Declarator>();
    }
    void Declarator_List::add_declarator(Declarator declarator) {
        this->declarators.push_back(declarator);
    }
    std::vector<Declarator> Declarator_List::get_declarators() {
        return this->declarators;
    }

    // Compound_Statement Class Methpods
    Compound_Statement::Compound_Statement() {
        this->symbols = std::vector<Symbol>();
        this->ast = new seq_astnode();
    }
    void Compound_Statement::add_symbol(Symbol symbol) {
        this->symbols.push_back(symbol);
    }
    std::vector<Symbol> Compound_Statement::get_symbols() {
        return this->symbols;
    }
    void Compound_Statement::set_ast(seq_astnode* ast){
        this->ast = ast;
    }
    seq_astnode* Compound_Statement::get_ast() {
        return this->ast;
    }

    //Expression_List Class Methopds
    Expression_List::Expression_List() {
        this->expressions = std::vector<exp_astnode*>();
    }
    void Expression_List::add_expression(exp_astnode* expression) {
        this->expressions.push_back(expression);
    }
    std::vector<exp_astnode*> Expression_List::get_expressions() {
        return this->expressions;
    }

}
