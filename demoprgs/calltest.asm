ldl #main
jmp r6,r7,r0
>func
add r1,r2,r3
ret r0,r0,r0
>main
ldl $1
and r7,r7,r1
and r7,r7,r2
ldl #func
call r6,r7,r0
hlt
