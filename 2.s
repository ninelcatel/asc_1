.section .note.GNU-stack,"",@progbits
#gcc -m32 2.s -o 2 -no-pie 
#^ compilare
.data
    contor: .long 0
    blocuri: .space 1048576 #2^20 bytes (1024x1024 bytes)
    printFormat: .asciz "%d: (%d, %d)\n"
    printFormat_get: .asciz "(%d, %d)\n"
    scanFormat: .asciz "%d"
    nrFunctie: .space 4
    nrOperatii: .space 4
    nrFisiere: .space 4
    dimensiuneFisier: .space 4
    idFisier: .long 0
    opInvalid: .asciz "Operatie invalida, restartati programul\n"
    printFormat_invalid: .asciz "%s"
    lenArray: .space 1024 #numarul de elemente pe fiecare rand 
    inceputInt: .long 1
    capatInt: .long 0
.text
.global main
main:
    
    
    lea blocuri, %edi 
    lea lenArray, %esi

    xor %ecx,%ecx
    xor %eax,%eax
    loop_nullArray:
        cmp $256,%ecx
        jge gata
        mov $0,(%esi,%ecx,4)
        jmp loop_nullArray
    gata:


    mov $nrOperatii,%eax            #input cate operatii
    push %eax
    push $scanFormat
    call scanf
    add $8,%esp
      
    xor %ecx,%ecx
        loop_main:
            
            mov contor,%ecx
            cmp nrOperatii,%ecx
            jge exit
            
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
            je validArray

            back:
                mov contor,%ecx
                inc %ecx
                mov %ecx,contor        

               
            jmp loop_main
    jmp exit

_add:    
    #nu cred ca trb ceva schimbat aici           
    mov $nrFisiere,%eax                 #input cate fisiere
    push %eax
    push $scanFormat
    call scanf
    add $8,%esp
    
    xor %eax,%eax
    xor %ecx,%ecx
    xor %ebx,%ebx
    loop_add:
        
        cmp nrFisiere,%ecx 
        jge parcurgereVector 
        
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
%
                xor %ecx,%ecx
                loop_verif_lenRows:
                        mov (%esi,%ecx,4),%ebx
                        add %eax,%ebx
                        cmp $256,%ebx
                        jl gasit_contor:
                        inc %ecx

                gasit_contor:

                mov (%esi,%ecx,4),%ebx
                add %eax,%ebx
                mov %ebx,(%esi,%ecx,4)


                push %ecx # care rand
                push %eax
                push %ebx # reprezinta lungimea curenta a rowului
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
    mov 16(%ebp), %edx      # pe care rand este
    mov %ebx,%ecx
    sub %eax,%ebx   #%ebx este valoarea de la care incepe atribuirea, %ecx unde se sfarseste%

                push %ebx
                push %ecx
                
                mov $256,%ecx
                mul %ecx,%edx
                add %ebx,%edx  #asa ajungem pe randul corect, si dupa doar incrementam ebx dupa fiecare atribuireS
                
                pop %ecx
                pop %ebx
            
            placeBlocks_loop:
                

                   mov idFisier,%eax
                mov %eax,(%edi,%edx,4)%
               
                inc %ebx
                cmp %ecx,%ebx
                jl placeBlocks_loop
    pop %ebp
    ret


parcurgereVector:
    xor %ecx,%ecx #trbuie schimbat sotto

    mov inceputInt,%edx
    xor %edx,%edx
    mov %edx,inceputInt

    mov (%edi,%ecx,4),%eax 
    mov %eax,idFisier    
    
    loop_afisare:
        cmp lenArray,%ecx
        jg back

        mov (%edi,%ecx,4),%eax
        cmp idFisier,%eax
        jne afisare 

        mov %ecx,capatInt
        inc %ecx
    jmp loop_afisare

afisare:

    #trb schimbat sotto
    push %ecx
    push %eax
    push %ebx
    
    mov idFisier,%edx
    cmp $0,%edx
    je skip

    push capatInt
    push inceputInt
    push idFisier
    push $printFormat
    call printf 
    add $16,%esp

    skip:

    pop %ebx
    pop %eax
    pop %ecx

    mov %ecx,inceputInt #crestem cu unul ca sa nu-si dea "overlap" intervalele
    mov %eax,idFisier # trece la urmatorul fisier
    
    jmp loop_afisare

get:
       mov $idFisier,%eax
       push %eax
       push $scanFormat
       call scanf 
       add $8,%esp

       xor %ecx,%ecx
        
        loop_inceputInt:
            cmp lenArray,%ecx       #de schimbat lenarray ca adresa lea cu esi
            jg iesi
            mov (%edi,%ecx,4),%eax
            cmp idFisier,%eax
            je get_capat
            inc %ecx
            jmp loop_inceputInt
        
        iesi:
        push $0
        push $0
        push $printFormat_get
        call printf 
        add $12,%esp
        jmp back
        

get_capat:
    push %ecx
    
    loop_capatInt:                  #trb facut pt matrix
        
        mov (%edi,%ecx,4),%eax
        cmp idFisier,%eax
        jne get_print
        inc %ecx
        jmp loop_capatInt
get_print:
    #trb facut pt matrix
    dec %ecx
    pop %eax
    push %ecx
    push %eax
    push $printFormat_get
    call printf
    add $12,%esp
    jmp back

del:    #trb facut pt matrix
     mov $idFisier,%eax
       push %eax
       push $scanFormat
       call scanf 
       add $8,%esp

       xor %ecx,%ecx
        
        loop_gasimFisier:
            cmp lenArray,%ecx
            jg back
            mov (%edi,%ecx,4),%eax
            cmp idFisier,%eax
            je del_capat
            inc %ecx
            jmp loop_gasimFisier
del_capat:  #trb facut pt matrix
    loop_del:
        mov $0,%ebx
        mov %ebx,(%edi,%ecx,4)
        inc %ecx
        mov (%edi,%ecx,4),%eax
        cmp idFisier,%eax
        jne parcurgereVector
        jmp loop_del
    
validArray:                 #validam daca mai exista 0 intre blocuri, daca exista, facem o shiftare la stanga cu 1 element  #trb facut pt matrix
    xor %ecx,%ecx
    loop_validArray:
        cmp %ecx,lenArray
        je parcurgereVector
        mov (%edi,%ecx,4),%eax
        cmp $0,%eax
        je defrag
        inc %ecx
        jmp loop_validArray
defrag:         #trb facut pt matrix
    loop_defrag:
        cmp %ecx,lenArray
        je exit_loop

        inc %ecx
        mov (%edi,%ecx,4),%ebx
        dec %ecx
        mov %ebx,(%edi,%ecx,4)
        inc %ecx
        jmp loop_defrag
    
    exit_loop:
    mov lenArray,%ebx
    mov $0,%eax
    mov %eax,(%edi,%ebx,4) #nulam blocul din capat pt shiftare la stanga
    dec %ebx
    mov %ebx,lenArray
    jmp validArray
    



exit:
    mov $1,%eax
    mov $0,%ebx
    int $0x80
