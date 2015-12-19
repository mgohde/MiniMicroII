#include "parser.hpp"

parser::parser(FILE *f)
{
    int instrCtr;
    token *t;
    tokens=new std::vector<token*>();
    
    instrCtr=0;
    
    while(true)
    {
        try
        {
            t=new token(f, instrCtr);
        } catch(int e)
        {
            break;
        }
        
        tokens->push_back(t);
    }
}

parser::~parser()
{
    if(tokens!=NULL)
    {
        for(int i=0;i<tokens->size();i++)
        {
            delete (*tokens)[i];
        }
        
        delete tokens;
    }
}

std::vector<token*> *parser::getTokens()
{
    return tokens;
}
