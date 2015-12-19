xor r0,r0,r0
xor r1,r1,r1
xor r2,r2,r2
xor r3,r3,r3
xor r4,r4,r4
xor r5,r5,r5
xor r6,r6,r6
ldl $-1
lsr r0,r7,r0
ldl #main
jmp r0,r7,r0
>val1
. 10
>val2
. 10
>main
ldl #val1
load r0,r7,r1
ldl #val2
load r0,r7,r2
ldl #mult
call r0,r7,r0
and r3,r3,r1
and r3,r3,r1
ldl #printhex
call r0,r7,r0
hlt
>mult
push r4,r0,r0
ldl $0
and r7,r7,r4
ldl $0
and r7,r7,r3
>loop0
add r4,r1,r4
cmp r3,r2,r0
ldl #loopend1
je r0,r7,r0
ldl $1
add r7,r3,r3
ldl #loop0
jmp r0,r7,r0
>loopend1
and r4,r4,r3
pop r0,r0,r4
ret
>printhex
ldl $48
and r7,r7,r4
ldl $15
and r7,r7,r5
ldl $12
and r7,r7,r-1
bsl r5,r-1,r2
and r1,r2,r3
bsr r3,r-1,r3
add r3,r4,r3
ldl $8002
store r0,r7,r3
ldl $1
and r7,r7,r3
ldl $8000
store r0,r7,r3
ret
