section .data
    prompt_num1 db "Enter the first number (0-9): ", 0
    prompt_num1_len equ $ - prompt_num1
    prompt_num2 db "Enter the second number (0-9): ", 0
    prompt_num2_len equ $ - prompt_num2
    prompt_op db "Choose operation (+, -, *, /): ", 0
    prompt_op_len equ $ - prompt_op
    result_msg db "Result: ", 0
    result_msg_len equ $ - result_msg
    newline db 10, 0
    buffer db 10, 0 ; Buffer for user input
    error_msg db "Invalid input. Please enter a single digit (0-9).", 0
    error_msg_len equ $ - error_msg

section .bss
    a resb 1
    b resb 1
    result resb 1
    operation resb 1

section .text
    global _start

_start:
    call read_first_number
    call read_second_number
    call read_operation
    call perform_operation
    call print_result

    ; Exit the program
    mov eax, 1
    xor ebx, ebx
    int 0x80

read_first_number:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_num1
    mov edx, prompt_num1_len
    int 0x80

    call read_single_digit
    mov [a], al
    ret

read_second_number:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_num2
    mov edx, prompt_num2_len
    int 0x80

    call read_single_digit
    mov [b], al
    ret

read_single_digit:
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 10
    int 0x80

    ; Check if the input is a valid single digit (0-9)
    cmp byte [buffer], '0'
    jb invalid_input
    cmp byte [buffer], '9'
    ja invalid_input

    sub byte [buffer], '0' ; Convert ASCII to integer
    mov al, [buffer]
    ret

invalid_input:
    ; Print error message
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, error_msg_len
    int 0x80
    jmp _start ; Restart the input process

read_operation:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_op
    mov edx, prompt_op_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 10
    int 0x80

    mov al, [buffer]        ; Get the operation character
    mov [operation], al
    ret

perform_operation:
    mov al, [a]
    mov bl, [b]
    mov cl, [operation]

    cmp cl, '+'            ; Check for addition
    je add_numbers
    cmp cl, '-'            ; Check for subtraction
    je sub_numbers
    cmp cl, '*'            ; Check for multiplication
    je mul_numbers
    cmp cl, '/'            ; Check for division
    je div_numbers

    jmp end_operation

add_numbers:
    add al, bl
    jmp store_result

sub_numbers:
    sub al, bl
    jmp store_result

mul_numbers:
    mul bl
    jmp store_result

div_numbers:
    cmp bl, 0              ; Check for division by zero
    je division_by_zero
    xor ah, ah             ; Clear AH for division
    div bl
    jmp store_result

division_by_zero:
    ; Print error message for division by zero
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, error_msg_len
    int 0x80
    jmp _start ; Restart the input process

store_result:
    mov [result], al
    jmp end_operation

end_operation:
    ret

print_result:
    mov al, [result]
    add al, '0'                  ; Convert to ASCII
    mov [result], al             ; Store the ASCII character back in result

    mov eax, 4
    mov ebx , 1
    mov ecx, result_msg
    mov edx, result_msg_len
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, result
    mov edx, 1
    int 0x80

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
