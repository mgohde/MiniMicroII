ldl $1
and r7,r7,r0
ldl $8
and r7,r7,r1
ldl $8
and r7,r7,r2
xor r3,r3,r3
xor r4,r4,r4
>loop
add r0,r3,r3
add r1,r4,r4
ldl #out
cmp r3,r2,r0
je r6,r7,r0
ldl #loop
jmp r6,r7,r0
>out
hlt
