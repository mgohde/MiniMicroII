ldl $10
and r7,r7,r1
ldl $1
and r7,r7,r2
>loop
add r2,r0,r0
ldl #out
cmp r1,r0,r0
je r6,r7,r0
ldl #loop
jmp r6,r7,r0
>out
hlt
