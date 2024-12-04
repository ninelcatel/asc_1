.section .note.GNU-stack,"",@progbits
#gcc -m32 1.s -o 1 -no-pie 
#^ compilare
.data
    contor: .long 0
    blocuri: .space 1024  
    printFormatt: .asciz "%s\n"
    printFormat: .asciz "%d: (%d, %d)\n"
    printFormat_get: .asciz "(%d, %d)\n"
    scanFormat: .asciz "%d"
    nrFunctie: .space 4
    nrOperatii: .long 0
    nrFisiere: .space 4
    dimensiuneFisier: .space 4
    idFisier: .space 4
    idFisierr: .space 4 # pt concat adreselor
    opInvalid: .asciz "Operatie invalida, restartati programul\n"
    printFormat_invalid: .asciz "%s"
    lenArray: .long 0 
    inceputInt: .long 1
    capatInt: .long 0
    basePath: .asciz "/home/ninel/facultate/asc/proiectFiles"
    adresa: .asciz "/home/ninel/facultate/asc/proiectFiles/"
    fullPath: .space 256
    element: .ascii "\0"
    convertNumber_buffer: .space 5
    fileName: .space 2
    dot: .asciz "."
    dotdot: .asciz ".."
    statBuffer: .space 96
    ptrDirEnt: .long 0
.text
.global main
main:
    xor %ecx,%ecx 

    lea blocuri,%edi                
    
    lea basePath,%ebx
    push %ebx
    call opendir
    add $4,%esp
    cmp $0,%eax
    je exit
    mov %eax,ptrDirEnt


    readNext:
    push %ecx 
    mov ptrDirEnt,%ebx 
    push %ebx
    call readdir
    add $4,%esp
    cmp $0,%eax
    je close
    pop %ecx 
  
    lea 11(%eax),%ebx
    mov %ebx,idFisierr

    cmpb $'.',(%ebx) 
    je readNext
    inc %ebx
    cmpb $'.',(%ebx)
    je readNext
    dec %ebx
    
    xor %eax,%eax
    xor %ecx,%ecx 
    xor %edx,%edx 
            convert:
                movb (%ebx,%ecx),%al 
                cmp $0,%al 
                je done 
                sub $'0',%al 
                jl readNext
                cmp $9,%al 
                jg readNext
                imul $10,%edx
                add %eax,%edx
                inc %ecx
                jmp convert
            done:
    mov %edx,idFisier
     
    
        
    push %ecx 

    push $adresa
    push $fullPath
    call strcpy
    add $8,%esp        

    push $element
    push $idFisierr
    call strcat
    add $8,%esp        
     
    push idFisierr
    push $fullPath
    call strcat
    add $8,%esp
    

    push $statBuffer
    push $fullPath
    call stat 
    add $8,%esp 


    pop %ecx #fileName addrses

    mov $statBuffer,%eax #filesize
    mov 20(%eax),%edx # struct address in st_id
    mov 44(%eax),%eax # struct addres in st_size
    mov %eax,dimensiuneFisier
    push %eax
    push %ecx
    jmp addFisier
    
    backFisiere:
    pop %ecx 
    pop %eax 
    jmp readNext

    close:
    mov ptrDirEnt,%ebx
    push %ebx 
    call closedir
    add $4,%esp                                         


    mov $nrOperatii,%eax            
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
                
                addFisier:
                mov $8,%ebx
                mov %ebx,%ecx
                dec %ecx
                add %ecx,%eax
                xor %edx, %edx
                div %ebx    # eax acum are nr de blocuri pt care trb sa adaug id respectiv
                
                jmp existSecv

                continue:
                pop %edx
                pop %eax
                pop %ebx
                pop %ecx
        
                mov lenArray,%ecx #in acest punct al stivei se afla lungimea completa a arrayului
                add %eax,%ecx #salvam ultimul index unde se va afla blocul 
                cmp $255,%ecx   #daca fisierul este prea mare
                jge else
                mov %ecx,lenArray
                
                push idFisier
                push %eax
                push lenArray
                call placeBlocks
                add $12,%esp
                
                mov nrOperatii,%ecx
                cmp $0,%ecx
                je backFisiere
        else:
        pop %ecx
        inc %ecx
        jmp loop_add
existSecv:
    push %ecx
    push %ebx
    push %eax
    push %edx 
    xor %ecx,%ecx
    loop_check:
        cmp lenArray,%ecx 
        je continue
        mov (%edi,%ecx,4),%ebx
        inc %ecx
        cmp $0,%ebx
        jne xoram
        inc %edx
        cmp %eax,%edx  #verificam daca incape
        je pBlocks_secv
        jmp loop_check
    xoram:
        xor %edx,%edx
        jmp loop_check
    pBlocks_secv:
        push idFisier
        push %eax
        push %ecx
        call placeBlocks
        add $12,%esp
        pop %edx
        pop %eax
        pop %ebx
        pop %ecx
        jmp else
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

        mov idFisier,%eax
        lea convertNumber_buffer,%ecx
        convertLoop:
                xor %edx,%edx
                mov $10,%ebx
                div %ebx 
                addb $'0',%dl 
                dec %ecx 
                movb %dl,(%ecx)
                cmp $0,%eax 
                jne convertLoop

        mov %ecx,idFisierr #idFisier doar ca string
        
        push $adresa
        push $fullPath
        call strcpy
        add $8,%esp

        push $element
        push $idFisierr 
        call strcat
        add $8,%esp
                
        push idFisierr
        push $fullPath
        call strcat
        add $8,%esp


        mov $10,%eax    #unlink code
        mov $fullPath,%ebx
        int $0x80



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
    
validArray:                 #validam daca mai exista 0 intre blocuri, daca exista, facem o shiftare la stanga cu 1 element
    xor %ecx,%ecx
    loop_validArray:
        cmp %ecx,lenArray
        je parcurgereVector
        mov (%edi,%ecx,4),%eax
        cmp $0,%eax
        je defrag
        inc %ecx
        jmp loop_validArray
defrag:
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
