%include "lib.inc"
%include "words.inc"
%include "dict.inc"

%define SYS_OUT 1
%define SYS_ERR 2
%define BUF_SIZE 255

section .bss
buf: resb BUF_SIZE

section .data
INPT_ERR: db "Input error", 0
NOT_FOUND_ERR: db "Entry not found", 0
SHIT: db "shit", 0

section .text

global _start

_start:
        mov rdi, buf
        mov rsi, BUF_SIZE
        call read_word                  ; адрес буфера в rax, длина слова в rdx

        test rax, rax                   ; тест корректного считывания слова из STDIN
        mov rdi, INPT_ERR
        mov rsi, SYS_ERR
        jz .printer

        mov rdi, rax
        mov rsi, genders_dict
        call find_word
        test rax, rax                   ; наход/ненаход
        mov rdi, NOT_FOUND_ERR
        mov rsi, SYS_ERR 
        jz .printer

        add rax, 8                      ; указатель ставим на значение

        mov rdi, rax                    ; блок передвигает указатель на значение
        push rdi
        call string_length
        pop rdi
        add rdi, rax

        add rdi, 1
        mov rsi, SYS_OUT
        .printer:
                call print_string
                mov rdi, 0
                call exit


