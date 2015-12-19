#include "assembler.hpp"

assembler::assembler(FILE *f)
{
    p=new parser(f);
    tokens=p->getTokens();
    labelDefs=new std::vector<token*>();
    
    for(int i=0;i<tokens->size();i++)
    {
        if((*tokens)[i]->getType()==LABELDEF)
        {
            labelDefs->push_back((*tokens)[i]);
        }
    }
    
    //Now map out all of the thingies:
    for(int i=0;i<tokens->size();i++)
    {
        if((*tokens)[i]->getType()==LABEL)
        {
            bool wasFound=false;
            
            for(int j=0;j<labelDefs->size();j++)
            {
                char *str1, *str2;
                str1=(char*) (*tokens)[i]->getDataString()->c_str();
                str2=(char*) (*labelDefs)[j]->getDataString()->c_str();
                
                if(strcmp(str1, str2)==0)
                {
                    (*tokens)[i]->setValue((*labelDefs)[j]->getValue());
                    wasFound=true;
                }
            }
            
            if(!wasFound)
            {
                printf("ERROR! Couldn't find label: %s\n", (*tokens)[i]->getData());
            }
        }
    }
    
    delete labelDefs;
    labelDefs=NULL;
}

assembler::~assembler()
{
    //printf("Deleting tokenlist...\n");
    //Deletion of the token list is handled by the parser.
    
    //printf("Deleting label definitions...\n");
    if(labelDefs!=NULL)
    {
        delete labelDefs;
    }
    
    //printf("Deleting the parser...\n");
    if(p!=NULL)
    {
        delete p;
    }
}

void assembler::assemble(FILE *outFile)
{
    std::vector<token*> tokenVect;
    
    printf("Have %d tokens.\n", (int) tokens->size());
    
    /*
    for(int i=0;i<tokens->size();i++)
    {
        printf("Type: %d\n", (*tokens)[i]->getType());
    }
    */
    
    //Now go through and get down to science:
    for(int i=0;i<tokens->size();i++)
    {
        //For each instruction:
        if((*tokens)[i]->getType()==INSTRUCTION)
        {
            tokenVect.clear();
            //Get the tokens after it:
            for(int j=i+1;j<tokens->size();j++)
            {
                if((*tokens)[j]->getType()==INSTRUCTION||(*tokens)[j]->getType()==RAWDATA)
                {
                    break;
                }
                
                //printf("Pushing token...");
                tokenVect.push_back((*tokens)[j]);
                //printf("Pushing token of type: %d\n", (*tokens)[j]->getType());
            }
            
            //Check if it has args:
            if(tokenVect.size()!=0)
            {
                uint16_t instr;
                
                //Now check if its args are literals or something similar:
                if((tokenVect[0])->getType()==LABEL||(tokenVect[0])->getType()==LITERAL)
                {
				   if((*tokens)[i]->getValue()==LDL)
				   {
					   instr=constructLdlOp(tokenVect[0]->getValue());
				   }
				   
				   else
				   {
					   instr=constructOpWithByte((uint8_t) (*tokens)[i]->getValue(), (int8_t) tokenVect[0]->getValue());
				   }
                }
                
                else if((tokenVect[0])->getType()==REG)//(tokenVect[0])->getType()==REGISTER)
                {
                    uint8_t regList[3];
                    
                    for(int j=0;j<3;j++)
                    {
                        if(j>tokenVect.size())
                        {
                            regList[j]=0;
                        }
                        
                        else
                        {
                            regList[j]=(uint8_t) tokenVect[j]->getValue();
                        }
                    }
                    
                    instr=constructOpWithRegs((uint8_t) (*tokens)[i]->getValue(), regList[0], regList[1], regList[2]);                
                }
                
                fwrite(&instr, sizeof(uint16_t), 1, outFile);
            }
            
            //Just write the instruction then:
            else
            {
                uint16_t instr=constructOpWithByte((uint8_t) (*tokens)[i]->getValue(), (uint8_t) 0);
                fwrite(&instr, sizeof(uint16_t), 1, outFile);
            }
        }
        
        else if((*tokens)[i]->getType()==RAWDATA)
        {
            tokenVect.clear();
            
            //Now push things into its possible vector:
            for(int j=i+1;j<tokens->size();j++)
            {
                if((*tokens)[j]->getType()==INSTRUCTION||(*tokens)[j]->getType()==RAWDATA)
                {
                    break;
                }
                
                //printf("Pushing token...");
                tokenVect.push_back((*tokens)[j]);
                //printf("Pushing token of type: %d\n", (*tokens)[j]->getType());
            }
            
            //Now that we have all of that:
            for(int j=0;j<tokenVect.size();j++)
            {
                if((tokenVect[j])->getType()==OTHER)
                {
                    if((tokenVect[j])->getValue()!=INVALID_DATA)
                    {
                        uint16_t tmpV=(uint16_t) (tokenVect[j])->getValue();
                        
                        fwrite(&tmpV, sizeof(uint16_t), 1, outFile);
                    }
                }
            }
        }
    }
}
