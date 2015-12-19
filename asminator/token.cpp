#include "token.hpp"

bool checkForWhitespace(char c)
{
    return c==' '||c=='\t'||c=='\n'||c==',';
}

token::token(FILE *f, int &ctr)
{
    char c;
    std::vector<char> v;
    rawData=NULL;
    internalData=NULL;
    
    while((c=fgetc(f))!=EOF)
    {
        if(checkForWhitespace(c))
        {
            break;
        }
        
        v.push_back(c);
    }
    
    if(v.size()==0)
    {
        throw 1;
    }
    
    //Now allocate the string:
    rawData=new char[v.size()+1];
    
    for(int i=0;i<v.size();i++)
    {
        rawData[i]=v[i];
    }
    
    rawData[v.size()]='\0';
    internalData=new std::string(rawData);
    
    //instructionCounter=ctr;
    
    //Determine what the string actually is:
    if(rawData[0]=='>')
    {
        internalData->erase(internalData->begin());
        intValue=ctr;
        typeV=LABELDEF;
    }
    
    else if(rawData[0]=='#')
    {
        internalData->erase(internalData->begin());
        typeV=LABEL;
    }
    
    else if(rawData[0]=='$')
    {
        internalData->erase(internalData->begin());
        typeV=LITERAL;
        sscanf((rawData+1), "%d", &intValue);
    }
    
    else if(getOpCode(rawData)!=UNKNOWN)
    {
        ctr++;
        intValue=getOpCode(rawData);
        typeV=INSTRUCTION;
    }
    
    else if(rawData[0]=='r'&&rawData[1]>='0'&&rawData[1]<='9')
    {
        typeV=REG;
        sscanf((rawData+1), "%d", &intValue);
    }
    
    else if(rawData[0]=='.')
    {
        typeV=RAWDATA;
        intValue=INVALID_DATA;
    }
    
    else
    {
        typeV=OTHER;
        
        //This allows for raw data to be included as part of 
        //a compiler macro.
        if(!sscanf(rawData, "%d", &intValue))
        {
            intValue=INVALID_DATA;
        }
        
        else
        {
            //So that the value is accounted for when it (probably)
            //gets written out.
            ctr++;
        }
    }
}

token::~token()
{
    if(rawData!=NULL)
    {
        delete rawData;
    }
    
    if(internalData!=NULL)
    {
        delete internalData;
    }
}

int token::getType()
{
    return typeV;
}

char* token::getData()
{
    return rawData;
}

std::string* token::getDataString()
{
    return internalData;
}

int token::getValue()
{
    return intValue;
}

void token::setValue(int v)
{
    intValue=v;
}
