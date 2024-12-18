.section .note.GNU-stack,"",@progbits
#gcc -m32 2.s -o 2 -no-pie 
#^ compilare
.data
    contor: .long 0
    blocuri: .space 1048576 #2^20 bytes (1024x1024 bytes)
    printFormat: .asciz "%d: ((%d, %d), (%d, %d))\n"
    printFormat_get: .asciz "((%d, %d) (%d, %d))\n"
    printFormat_dbg: .asciz "%d\n"
    scanFormat: .asciz "%d"
    nrFunctie: .space 4
    nrOperatii: .space 4
    nrFisiere: .space 4
    dimensiuneFisier: .space 4
    idFisier: .space 4
    opInvalid: .asciz "Operatie invalida, restartati programul\n"
    printFormat_invalid: .asciz "%s"
    lenArray: .space 1024 #numarul de elemente pe fiecare rand 
    inceputInt: .long 1
    capatInt: .long 0
    lenArrayCurrent: .long 0
    linieArray: .long 0
    contorCheck: .long 0
    basePath: .asciz "/home/ninel/facultate/asc/proiectFiles/"
    adresa: .asciz "/home/ninel/facultate/asc/proiectFiles/"
    fullPath: .space 256
    element: .ascii "\0"
    convertNumber_buffer: .space 5
    idFisierr: .space 4
    statBuffer: .space 96
    ptrDirEnt: .long 0
.text
.global main
main:
    lea blocuri, %edi 
    lea lenArray, %esi

    xor %ecx,%ecx
    xor %eax,%eax
    mov %eax,lenArrayCurrent
    loop_nullArray:
        cmp $256,%ecx
        jge gata
        mov %eax,(%esi,%ecx,4)
        inc %ecx
        jmp loop_nullArray
    gata:
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
    
    


    mov $nrOperatii,%eax            #input cate operatii
    push %eax
    push $scanFormat
    call scanf
    add $8,%esp
      
    xor %ecx,%ecx
        loop_main:
            
            push %ecx
            mov $0, %ecx
            mov %ecx, linieArray #pentru adaugari secventiale sa nu mai ajunga la randul 255 
            pop %ecx

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

                addFisier:

                mov dimensiuneFisier,%eax
                mov $8,%ebx
                mov %ebx,%ecx
                dec %ecx
                add %ecx,%eax
                xor %edx, %edx
                div %ebx
                
                # eax acum are nr de blocuri pt care trb sa adaug id respectiv

                xor %ecx,%ecx
                
                jmp existSecv
                continue:
            pop %eax
            pop %edx
            pop %ebx
            pop %ecx


                loop_verif_lenRows:
                        mov (%esi,%ecx,4),%ebx
                        add %eax,%ebx
                        cmp $256,%ebx
                        jle gasit_contor
                        inc %ecx
                        jmp loop_verif_lenRows
                gasit_contor:

                mov (%esi,%ecx,4),%ebx
                add %eax,%ebx
                mov %ebx,(%esi,%ecx,4)


                push %ecx # care rand
                push %eax
                push %ebx # reprezinta lungimea curenta a rowului
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
    push %edx 
    push %eax 
    xor %ebx,%ebx
    xor %ecx,%ecx
    mov (%esi,%ecx,4),%edx
    mov %edx,lenArrayCurrent
    xor %edx,%edx
    loop_check:
        push %edx
        mov $256,%edx
        imul %ebx,%edx
        add %ecx,%edx
        cmp lenArrayCurrent,%ecx 
        je incCheck
        push %eax 
        mov (%edi,%edx,4),%eax
        inc %ecx
        cmp $0,%eax
        jne xoram
        pop %eax
        pop %edx
        inc %edx
        cmp %eax,%edx
        je placeBlocks_secv
        jmp loop_check
    xoram:
        pop %eax
        pop %edx
        xor %edx,%edx
        jmp loop_check
    placeBlocks_secv:
        mov $256,%edx
        imul %ebx,%edx
        add %ecx,%edx
        push %ebx 
        push %eax 
        push %edx 
        call placeBlocks_secv2
        add $12,%esp
        pop %eax
        pop %edx
        pop %ebx
        pop %ecx
        jmp else
placeBlocks_secv2: 
    push %ebp
    mov %esp,%ebp

    mov 8(%ebp), %edx 
    mov 12(%ebp), %eax
    mov 16(%ebp), %ebx      
    mov %edx,%ecx
    sub %eax,%edx
                mov idFisier,%eax
              
                placeBlocks_loop_secv:
                    mov %eax,(%edi,%edx,4)
                    inc %edx
                    cmp %ecx,%edx                  
                    jl placeBlocks_loop_secv
    pop %ebp
    ret


incCheck:
    pop %edx
    
    inc %ebx
    cmp $256,%ebx
    jge continue
    push %edx
    mov (%esi,%ebx,4),%edx
    mov %edx,lenArrayCurrent
    xor %ecx,%ecx 
    pop %edx
    xor %edx,%edx
    jmp loop_check
afisare2:
    xor %ecx,%ecx
    mov (%esi,%ecx,4),%edx
    loop_bbb:
        cmp %edx,%ecx
        jge exit
        mov (%edi,%ecx,4),%eax
        mov %eax,capatInt
        push %ecx
        push %edx

        push capatInt
        push $printFormat_dbg
        call printf
        add $8,%esp
        
        pop %edx
        pop %ecx

        inc %ecx
        jmp loop_bbb

placeBlocks: #functioneaza corect
    push %ebp
    mov %esp,%ebp

    mov 8(%ebp), %ebx 
    mov 12(%ebp), %eax
    mov 16(%ebp), %edx      # pe care rand este prin intermediul loop_verif_lenRows
    mov %ebx,%ecx
    sub %eax,%ebx   #%ebx este valoarea de la care incepe atribuirea, %ecx unde se sfarseste%

                push %ebx
                push %ecx

                mov $256,%ecx
                imul %ecx,%edx
                  #asa ajungem pe randul corect, si dupa doar incrementam ebx dupa fiecare atribuireS
                
                pop %ecx
                pop %ebx

                add %ebx,%edx
                
                mov idFisier,%eax
              
                placeBlocks_loop:
                    mov %eax,(%edi,%edx,4)
                    inc %ebx
                    inc %edx
                    cmp %ecx,%ebx                  
                    jl placeBlocks_loop
    pop %ebp
    ret


parcurgereVector:   
    xor %ecx,%ecx
    xor %ebx,%ebx
    xor %edx,%edx
    mov %edx,inceputInt
    
    mov %edx,linieArray

    mov (%edi,%ecx,4),%eax 
    mov %eax,idFisier    
    push %eax
    
    mov (%esi,%ebx,4),%eax
    mov %eax,lenArrayCurrent       #schimbam urmatorul rand cand atingem lenArrayCurrent
    
    pop %eax
    

    loop_afisare:
        
        mov (%edi,%edx,4),%eax
        cmp idFisier,%eax
        jne afisare         

        cmp lenArrayCurrent,%ecx  # trebuie parcursa toata matricea ca sa putem arata fisierele inainte de defragmentare
        jge incrementareLenArray  
        
        mov %ecx,capatInt   #trebuie dat move inainte de incrementare ca sa nu creasca din greseala cu 1 interavlul
        inc %ecx
        inc %edx
        
    jmp loop_afisare


incrementareLenArray:
    inc %ebx        #%ebx reprezinta contor pentru linia matricei, cat sipentru lenArray 
    cmp $256,%ebx   # daca a ajuns la sfarsitul matricei ne intoarcem
    jge back
    mov %ebx,linieArray
    push %edx
        
        mov (%esi,%ebx,4),%edx
        mov %edx,lenArrayCurrent
    
    pop %edx

    push %ecx
    push %ebx

        mov $256,%ecx
        imul %ecx,%ebx
        mov %ebx, %edx

    pop %ebx
    pop %ecx
    
    xor %ecx,%ecx
    jmp loop_afisare
afisare:

    push %ecx
    push %eax
    push %ebx
    push %edx

    mov idFisier,%edx
                   cmp $0,%edx     # sa nu arate blocurile egale cu 0 dupa delete
                   je skip

    push capatInt
    push linieArray
    push inceputInt
    push linieArray
    push idFisier
    push $printFormat
    call printf 
    add $24,%esp

    skip:

    pop %edx
    pop %ebx
    pop %eax
    pop %ecx
    
    mov %eax,idFisier # trece la urmatorul fisier

    cmp $256,%ecx
    je e_ok
    mov %ecx,inceputInt #crestem cu unul ca sa nu-si dea "overlap" intervalele
    jmp loop_afisare
    e_ok:
    push %ecx
    mov $0,%ecx
    mov %ecx,inceputInt
    pop %ecx
    
    jmp loop_afisare


get:
        mov $idFisier,%eax
        push %eax
        push $scanFormat
        call scanf 
        add $8,%esp

        xor %ecx,%ecx
        
        mov (%esi,%ecx,4),%ebx
        mov %ebx,lenArrayCurrent

        xor %ebx,%ebx
        xor %edx,%edx

        loop_inceputInt:
            cmp lenArrayCurrent,%ecx       
            jge incLen_array
            mov (%edi,%edx,4),%eax
            cmp idFisier,%eax
            je get_capat
            inc %edx
            inc %ecx
            jmp loop_inceputInt
        
        iesi:
        
        push $0
        push $0
        push $0
        push $0
        push $printFormat_get
        call printf 
        add $20,%esp
        jmp back

incLen_array:
    inc %ebx
    cmp $256,%ebx
    jge iesi
    mov %ebx,linieArray
    push %edx
    mov (%esi,%ebx,4),%edx
    mov %edx,lenArrayCurrent
    pop %edx

    mov $256,%edx
    imul %ebx,%edx
    xor %ecx,%ecx
    
    jmp loop_inceputInt

get_capat:
    push %ecx
    
    loop_capatInt:                  #trb facut pt matrix
        
        mov (%edi,%edx,4),%eax
        cmp idFisier,%eax
        jne get_print
        inc %edx
        inc %ecx
        jmp loop_capatInt
get_print:
    
    dec %ecx
    pop %eax
    
    push %ecx
    push linieArray
    push %eax
    push linieArray
    push $printFormat_get
    call printf
    add $20,%esp
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
        mov (%esi,%ecx,4),%ebx
        mov %ebx,lenArrayCurrent
        xor %ebx,%ebx
        xor %edx,%edx
    
        loop_gasimFisier:
            cmp lenArrayCurrent,%ecx
            jge incLen_arrayDel
            mov (%edi,%edx,4),%eax
            cmp idFisier,%eax
            je del_capat
            inc %edx
            inc %ecx
            jmp loop_gasimFisier
del_capat:  
    loop_del:
        mov $0,%ebx
        mov %ebx,(%edi,%edx,4)
        inc %edx
        mov (%edi,%edx,4),%eax
        cmp idFisier,%eax
        jne parcurgereVector
        jmp loop_del
incLen_arrayDel:
    inc %ebx
    cmp $256,%ebx
    jge parcurgereVector
    push %edx
    mov (%esi,%ebx,4),%edx
    mov %edx,lenArrayCurrent
    pop %edx

    mov $256,%edx
    imul %ebx,%edx
    xor %ecx,%ecx
    
    jmp loop_gasimFisier
validArray:                 #validam daca mai exista 0 intre blocuri, daca exista, facem o shiftare la stanga cu 1 element  
    xor %ecx,%ecx
    mov (%esi,%ecx,4),%ebx
    mov %ebx,lenArrayCurrent
    xor %ebx,%ebx
    xor %edx,%edx

    loop_validArray:
        cmp %ecx,lenArrayCurrent
        je incLen_arrayDef 
        mov (%edi,%edx,4),%eax
        cmp $0,%eax
        je defrag
        inc %edx
        inc %ecx
        jmp loop_validArray
incLen_arrayDef:
    inc %ebx
    cmp $256,%ebx
    jge parcurgereVector
    
    push %edx
    mov (%esi,%ebx,4),%edx
    mov %edx,lenArrayCurrent
    pop %edx

    mov $256,%edx
    imul %ebx,%edx
    xor %ecx,%ecx
    jmp loop_validArray

defrag:         
     push %edx
     push %ecx #tinem minte unde am ramas
    push %ebx #pastram pe ce linie ne aflam
   
    loop_defrag:
        cmp %ecx,lenArrayCurrent
        je exit_loop

        inc %edx
        mov (%edi,%edx,4),%ebx
        dec %edx
        mov %ebx,(%edi,%edx,4)
        inc %edx
        inc %ecx
        jmp loop_defrag
    
    exit_loop:
    
    pop %ecx
    push %ecx
    
    mov lenArrayCurrent,%ebx
    mov $256,%edx
    imul %ecx,%edx
    dec %ebx
    add %ebx,%edx
    
    mov $0,%eax
    mov %eax,(%edi,%edx,4) #nulam blocul din capat pt shiftare la stanga
    
    mov %ebx,(%esi,%ecx,4)
    mov %ebx,lenArrayCurrent

    pop %ebx
    pop %ecx
    pop %edx
    jmp loop_validArray
    



exit:
    mov $1,%eax
    mov $0,%ebx
    int $0x80
