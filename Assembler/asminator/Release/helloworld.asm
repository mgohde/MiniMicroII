xor r0,r0,r0
ldl $8000
and r7,r7,r2
xor r3,r3,r3
ldl $8002
and r7,r7,r6
ldl #textsize
load r0,r7,r1
ldl #textptr
and r7,r7,r4
>loop
load r0,r4,r5
ldl $1
add r7,r4,r4
add r7,r3,r3
sub r1,r7,r1
store r0,r2,r3
nop r0,r0,r0
store r0,r6,r5
ldl #out
cmp r1,r0,r0
je r0,r7,r0
ldl #loop
jmp r0,r7,r0
>out
nop r0,r0,r0
hlt
>textsize
. 13
>textptr
. 72,101,108,108,111,44,32,119,111,114,108,100,33