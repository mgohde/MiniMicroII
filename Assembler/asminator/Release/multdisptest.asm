>plothex
>plotchar
push r0,r0,r0
push r0,r0,r7
xor r0,r0,r0
ldl $8000
store r0,r7,r4
ldl $8001
store r0,r7,r5
ldl $8002
store r0,r7,r6
pop r0,r0,r7
pop r0,r0,r0
ret r0,r0,r0