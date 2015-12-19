#ifndef PARSER_HPP
#define PARSER_HPP
#include <vector>
#include <cstdio>
#include <cstring>
#include "token.hpp"

class parser
{
private:
    std::vector<token*> *tokens;
public:
    parser(FILE *f);
    ~parser();

    std::vector<token*> *getTokens();
};

#endif // PARSER_HPP
