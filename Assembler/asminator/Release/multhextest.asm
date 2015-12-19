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
nop r0,r0,r0
>main
nop r0,r0,r0
ldl $30
and r7,r7,r1
ldl $27
and r7,r7,r2
nop r0,r0,r0
ldl #mult
call r0,r7,r0
nop r0,r0,r0
ldl #outVal
load r0,r7,r2
nop r0,r0,r0
ldl #drawhex
call r0,r7,r0
nop r0,r0,r0
hlt
hlt
nop r0,r0,r0
>mult
nop r0,r0,r0
ldl $0
and r7,r7,r3
ldl $1
and r7,r7,r4
sub r2,r4,r2
ldl $0
and r7,r7,r4
>loop0
add r3,r1,r3
cmp r4,r2,r0
ldl #loopend1
je r0,r7,r0
ldl $1
add r7,r4,r4
ldl #loop0
jmp r0,r7,r0
nop r0,r0,r0
>loopend1
ldl #outVal
store r0,r7,r3
ret
nop r0,r0,r0
>drawhex
nop r0,r0,r0
ldl $12
and r7,r7,r5
ldl $4
and r7,r7,r4
ldl $0
and r7,r7,r3
>loop2
nop r0,r0,r0
add r1,r3,r3
ldl $8000
store r0,r7,r3
sub r3,r1,r3
ldl $15
and r7,r7,r6
bsl r6,r5,r6
and r6,r2,r6
bsr r6,r5,r6
ldl #hexDat
and r7,r7,r4
add r4,r6,r4
load r0,r4,r6
ldl $8002
store r0,r7,r6
ldl $4
and r7,r7,r4
sub r5,r4,r5
ldl $3
cmp r3,r7,r0
ldl #loopend3
je r0,r7,r0
ldl $1
add r7,r3,r3
ldl #loop2
jmp r0,r7,r0
nop r0,r0,r0
>loopend3
nop r0,r0,r0
ret
>hexDat
. 48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70
>times
. 42
>equals
. 61
>outVal
. 0
