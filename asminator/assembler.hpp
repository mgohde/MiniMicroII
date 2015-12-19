#ifndef ASSEMBLER_HPP
#define ASSEMBLER_HPP
#include <vector>
#include <cstdio>
#include <stdint.h>
#include <cstring>

#include "token.hpp"
#include "parser.hpp"

class assembler
{
private:
    std::vector<token*> *labelDefs;
    std::vector<token*> *tokens;
    parser *p;
public:
    assembler(FILE *f);
    ~assembler();

    void assemble(FILE *outFile);
};

#endif // ASSEMBLER_HPP
