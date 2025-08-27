; Trivial (unoptimized) program that calculates djb2 hash of stdin
; Written in 2025 just for fun by Mislav Bozicevic, nothing big or professional
;    
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

[bits 32]

section .bss
buffer resb 9 ; 9-byte buffer

section .text
global _start

_start:
    mov    edi, 5381    ; set hash to the initial value
.next_char:
    mov    edx, 1       ; maximum input buffer length
    mov    ecx, buffer  ; buffer
    mov    ebx, 0       ; stdin
    mov    eax, 3       ; read syscall
    int    0x80

    cmp    eax, 0           ; if read <= 0
    jle    short .end_read  ; then end

    mov    al, byte [buffer]
    test   al, al           ; if '\0'
    jz     short .end_read  ; then end

    mov    edx, edi    ; hash = ((hash << 5) + hash) + c
    shl    edx, 5      ; ref: https://groups.google.com/g/comp.lang.c/c/lSKWXiuNOAk
    add    edi, edx    ; ((hash << 5) + hash) is equivalent to (hash * 33)
    add    edi, eax    ; + c

    jmp    short .next_char

.end_read:
    mov    edx, edi        ; number to convert to hex representation
    mov    ebx, buffer     ; where to store the hex representation
    lea    edi, [ebx + 7]  ; start from buffer[7]
.next_nibble:
    mov    eax, edx
    and    eax, 0x0f       ; isolate the low nibble
    lea    ecx, [eax + 'a' - 10] ; a...f
    add    eax, '0'              ; 0...9
    cmp    ecx, 'a'
    cmovae eax, ecx              ; use a...f value, if it is in range
    mov    byte [edi], al
    dec    edi                   ; counting downwards
    shr    edx, 4
    cmp    edi, ebx
    jae    .next_nibble

    mov    al, 0x0a
    mov    ebx, buffer
    lea    edi, [ebx + 8]
    mov    byte [edi], al ; terminate with a line feed

    mov    edx, 9         ; length
    mov    ecx, buffer    ; buffer
    mov    ebx, 1         ; stdout
    mov    eax, 4         ; write syscall
    int    0x80

    xor    ebx, ebx       ; exit code
    mov    eax, 1         ; exit syscall
    int    0x80

