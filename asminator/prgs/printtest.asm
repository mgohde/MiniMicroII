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
>curX
. 0
>curY
. 0
>val1
. 1
>val2
. 9
>str
. 42
>str1
. 61
>main
ldl #val1
load r0,r7,r1
and r1,r1,r2
ldl #printnum
call r0,r7,r0
ldl #str
load r0,r7,r1
ldl #printchar
call r0,r7,r0
ldl #val2
load r0,r7,r1
and r1,r1,r3
ldl #printnum
call r0,r7,r0
ldl #str1
load r0,r7,r1
ldl #printchar
call r0,r7,r0
and r2,r2,r1
and r3,r3,r2
ldl #mul
call r0,r7,r0
and r3,r3,r1
ldl #printnum
call r0,r7,r0
hlt
>mul
push r4,r0,r0
xor r4,r4,r4
xor r3,r3,r3
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
>printnum
push r1,r0,r0
push r2,r0,r0
push r3,r0,r0
push r4,r0,r0
and r1,r1,r3
ldl #curX
load r0,r7,r1
ldl #curY
load r0,r7,r2
ldl $48
and r7,r7,r4
add r3,r4,r3
ldl #plotchar
call r0,r7,r0
ldl $1
and r7,r7,r3
add r1,r3,r1
ldl #curX
store r0,r7,r1
ldl $80
and r7,r7,r3
cmp r3,r1,r0
ldl #overflowhandler
je r0,r7,r0
>endfunc
pop r0,r0,r4
pop r0,r0,r3
pop r0,r0,r2
pop r0,r0,r1
ret
>overflowhandler
ldl $1
and r7,r7,r3
add r2,r3,r2
ldl $0
and r7,r7,r1
ldl #curX
store r0,r7,r1
ldl #curY
store r0,r7,r2
ldl #endfunc
jmp r0,r7,r0
>printchar
push r1,r0,r0
push r2,r0,r0
push r3,r0,r0
and r1,r1,r3
ldl #curX
load r0,r7,r1
ldl #curY
load r0,r7,r2
ldl #plotchar
call r0,r7,r0
ldl $1
and r7,r7,r3
add r1,r3,r1
add r2,r3,r2
ldl #curX
store r0,r7,r1
ldl #curY
store r0,r7,r2
pop r0,r0,r3
pop r0,r0,r2
pop r0,r0,r1
ret
>plotchar
ldl $8000
store r0,r7,r1
ldl $8001
store r0,r7,r2
ldl $8002
store r0,r7,r3
ret
