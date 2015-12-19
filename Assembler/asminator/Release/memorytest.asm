ldl #sizeval
load r6,r7,r7
and r7,r7,r1
ldl #data
and r7,r7,r2
ldl $1
and r7,r7,r3
ldl $10
and r7,r7,r4
>loop
add r3,r0,r0
add r3,r2,r2
add r4,r2,r6
load r2,r0,r7
store r0,r6,r7
ldl #out
cmp r1,r6,r0
je r0,r7,r0
ldl #loop
jmp r0,r7,r0
>out
hlt
>sizeval
. 5
>data
. 1,2,3,4,5
