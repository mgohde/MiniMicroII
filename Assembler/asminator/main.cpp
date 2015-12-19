#include <iostream>

#include "assembler.hpp"

int main(int argc, char **argv)
{
    if(argc!=3)
    {
        printf("Need more args.\n");
        return 1;
    }
    
    FILE *inFile=fopen(argv[1], "r");
    FILE *outFile=fopen(argv[2], "wb");
    
    printf("Assembling...\n");
    assembler *a=new assembler(inFile);
    a->assemble(outFile);
    
    delete a;
    printf("Done.\n");
    
    fclose(inFile);
    fclose(outFile);
    
    return 0;
}
