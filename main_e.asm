%line 1+1 lib.inc
[extern exit]
[extern string_length]
[extern print_string]
[extern print_char]
[extern print_newline]
[extern print_uint]
[extern print_int]
[extern string_equals]
[extern read_char]
[extern read_word]
[extern parse_uint]
[extern parse_int]
[extern string_copy]
%line 3+1 words.inc
[section .data]

genders_dict:

%line 4+1 colon.inc
 woman:
 dq 0
 db "Woman", 0
%line 8+1 words.inc
db "Oh_my_god", 0

%line 4+1 colon.inc
 man:
 dq woman
 db "Man", 0
%line 11+1 words.inc
db "Content", 0


%line 1+1 dict.inc
[extern find_word]
%line 9+1 main.asm
[section .bss]
buf: resb 255

[section .data]
INPT_ERR: db "Input error", 0
NOT_FOUND_ERR: db "Entry not found", 0
SHIT: db "shit", 0

[section .text]

[global _start]

_start:
 mov rdi, buf
 mov rsi, 255
 call read_word

 test rax, rax
 mov rdi, INPT_ERR
 mov rsi, 2
 jz .printer

 mov rdi, rax
 mov rsi, genders_dict
 call find_word
 test rax, rax
 mov rdi, NOT_FOUND_ERR
 mov rsi, 2
 jz .printer

 add rax, 8

 mov rdi, rax
 push rdi
 call string_length
 pop rdi
 add rdi, rax

 add rdi, 1
 mov rsi, 1
 .printer:
 call print_string
 mov rdi, 0
 call exit


