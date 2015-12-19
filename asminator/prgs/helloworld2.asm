xor r0,r0,r0
xor r1,r1,r1
xor r2,r2,r2
xor r3,r3,r3
xor r4,r4,r4
xor r5,r5,r5
xor r6,r6,r6
ldl #main
jmp r0,r7,r0
>hello
. 72,101,108,108,111,44,32,77,75,76,97,110,103,33
>hellolen
. 13
>main
ldl #hellolen
load r0,r7,r1
ldl #hello
and r7,r7,r2
>loop0
add r3,r2,r4
load r0,r4,r5
ldl $8000
store r0,r7,r3
ldl $8002
store r0,r7,r5
cmp r3,r1,r0
ldl #loopend1
je r0,r7,r0
ldl $1
add r7,r3,r3
ldl #loop0
jmp r0,r7,r0
>loopend1
hlt
