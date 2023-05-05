#include <bits/stdc++.h>

using namespace std;
namespace IPL{

    enum class typeExp {abstract_astnode,statement_astnode,exp_astnode,empty_astnode,seq_astnode,assignS_astnode,return_astnode,if_astnode,while_astnode,for_astnode,proccall_astnode,identifier_astnode,ref_astnode,arrayref_astnode,member_astnode,arrow_astnode,op_binary_astnode,op_unary_astnode,assignE_astnode,funcall_astnode,intconst_astnode,floatconst_astnode,stringconst_astnode
    };

    enum class op_binary_type{
        OR_OP,
        AND_OP,
        EQ_OP_INT,
        NE_OP_INT,
        LT_OP_INT,
        LE_OP_INT,
        GT_OP_INT,
        GE_OP_INT,
        
        
        EQ_OP_FLOAT,
        NE_OP_FLOAT,
        LT_OP_FLOAT,
        LE_OP_FLOAT,
        GT_OP_FLOAT,
        GE_OP_FLOAT,
        
        
        PLUS_INT,
        MINUS_INT,
        MULT_INT,
        DIV_INT,

        PLUS_FLOAT,
        MINUS_FLOAT,
        MULT_FLOAT,
        DIV_FLOAT,
        
    };

    enum class op_unary_type{
        TO_INT,
        TO_FLOAT,
        UMINUS,
        NOT,
        ADDRESS,
        DEREF,
        PP
    };




    class abstract_astnode{
        public :
        virtual void print(int blanks) = 0;
        enum typeExp astnode_type;

    };
    class statement_astnode: public abstract_astnode{
        public:
            virtual ~statement_astnode(){}
    };
    class exp_astnode : public abstract_astnode{
        public:
            virtual ~exp_astnode(){}
        int val1;
        float val2;
        bool islval;
        int cval;
        string val_type = "";
        string iden_type = "";
        string get_derefrenced_type();
    };
    class empty_astnode : public statement_astnode{
        public:
        empty_astnode();
        void print(int blanks);
    };
    class seq_astnode : public statement_astnode{
        vector<statement_astnode*> s1;
        public:
        seq_astnode();
        void add_statement(statement_astnode* statement);
        void print(int blanks);
    };
    class assignS_astnode : public statement_astnode{
        exp_astnode* e1;
        exp_astnode* e2;
        public:
        assignS_astnode(exp_astnode* ex1,exp_astnode* ex2);
        void print(int blanks);
    };

    class return_astnode : public statement_astnode{
        exp_astnode* e1;
        public:
        return_astnode(exp_astnode* ex1);
        
        void print(int blanks);
    };

    class proccall_astnode : public statement_astnode{
        string name;
        vector<exp_astnode*> args;
        public:
        proccall_astnode(string name);
        void add_argument(exp_astnode* argument);
        void print(int blanks);
    };

    class if_astnode : public statement_astnode{
        exp_astnode* cond_;
        statement_astnode* then_;
        statement_astnode* else_;
        public:
            if_astnode(exp_astnode* cond,statement_astnode* s1,statement_astnode* s2);
        void print(int blanks);
    };

    class while_astnode : public statement_astnode{
        exp_astnode* cond_;
        statement_astnode* body_;
        public:
            while_astnode(exp_astnode* cond, statement_astnode* body);
        void print(int blanks);
    };

    class for_astnode : public statement_astnode{
        exp_astnode* init_;
        exp_astnode* cond_;
        exp_astnode* update_;
        statement_astnode* body_;
        public:
            for_astnode(exp_astnode* init,exp_astnode* cond, exp_astnode* update,statement_astnode* body);
        void print(int blanks);
    };

    class op_binary_astnode : public exp_astnode{
        op_binary_type op;
        exp_astnode* exp1;
        exp_astnode* exp2;
        public:
        op_binary_astnode(exp_astnode* exp1,exp_astnode* exp2,op_binary_type op);
        void print(int blanks);
    };

    class op_unary_astnode : public exp_astnode{
        op_unary_type op;
        exp_astnode* exp1;
        
        public:
        op_unary_astnode(exp_astnode* exp1,op_unary_type op);
        void print(int blanks);


    };

    class assignE_astnode : public exp_astnode{
        public:
        exp_astnode* exp1;
        exp_astnode* exp2;
        
            assignE_astnode(exp_astnode* exp1 , exp_astnode* exp2);
        void print(int blanks);
    };

    class funcall_astnode : public exp_astnode{
        string name;
        vector<exp_astnode*> args;
        public:
        funcall_astnode(string name);
        void add_argument(exp_astnode* argument);
        void print(int blanks);
    };

    class floatconst_astnode: public exp_astnode{
        float val;
        public:
        floatconst_astnode(float val);
        void print(int blanks);
    };

    class intconst_astnode : public exp_astnode{
        int val;
        public:
        intconst_astnode(int val);
        void print(int blanks);
    };

    class stringconst_astnode : public exp_astnode{
        string val;
        public:
        stringconst_astnode(string val);
        void print(int blanks);
    };

    class ref_astnode : public exp_astnode{

        public:
            virtual ~ref_astnode(){}
    }; 

    class identifier_astnode : public ref_astnode{
        string name;
        public:
        identifier_astnode(string s);
        void print(int blanks);
    };

    class member_astnode : public ref_astnode{
        exp_astnode* expression;
        identifier_astnode* name;
        public:
            member_astnode(exp_astnode* exp1, identifier_astnode* name);
        void print(int blanks);

    };

    class arrow_astnode : public ref_astnode{
        exp_astnode* expression;
        identifier_astnode* name;
        public:
            arrow_astnode(exp_astnode* exp1, identifier_astnode* name);
        void print(int blanks);


    };

    class arrayref_astnode : public ref_astnode
    {
        exp_astnode* expression1;
        exp_astnode* expression2;
        public:
            arrayref_astnode(exp_astnode* exp1, exp_astnode* exp2);
        void print(int blanks);

    };

    // Non - Terminal Classes

    enum class SymbolType{
        Var,Const,Function,Struct
    };

    enum class Scope{Global,Local,Param};

    class Symbol 
    {
        public:
        string name;
        enum SymbolType type;
        enum Scope scope;
        string semantic_type;
        int size;
        

        public:
            int offset;
            Symbol(string name, enum SymbolType type,enum Scope scope,string semantic_type,int size,int offset);

            string get_name();
            SymbolType get_type();
            string get_type_name();
            string get_scope_name();
            Scope get_scope();
            string get_semantic_type();
            string get_deref_sem_type();
            int get_size();
            int get_offset();
    };

    class SymbolTable{
        public:
        vector<Symbol> symbols;
        
            SymbolTable();
            bool add_symbol(Symbol symbol);
            Symbol get_symbol(int index);
            int get_size();
            Symbol get_symbol_by_name(string name);
            void print();
    };

    class Type_Specifier{
        string type;
        string name;
        int size;
        public:
        Type_Specifier();
        Type_Specifier(string type);
        Type_Specifier(string type,string name);
        string get_type();
        string get_name();
        void set_type(string type);
        void set_name(string name);
        void set_size(int size);
        int get_size();
    };

    class Fun_Declarator{
        public: 
        string name;
        vector<Symbol> symbols;
        
            Fun_Declarator();
            Fun_Declarator(string name);
            void set_name(string name);
            string get_name();
            void add_symbol(Symbol symbol, int offset);
            vector<Symbol> get_symbols(); 
    };

    class Struct_Specifier{
        string name;
        SymbolTable lst;
        int size;
        public:
            Struct_Specifier();
            Struct_Specifier(string name);
            string get_name();
            SymbolTable get_lst();
            int get_size();
            void add_symbol(Symbol symbol, int offset);
            void set_name(string name);
            void set_size(int size);

    };

    class Function_Definition{
        public:
        string name;
        SymbolTable lst;
        string type;
        seq_astnode* ast;
        SymbolTable gst;

        
            Function_Definition();
            Function_Definition(string name, string type);
            string get_name();
            string get_type();
            SymbolTable get_lst();
            SymbolTable get_gst();
            void add_symbol(Symbol symbol, int offset);
            void set_name(string name);
            void set_type(string type);
            void set_gst(SymbolTable gst);
            void set_ast(seq_astnode* ast);
            seq_astnode* get_ast();
    };

    class Translation_Unit{
        SymbolTable gst;
        SymbolTable gst2;
        vector<Struct_Specifier> struct_specifiers;
        vector<Function_Definition> function_definitions;
        public:
            Translation_Unit();
            void add_struct_specifier(Struct_Specifier s);
            void add_function_definition(Function_Definition f);
            void add_global_symbol(Symbol symbol);
            void add_global_symbol2(Symbol symbol);
            void print();
            SymbolTable get_gst();


    };

    class Declarator{
        string stars;
        string name;
        int size;
        public:
            Declarator();
            Declarator(string name);
            Declarator(string name,int size);
            string get_name();
            int get_size();

            string get_stars();
            void set_name(string name);
            void set_size(int size);
            void set_stars(string stars);
            
    };

    class Declarator_List{
        vector<Declarator> declarators;
        public:
        Declarator_List();
        void  add_declarator(Declarator d);
        vector<Declarator> get_declarators();
    };

    class Compound_Statement{
        vector<Symbol> symbols;
        seq_astnode* ast;

        public: 
            Compound_Statement();
            void add_symbol(Symbol symbol);
            vector<Symbol> get_symbols();
            void set_ast(seq_astnode* ast);
            seq_astnode* get_ast();
    };

    class Declaration_List{
        vector<Symbol> symbols;
        public:
            Declaration_List();
            void add_symbol(Symbol symbol);
            vector<Symbol> get_symbols();
    };


    class Expression_List{
        vector<exp_astnode*> expressions;
        public:
            Expression_List();
            void add_expression(exp_astnode* exp);
            vector<exp_astnode*> get_expressions(); 
    };

};

