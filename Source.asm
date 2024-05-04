INCLUDE Irvine32.inc

INVALID_HANDLE_VALUE equ -1
KEY = 2           ; any value between 1-255
BUFMAX = 128        ; maximum buffer size /string size

.data
filename BYTE "output.txt", 0
errorMsg BYTE "Error during file operation!", 0
successMsg BYTE "File operation successful!", 0
fileHandle HANDLE ?
sPrompt BYTE "Enter the plain text: ",0
sEncrypt BYTE "Cipher text:          ",0
sDecrypt BYTE "Decrypted:            ",0
buffer BYTE BUFMAX DUP(0)
bufSize DWORD ?

.code
main PROC
    ; Call the file handling function
    mov edx, OFFSET filename
    call OpenFileForWriting

    ; Check if the file handle is valid
    cmp eax, INVALID_HANDLE_VALUE
    je fileOperationError

    ; File operation successful
    mov edx, OFFSET successMsg
    call WriteString

    ; Encrypt the buffer
    call InputTheString      ; input the plain text
    call TranslateBuffer     ; encrypt the buffer
    mov edx, OFFSET sEncrypt  ; display encrypted message
    call DisplayMessage

    ; Save the encrypted text to the file
    mov eax, fileHandle
    mov edx, OFFSET buffer
    mov ecx, bufSize
    call WriteaFile

    ; Decrypt the buffer
    call TranslateBuffer     ; decrypt the buffer
    mov edx, OFFSET sDecrypt  ; display decrypted message
    call DisplayMessage

    ; Save the decrypted text to the file
    mov eax, fileHandle
    mov edx, OFFSET buffer
    mov ecx, bufSize
    call WriteaFile

    ; Close the file handle
    mov eax, fileHandle
    call ClseFile

    ; Exit the program
    call ExitProcess

fileOperationError:
    ; Display error message
    mov edx, OFFSET errorMsg
    call WriteString

    ; Exit the program with an error code
    mov eax, 1
    call ExitProcess

main ENDP
CreateFileForWriting PROC
    ; Input: eax - access mode (GENERIC_WRITE)
    ;        edx - filename
    ; Output: eax - file handle (INVALID_HANDLE_VALUE if error)
    LOCAL hFile:HANDLE

    ; Create or open the file for writing
    invoke CreateFile, edx, eax, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov hFile, eax

    ; Check for errors
    cmp hFile, INVALID_HANDLE_VALUE
    je CFError

    ; Return the file handle
    mov eax, hFile
    ret

CFError:
    ; Set error code and return INVALID_HANDLE_VALUE
    mov eax, INVALID_HANDLE_VALUE
    ret

CreateFileForWriting ENDP


OpenFileForWriting PROC
    ; Input: edx - filename
    ; Output: eax - file handle (INVALID_HANDLE_VALUE if error)
    mov eax, GENERIC_WRITE
    call CreateFileForWriting
    mov fileHandle, eax
    ret
OpenFileForWriting ENDP

ClseFile PROC
    ; Input: None
    ; Output: None
    LOCAL result:dword

    mov eax, fileHandle      ; Get the file handle
    invoke CloseHandle, eax  ; Call the CloseHandle function
    mov result, eax          ; Save the result

    ; Check for errors
    ;test result, result
    jz  CFError

    ret

CFError:
    ; Handle the error (you may want to add appropriate error handling code)
    ; For now, just set eax to an error value (e.g., 0) and continue
    mov eax, 0
    ret

ClseFile ENDP

WriteaFile PROC
    ; Input: None
    ; Output: None
    LOCAL bytesWritten:DWORD

    mov eax, fileHandle       ; Get the file handle
    mov edx, OFFSET buffer    ; Pointer to the buffer
    mov ecx, bufSize          ; Number of bytes to write
    lea ebx, bytesWritten     ; Pointer to the variable that receives the number of bytes written

    invoke WriteFile, eax, edx, ecx, ebx, 0 ; Call the WriteFile function

    ; Check for errors
    test eax, eax
    jz  WFAError

    ret

WFAError:
    ; Handle the error (you may want to add appropriate error handling code)
    ; For now, just set eax to an error value (e.g., 0) and continue
    mov eax, 0
    ret

WriteaFile ENDP




InputTheString PROC
    ; Input: None
    ; Output: None
    mov edx, OFFSET sPrompt
    call WriteString
    mov ecx, BUFMAX
    mov edx, OFFSET buffer
    call ReadString
    mov bufSize, eax
    call Crlf
    ret
InputTheString ENDP

TranslateBuffer PROC
    ; Input: None
    ; Output: None
    mov ecx, bufSize
    xor esi, esi; mov esi, 0
L1:
    xor buffer[esi], KEY
    inc esi
    loopnz L1
    ret
TranslateBuffer ENDP

DisplayMessage PROC
    ; Input: None
    ; Output: None
    call WriteString
    mov edx, OFFSET buffer
    call WriteString
    call Crlf
    call Crlf
    ret
DisplayMessage ENDP

END main