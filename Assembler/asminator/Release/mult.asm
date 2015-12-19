ldl $500
xor r6,r6,r6
lsr r6,r7,r0
ldl $10
and r7,r7,r1
ldl $5
and r7,r7,r2
ldl $1
and r7,r7,r3
xor r0,r0,r0
xor r4,r4,r4
>loop
add r2,r0,r0
add r3,r4,r4
ldl #out
cmp r4,r1,r0
je r6,r7,r0
ldl #loop
jmp r6,r7,r0
>out
push r0,r0,r0
hlt
