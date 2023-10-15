global exit
global string_length
global print_string
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global read_word
global parse_uint
global parse_int
global string_copy

SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60

section .text

; Принимает код возврата и завершает текущий процесс
exit: 
    mov rax, SYS_EXIT
    syscall

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    mov  rax, rdi
        .counter:
            cmp byte [rax], 0
            je .end
            inc rax
            jmp .counter
        .end:
            sub rax, rdi
            ret 

; Принимает указатель на нуль-терминированную строку и дескриптор стандартного потока,
; в который будет выведена строка
print_string:
    push rdi                        ; указатель на строку
    push rsi                        ; дескриптор
    call string_length
    pop rdi                         ; дескриптор
    pop rsi                         ; указатель

    mov  rdx, rax
    mov  rax, SYS_WRITE
    syscall
    ret

; Принимает код символа и выводит его в stdout
print_char:
    push 0
    mov [rsp], dil                  ; размещение кода символа в памяти
    mov rax, SYS_WRITE
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rax
    ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rsi, '\n'
    call print_char
    ret

; Выводит беззнаковое 8-байтовое число в десятичном формате
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    sub rsp, 32                     ; Аллоцируем
    mov rax, rdi
    mov r8, 10                      ; Делитель
    lea r9, [rsp + 20]
    mov byte [r9], 0

    .loop:
        xor rdx, rdx
        div r8
        add dl, '0'                 ; Конвертация в ASCII
        dec r9
        mov [r9], dl
        test rax, rax
        jnz .loop

    mov rdi, r9                     ; Возврат, чтобы rdi указывал на начало строки
    call print_string

    add rsp, 32                     ; Деаллоцируем
    ret

; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    xor rcx, rcx

    test rdi, rdi
    jnl print_uint                  ; если положительное, беззнаковый вывод

    push rdi                        ; иначе вывод "-", меняем знак, печатаем беззнаковое
    mov rdi, '-'
    call print_char
    pop rdi
    neg rdi
    jmp print_uint


; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
    xor rdx, rdx                    ; итератор
    xor rax, rax
    .loop:
        mov r8b, [rdi+rdx]
        cmp r8b, [rsi+rdx]          ; проверка равенства
        jnz .fail

        inc rdx
        test r8b, r8b
        jnz .loop

    .success:
        inc rax
        ret

    .fail:
        ret

; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    push 0
    mov rax, SYS_READ
    mov rdi, 0
    mov rsi, rsp
    mov rdx, 1
    syscall

    cmp rax, 0
    jle .fail
    mov rax, [rsp]
    pop rdx
    ret

    .fail:
        pop rdx
        ret

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор
; IN (rdi,rsi) OUT (rax,rdx)
read_word:               
    push r12
    push r13
    test rsi, rsi
    je .fail   
    xor  rbx, rbx
    mov  r12, rdi
    mov  r13, rsi
    xor r9, r9

    .whitespace_reader:
        call read_char              ; -> RAX
        test rax, rax
        jz .fail
        call .whitespace_checker    ; -> RDX={0,1,2}
        cmp  rdx, 1
        jb   .whitespace_reader
        ja   .fail  
                                
    .word_reader:
        inc  r9
        cmp  r9, r13
        jnb  .fail 
        mov  [r12], rax
        inc  r12
        call read_char              ; -> RAX
        call .whitespace_checker    ; -> RDX={0,1,2}
        cmp  rdx, 1
        je   .word_reader
    .success:
        mov  byte [r12], 0          ; Нуль-терминируем
        mov  rax, r12
        sub  rax, r9
        
        push rdi
        push rax
        mov rdi, rax
        call string_length
        mov rdx, rax
        pop rax
        pop rdi
        jmp  .done

    ; IN (rax) OUT (rdx)
    .whitespace_checker:
        xor  rdx, rdx
        cmp  rax, ` `
        je   .ret
        cmp  rax, `\n`
        je   .ret
        cmp  rax, `\t`
        je   .ret
        inc  rdx
        test rax, rax
        jnz  .ret
        inc  rdx
    .ret:
        ret
        
    .fail:
        xor rax, rax
        xor rdx, rdx 
    .done:
        pop  r13
        pop  r12
        ret

; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
    xor rsi, rsi
    xor rax, rax
    xor r8, r8
    mov r9, 10

    .loop:
        mov sil, [rdi+r8]
        cmp sil, '0'
        jb .exit
        cmp sil, '9'
        ja .exit

        inc r8
        sub sil, 0x30
        mul r9
        add rax, rsi
        jmp .loop

    .exit:
        mov rdx, r8
        ret


; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int:
    .sign_reader:
        mov al, byte [rdi]
        cmp rax, '-'
        jne .positive
        

    .negative:
        inc rdi
        call parse_uint
        neg rax
        inc rdx
        ret
    
    .positive:
        cmp rax, '+'
        je .plus
        
    .default:
        call parse_uint
        ret

    .plus:
        inc rdi
        call parse_uint
        inc rdx

; Принимает указатель на строку rdi, указатель на буфер rsi и длину буфера rdx
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    xor r8, r8
    test rdx, rdx
    je .fail
    .loop:
        mov al, [rdi+r8]
        mov [rsi+r8], al
        inc r8
        cmp r8, rdx
        jae .fail                   ; Выход, если превысили размер буфера
        test al, al
        jnz .loop
    
    cmp rax, '+'
    .success:
        mov rax, r8
        ret

    .fail:
        xor rax, rax
        ret