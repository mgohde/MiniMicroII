#ifndef TOKEN_HPP
#define TOKEN_HPP
#include <string>
#include <vector>
#include <cstdio>
#include <cstring>
#include "opdefs.h"

#define INSTRUCTION 1
#define LABELDEF 2
#define LABEL 3
#define LITERAL 4
#define OTHER 5
#define REGISTER 6
#define REG 6
#define RAWDATA 7

#define INVALID_DATA -9999

bool checkForWhitespace(char c);

class token
{
private:
    int typeV;
    char *rawData;
    std::string *internalData;
    int intValue;
    //int instructionCounter;
public:
    token(FILE *f, int &ctr);
    ~token();
    
    int getType();
    char *getData();
    std::string *getDataString();
    int getValue();
    void setValue(int v);
};

#endif // TOKEN_HPP
