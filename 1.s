.section .note.GNU-stack,"",@progbits
#1=add 2=get 3=delete 4=defragmentation
#gcc -m32 1.s -o 1 -no-pie 
#^ compilare
.data
    contor: .long 0
    blocuri: .space 1024  
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
    lenArray: .long 0 
    inceputInt: .long 1
    capatInt: .long 0
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
            je defrag

            back:
                mov contor,%ecx
                inc %ecx
                mov %ecx,contor        

               
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
    loop_add:
        
        cmp nrFisiere,%ecx 
        jge parcurgereVector # afisare_add
        
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
                mov lenArray,%ecx #in acest punct al stivei se afla lungimea completa a arrayului
                add %eax,%ecx #salvam ultimul index unde se va afla blocul 
                mov %ecx,lenArray

                push idFisier
                push %eax
                push lenArray
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
                mov idFisier,%eax
                mov %eax,(%edi,%ebx,4)
                inc %ebx
                cmp %ecx,%ebx
                jl placeBlocks_loop
    pop %ebp
    ret

afisare_add:
    mov lenArray,%ecx
    dec %ecx 
    mov (%edi,%ecx,4),%eax #acceseaza elementul de pe pozitia ecx in vector
    push %eax
    push $0
    push $printFormat_get
    call printf 
    add $12,%esp

    push lenArray # printeaza %ebx memorat in stiva, adica lunigmea vectorului
    push $0
    push $printFormat_get
    call printf 
    add $12,%esp
    jmp back
    #   daca este apelat de doua ori add, nu tine minte ultima pozitie a fisierului deja adaugat si il suprascrie, acest lucru NU se intampla daca ambele fisiere sunt adaugate in acelasi add
    #de facut outputul specific add, 

parcurgereVector:
    xor %ecx,%ecx
    
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
            cmp lenArray,%ecx
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
    
    loop_capatInt:
        
        mov (%edi,%ecx,4),%eax
        cmp idFisier,%eax
        jne get_print
        inc %ecx
        jmp loop_capatInt
get_print:
    dec %ecx
    pop %eax
    push %ecx
    push %eax
    push $printFormat_get
    call printf
    add $12,%esp
    jmp back

del:
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
del_capat:
    loop_del:
        mov $0,%ebx
        mov %ebx,(%edi,%ecx,4)
        inc %ecx
        mov (%edi,%ecx,4),%eax
        cmp idFisier,%eax
        jne parcurgereVector
        jmp loop_del
    
defrag:
    jmp exit
exit:
    mov $1,%eax
    mov $0,%ebx
    int $0x80
