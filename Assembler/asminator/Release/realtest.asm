xor r0,r0,r0
ldl $1
and r7,r7,r1
ldl $8000
store r0,r7,r1
ldl $8001
store r0,r7,r1
ldl $8002
and r7,r7,r1
ldl $65
store r0,r1,r7
nop r0,r0,r0
ldl $66
store r0,r1,r7
hlt
