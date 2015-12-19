/*
 * opdefs.c
 *
 *  Created on: Sep 3, 2015
 *      Author: mgohde
 */

#include "opdefs.h"

int getOpCode(char *str)
{
	if(strcmp(str, NOP_STR)==0)
	{
		return NOP;
	}

	else if(strcmp(str, ADD_STR)==0)
	{
		return ADD;
	}

	else if(strcmp(str, ADDC_STR)==0)
	{
		return ADDC;
	}

	else if(strcmp(str, SUB_STR)==0)
	{
		return SUB;
	}

	else if(strcmp(str, SUBC_STR)==0)
	{
		return SUBC;
	}

	else if(strcmp(str, BSL_STR)==0)
	{
		return BSL;
	}

	else if(strcmp(str, BSR_STR)==0)
	{
		return BSR;
	}

	else if(strcmp(str, AND_STR)==0)
	{
		return AND;
	}

	else if(strcmp(str, OR_STR)==0)
	{
		return OR;
	}

	else if(strcmp(str, INV_STR)==0)
	{
		return INV;
	}

	else if(strcmp(str, XOR_STR)==0)
	{
		return XOR;
	}

	else if(strcmp(str, CMP_STR)==0)
	{
		return CMP;
	}

	else if(strcmp(str, JMP_STR)==0)
	{
		return JMP;
	}

	else if(strcmp(str, JE_STR)==0)
	{
		return JE;
	}

	else if(strcmp(str, JP_STR)==0)
	{
		return JP;
	}

	else if(strcmp(str, JN_STR)==0)
	{
		return JN;
	}

	else if(strcmp(str, SETINT_STR)==0)
	{
		return SETINT;
	}

	else if(strcmp(str, INT_STR)==0)
	{
		return INT;
	}

	else if(strcmp(str, HINT_STR)==0)
	{
		return HINT;
	}

	else if(strcmp(str, RETI_STR)==0)
	{
		return RETI;
	}

	else if(strcmp(str, HLT_STR)==0)
	{
		return HLT;
	}

	else if(strcmp(str, LOAD_STR)==0)
	{
		return LOAD;
	}

	else if(strcmp(str, STORE_STR)==0)
	{
		return STORE;
	}

	else if(strcmp(str, LDFLGS_STR)==0)
	{
		return LDFLGS;
	}

	else if(strcmp(str, STFLGS_STR)==0)
	{
		return STFLGS;
	}

	else if(strcmp(str, LDL_STR)==0)
	{
		return LDL;
	}

	else if(strcmp(str, CPY_STR)==0)
	{
		return CPY;
	}

	/* New instructions:*/
	else if(strcmp(str, SSR_STR)==0)
	{
		return SSR;
	}

	else if(strcmp(str, LSR_STR)==0)
	{
		return LSR;
	}

	else if(strcmp(str, PUSH_STR)==0)
	{
		return PUSH;
	}

	else if(strcmp(str, POP_STR)==0)
	{
		return POP;
	}

	else if(strcmp(str, CALL_STR)==0)
	{
		return CALL;
	}

	else if(strcmp(str, RET_STR)==0)
	{
		return RET;
	}

	else if(strcmp(str, PUSHPC_STR)==0)
	{
		return PUSHPC;
	}

	else
	{
		return UNKNOWN;
	}
}

uint16_t constructOpWithRegs(uint8_t opCode, uint8_t a, uint8_t b, uint8_t c)
{
	uint16_t retVal, operandBuffer;

	retVal=opCode<<1;
	retVal=retVal<<8;
	operandBuffer=a;
	operandBuffer=operandBuffer<<6;
	operandBuffer=operandBuffer|(b<<3);
	operandBuffer=operandBuffer|c;

	retVal=retVal|operandBuffer;

	return retVal;
}

uint16_t constructOpWithByte(uint8_t opCode, uint8_t operand)
{
	uint16_t retVal;

	retVal=opCode<<1;
	retVal=retVal<<8;
	retVal+=operand;

	return retVal;
}

uint16_t constructLdlOp(uint16_t word)
{
	uint16_t retVal;
	
	retVal=word;
	retVal=retVal|(32768); //Or 1<<15.
	
	return retVal;
}
