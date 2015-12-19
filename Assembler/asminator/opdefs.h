/*
 * opdefs.h
 *
 *  Created on: 23 May 2015
 *      Author: mgohde
 */

#ifndef OPDEFS_H_
#define OPDEFS_H_

#include <stdint.h>
#include <string.h>

#define NOP 0
#define NOP_STR "nop"
#define ADD 1
#define ADD_STR "add"
#define ADDC 2
#define ADDC_STR "addc"
#define SUB 3
#define SUB_STR "sub"
#define SUBC 4
#define SUBC_STR "subc"
#define BSL 5
#define BSL_STR "bsl"
#define BSR 6
#define BSR_STR "bsr"
#define AND 7
#define AND_STR "and"
#define OR 8
#define OR_STR "or"
#define INV 9
#define INV_STR "inv"
#define XOR 10
#define XOR_STR "xor"

/* Instructions Added for C Support: */
/* Yeah, it looks like we need stack and call instructions...*/
#define SSR 40
#define SSR_STR "ssr"
#define LSR 41
#define LSR_STR "lsr"
/* Pushes register A.*/
#define PUSH 42
#define PUSH_STR "push"
#define POP 43
#define POP_STR "pop"
#define CALL 44
#define CALL_STR "call"
#define RET 45
#define RET_STR "ret"
#define PUSHPC 46
#define PUSHPC_STR "pushpc"

/* End instructions added.*/
#define CMP 50
#define CMP_STR "cmp"
#define JMP 51
#define JMP_STR "jmp"
#define JE 52
#define JE_STR "je"
#define JP 53
#define JP_STR "jp"
#define JN 54
#define JN_STR "jn"
/* Interrupt instructions can probably be safely discarded, because
   by this point, they'll either be implemented in a separate unit or 
   not at all.
*/
#define SETINT 55
#define SETINT_STR "setint"
#define INT 56
#define INT_STR "int"
#define HINT 57
#define HINT_STR "hint"
#define RETI 58
#define RETI_STR "reti"
/* Halt instruction added to help the emulator.*/
#define HLT 59
#define HLT_STR "hlt"
#define LOAD 60
#define LOAD_STR "load"
#define STORE 61
#define STORE_STR "store"
#define LDFLGS 62
#define LDFLGS_STR "ldflgs"
#define STFLGS 63
#define STFLGS_STR "stflgs"
#define LDL 64
#define LDL_STR "ldl"
/*
 * This instruction is unimplemented, so use the OpCode for AND, since
 * when used correctly, it should give the same result if B==A.
 */
#define CPY 7
#define CPY_STR "cpy"

#define UNKNOWN 999

int getOpCode(char *str);
uint16_t constructOpWithRegs(uint8_t opCode, uint8_t a, uint8_t b, uint8_t c);
uint16_t constructOpWithByte(uint8_t opCode, uint8_t operand);
uint16_t constructLdlOp(uint16_t word);


#endif /* OPDEFS_H_ */
