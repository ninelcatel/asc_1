.section .note.GNU-stack,"",@progbits
#1=add 2=get 3=delete 4=defragmentation
#gcc -m32 1.s -o 1 -no-pie 
#^ compilare
.data
    blocuri: .space 1024  
    printFormat: .asciz "%d: (%d, %d)\n"
    printFormat_get: .asciz "(%d, %d)\n"
    scanFormat: .asciz "%d"
    nrFunctie: .space 4
    nrOperatii: .space 4
    nrFisiere: .space 4
    dimensiuneFisier: .space 4
    idFisier: .space 4
    opInvalid: .asciz "Operatie invalida, restartati programul\n"
    printFormat_invalid: .asciz "%s"
.text
.global main
main:

    lea blocuri,%edi                #incarcam adresa blocurilor in edi pentru a le prelucra
    
    mov $nrOperatii,%eax            #input cate operatii
    push %eax
    push $scanFormat
    call scanf
    add $8,%esp
      
    xor %ecx,%ecx
        loop_main:
            cmp nrOperatii,%ecx
            jge exit
            push %ecx #tinem minte indexul in stiva
            
            mov $nrFunctie,%eax # ce fel de functie
            
            push %eax
            push $scanFormat
            call scanf
            add $8,%esp

            mov nrFunctie,%eax  # verif ce fel de functie apelam
            cmp $1,%eax         
            je _add 
            
            mov nrFunctie,%eax
            cmp $2,%eax
            je get

            mov nrFunctie,%eax
            cmp $3,%eax
            je del 

            mov nrFunctie,%eax
            cmp $4,%eax
            je defrag

            back:
                pop %ecx #recuperam registru ecx
                inc %ecx

            jmp loop_main
    jmp exit
_add:
    mov $nrFisiere,%eax                 #input cate fisiere
    push %eax
    push $scanFormat
    call scanf
    add $8,%esp
    
    xor %eax,%eax
    xor %ecx,%ecx
    xor %ebx,%ebx
    push %ebx
    loop_add:
        
        cmp nrFisiere,%ecx 
        jge afisare_add
        
        push %ecx

            mov $idFisier,%eax
            push %eax
            push $scanFormat
            call scanf 
            add $8,%esp

            mov $dimensiuneFisier,%eax
            push %eax 
            push $scanFormat
            call scanf 
            add $8,%esp

                #impartire rotunjita superior in bytes, pentur a vedea cate blocuri ocupa in array

                mov dimensiuneFisier,%eax
                mov $8,%ebx
                mov %ebx,%ecx
                dec %ecx
                add %ecx,%eax
                xor %edx, %edx
                div %ebx
                
                # eax acum are nr de blocuri pt care trb sa adaug id respectiv
                mov 8(%esp),%ecx
                add %eax,%ecx #salvam ultimul index unde se va afla blocul 
                mov %ecx,8(%esp)

                push idFisier
                push %eax
                push 16(%esp)
                call placeBlocks
                add $12,%esp
                    
        pop %ecx
        inc %ecx
        jmp loop_add
    
placeBlocks:
    push %ebp
    mov %esp,%ebp
    
    mov 8(%ebp), %ebx
    mov 12(%ebp), %eax
    mov %ebx,%ecx
    sub %eax,%ebx
            placeBlocks_loop:
                mov 16(%ebp),%eax
                mov %eax,(%edi,%ebx,4)
                inc %ebx
                cmp %ecx,%ebx
                jl placeBlocks_loop
    pop %ebp
    ret

afisare_add:
    mov $1,%ecx 
    mov (%edi,%ecx,4),%eax #acceseaza elementul de pe pozitia ecx in vector
    push %eax
    push $0
    push $printFormat_get
    call printf 
    add $12,%esp

    push 4(%esp) # printeaza %ebx memorat in stiva, adica lunigmea vectorului
    push $0
    push $printFormat_get
    call printf 
    add $12,%esp
    jmp exit
    #de facut outputul specific add, 
    
get:
    jmp exit
del:
    jmp exit

defrag:
    jmp exit
exit:
    mov $1,%eax
    mov $0,%ebx
    int $0x80

exit_invalid:
    push $opInvalid
    push $printFormat_invalid
    call printf 
    add $8,%esp
    jmp exit
