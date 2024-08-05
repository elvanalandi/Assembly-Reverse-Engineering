;-----------------------------------------------------
;  Student Login Program (Assignment.asm)
;  Name: Elvan Alandi
;  Student ID: 104078674
;  Unit Code: CYB80003
;  Date Submitted: 17/05/2024
;  Visual Studio Version: 2022
;-----------------------------------------------------

INCLUDE Irvine32.inc
BUFMAX = 128     	; Maximum buffer size
KEY = 250			; KEY between 1-255

.data
promptID		BYTE	"Enter student ID [1-30]: ", 0
promptPwd		BYTE	"Enter password: ", 0
promptSurname	BYTE	"Enter surname: ", 0
promptFirstname BYTE	"Enter first name: ", 0
promptDOB		BYTE	"Enter date of birth (DD/MM/YYYY): ", 0
invalidID		BYTE	"Incorrect student ID",0
invalidPass		BYTE	"Incorrect password, please try again",0
filename		BYTE	"output.txt",0
logFilename		BYTE	"log.txt",0
fileOpenErrMsg	BYTE	"Cannot open file",0dh,0ah,0
fileWriteErrMsg BYTE	"Cannot write data to file",0dh,0ah,0
successWriteMsg BYTE	"Your data has been successfully written to a file!",0dh,0ah,0
exitMsg			BYTE	"To exit the program, press Enter!",0
loginMsg		BYTE	"logged in", 0
pwd				BYTE	"student123",0

id				DWORD 0
idString		DWORD BUFMAX+1 DUP(0)
datetime		BYTE "%0.2d/%0.2d/%d %0.2d:%0.2d",0
password		DWORD BUFMAX+1 DUP(0)
surname			DWORD BUFMAX+1 DUP(0)
firstname		DWORD BUFMAX+1 DUP(0)
dob DWORD		BUFMAX+1 DUP(0)
bufSize			DWORD ?
log				DWORD BUFMAX+1 DUP(0)
buffer			DWORD BUFMAX+1 DUP(0)
fileHandle		DWORD ?	; Handle to output file
bytesWritten	DWORD ? ; Number of bytes written
delimiter		BYTE ", ",0
space			BYTE " ",0
sysTime			SYSTEMTIME <> ; System time structure

; Individual components of system time
day            DWORD ?
month          DWORD ?
year           DWORD ?
hour           DWORD ?
minute         DWORD ?

.code
StudentIdPrompt PROTO
StudentPassPrompt PROTO
SurnamePrompt PROTO
FirstnamePrompt PROTO
DobPrompt PROTO
UserInfoPrompt PROTO
CheckId PROTO
PasswordInput PROTO
TranslatePassword PROTO, text:DWORD, tSize:DWORD
ReadPassword PROTO
CheckPass PROTO
AppendToFile PROTO, data:DWORD, dSize:DWORD, file:PTR BYTE
StrLen PROTO, data:DWORD
IntToString PROTO, data:DWORD, resultBuffer:DWORD, bufferSize:DWORD
ConcatString PROTO, src:DWORD, dst:DWORD, sSize:DWORD

main PROC
	call StudentIdPrompt			; Prompting the student ID
	call StudentPassPrompt			; Prompting the student password
	exit
main ENDP

;-----------------------------------------------------
StudentIdPrompt PROC
;
; Prompts user for a student ID and check if the ID is valid or not. Saves the integer in id variable.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	pushad
IdPrompt:
	mov	edx,OFFSET promptID			; Display the student ID prompt
	call WriteString				; Write the prompt
	call ReadInt					; Read the integer value
	mov id, eax						; Store the entered integer value in the id variable
	call CheckId					; Call CheckId function
	cmp eax, 0						; Check if it is valid or not
	jz IdPrompt						; If invalid student ID detected, go to the student ID prompt
	popad
	ret
StudentIdPrompt ENDP

;-----------------------------------------------------
StudentPassPrompt PROC
;
; Prompts user for a password. Saves the password in password variable.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	pushad
	mov edx,OFFSET promptPwd		; Display the student password prompt
	call WriteString				; Write the prompt
	call PasswordInput				; Call a function to get user input without echoing to the console
	call Crlf
	popad
	ret
StudentPassPrompt ENDP

;-----------------------------------------------------
SurnamePrompt PROC
;
; Prompts user for a surname in string. Saves the surname in surname variable.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	pushad
	mov edx,OFFSET promptSurname	; Display the surname prompt
	call WriteString				; Write the prompt
	mov edx, OFFSET surname			; Pointer to the surname
	mov ecx, BUFMAX
	call ReadString
	popad
	ret
SurnamePrompt ENDP

;-----------------------------------------------------
FirstnamePrompt PROC
;
; Prompts user for a firstname in string. Saves the firstname in firstname variable.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	pushad
	mov edx,OFFSET promptFirstname	; Display the first name prompt
	call WriteString				; Write the prompt
	mov edx, OFFSET firstname		; Pointer to the firstname
	mov ecx, BUFMAX
	call ReadString
	popad
	ret
FirstnamePrompt ENDP

;-----------------------------------------------------
DobPrompt PROC
;
; Prompts user for dob in string. Saves the dob in dob variable.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	mov edx,OFFSET promptDOB		; Display the date of birth prompt
	call WriteString				; Write the prompt
	mov ecx, BUFMAX
	mov edx, OFFSET dob				; Pointer to the dob
	call ReadString
	ret
DobPrompt ENDP

;-----------------------------------------------------
CheckId PROC
;
; Check if the ID is in the range of 1-30
; Receives: nothing
; Returns: EAX (1 = true | 0 = false)
;-----------------------------------------------------
	mov eax, 1                      ; Set eax to 1
    cmp eax, DWORD PTR [id]         ; Compare 1 with the entered ID
    jg Invalid                      ; Jump if the entered ID is greater than 1
    mov eax, 30                     ; Set eax to 30
    cmp eax, DWORD PTR [id]         ; Compare 30 with the entered ID
    jl Invalid                      ; Jump if the entered ID is less than 30
	mov eax, 1                      ; If 1 <= id <= 30, set eax to 1 (true)
    ret                             ; Return true

Invalid:
	mov	edx,OFFSET invalidID		; Display invalid student ID
	call WriteString				; Write the message
	call Crlf						; Carriage return line feed
	xor eax, eax					; If id is invalid, set eax to 0 (false)
	ret								; Return false
CheckId ENDP

;-----------------------------------------------------
CheckPass PROC
;
; Check if the password is correct or not
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	pushad
	cld								; Set the forward direction
	mov esi, OFFSET pwd				; Set pre-defined password to esi as the source
	mov eax, OFFSET password		; Load the memory address stored in buf into eax
	mov edi, eax					; Set user input password to edi as the destination
	mov ecx, LENGTHOF pwd			; Set the length of the password to ecx
	repe cmpsb						; Compare two strings
	jecxz Match						; Jump to Match if ecx is zero
	mov	edx,OFFSET invalidPass		; Display invalid password
	call WriteString				; Write the message
	call Crlf
	call StudentPassPrompt			; Prompting the student password
	call PasswordInput
	popad
	ret

Match:
	invoke StrLen, OFFSET password		; Calculate password length
	mov bufSize, ecx					; Move the length into bufSize variable
	invoke TranslatePassword, OFFSET password, bufSize	; Encrypt the password
	call UserInfoPrompt
	popad
	ret
CheckPass ENDP

;-----------------------------------------------------
UserInfoPrompt PROC
;
; Prompts user for surname, firstname, and dob. Collate the entered information and write it to the text file.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------
	invoke IntToString, id, OFFSET idString, BUFMAX			; Change the integer to string
	invoke StrLen, OFFSET idString							; Get the ID length
	mov bufSize, ecx										; Move firstname length to bufSize variable
	invoke ConcatString, OFFSET idString, OFFSET buffer, bufSize		; Append the ID to buffer 
	invoke StrLen, OFFSET delimiter							; Get the delimiter length
	mov bufSize, ecx										; Move delimiter length to bufSize variable
	invoke ConcatString, OFFSET delimiter, OFFSET buffer, bufSize	; Append the delimiter to buffer

	invoke StrLen, OFFSET password							; Get the password length
	mov bufSize, ecx										; Move password length to bufSize variable
	invoke ConcatString, OFFSET password, OFFSET buffer, bufSize		; Append the password to buffer
	invoke StrLen, OFFSET delimiter							; Get the delimiter length
	mov bufSize, ecx										; Move delimiter length to bufSize variable
	invoke ConcatString, OFFSET delimiter, OFFSET buffer, bufSize	; Append the delimiter to buffer

	call SurnamePrompt										; Prompts the user for surname
	invoke StrLen, OFFSET surname							; Get the surname length
	mov bufSize, ecx										; Move surname length to bufSize variable
	invoke ConcatString, OFFSET surname, OFFSET buffer, bufSize	; Append the surname to buffer
	invoke StrLen, OFFSET delimiter							; Get the delimiter length
	mov bufSize, ecx										; Move delimiter length to bufSize variable
	invoke ConcatString, OFFSET delimiter, OFFSET buffer, bufSize	; Append the delimiter to buffer

	call FirstnamePrompt									; Prompts the user for firstname
	invoke StrLen, OFFSET firstname							; Get the firstname length
	mov bufSize, ecx										; Move firstname length to bufSize variable
	invoke ConcatString, OFFSET firstname, OFFSET buffer, bufSize	; Append the firstname to buffer
	invoke StrLen, OFFSET delimiter							; Get the delimiter length
	mov bufSize, ecx										; Move delimiter length to bufSize variable
	invoke ConcatString, OFFSET delimiter, OFFSET buffer, bufSize	; Append the delimiter to buffer

	call DobPrompt											; Prompts the user for dob
	invoke StrLen, OFFSET dob								; Get the dob length
	mov bufSize, ecx										; Move dob length to bufSize variable
	invoke ConcatString, OFFSET dob, OFFSET buffer, bufSize	; Append the dob to buffer
	invoke StrLen, OFFSET buffer							; Get the buffer length
	mov bufSize, ecx										; Insert the length to bufSize
	invoke AppendToFile, OFFSET buffer, bufSize, ADDR filename	; Append the buffer to a file

	invoke GetLocalTime, ADDR sysTime						; Get current local time
	movzx eax, sysTime.wDay					; Day
	mov day, eax							; Move day value to the variable

	movzx eax, sysTime.wMonth				; Month
	mov month, eax							; Move month value to the variable

	movzx eax, sysTime.wYear				; Year
	mov year, eax							; Move year value to the variable

	movzx eax, sysTime.wHour				; Hour
	mov hour, eax							; Move hour value to the variable

	movzx eax, sysTime.wMinute				; Minute
	mov minute, eax							; Move minute value to the variable

	; wsprintf is a Windows procedure that helps with formatting the date and time.
	; This code is cited from https://masm32.com/board/index.php?topic=10244.0
	invoke wsprintf, ADDR log, OFFSET datetime, month, day, year, hour, minute ; Put formatted date and time into log.

	invoke ConcatString, OFFSET space, OFFSET log, 1			; Append space to log

	invoke StrLen, OFFSET firstname								; Get the firstname length
	mov bufSize, ecx											; Move firstname length to bufSize variable
	invoke ConcatString, OFFSET firstname, OFFSET log, bufSize	; Append the firstname to log
	invoke ConcatString, OFFSET space, OFFSET log, 1			; Append space to log

	invoke StrLen, OFFSET surname								; Get the surname length
	mov bufSize, ecx											; Move surname length to bufSize variable
	invoke ConcatString, OFFSET surname, OFFSET log, bufSize	; Append the surname to log
	invoke ConcatString, OFFSET space, OFFSET log, 1			; Append space to log
	invoke StrLen, OFFSET loginMsg								; Get the surname length
	mov bufSize, ecx											; Move loginMsg length to bufSize variable
	invoke ConcatString, OFFSET loginMsg, OFFSET log, bufSize	; Append login message to log

	invoke StrLen, OFFSET log									; Get the log length
	mov bufSize, ecx											; Insert the length to bufSize
	invoke AppendToFile, OFFSET log, bufSize, ADDR logFilename	; Append the log to a log file

	mov edx, OFFSET successWriteMsg								; Display success feedback message
	call WriteString											; Write the message on the console
	call Crlf
	mov edx, OFFSET exitMsg										; Display exit message
	call WriteString											; Write the message on the console

ReadEnterChar:
	call ReadChar												; Read a character from the console
    cmp al, 13													; Check if Enter key pressed
    jne ReadEnterChar											; If Enter key is not pressed, read the input character again
	call ExitProcess											; Exit program
	ret
UserInfoPrompt ENDP

;-----------------------------------------------------
ConcatString PROC src:DWORD, dst:DWORD, sSize:DWORD
;
; Concatenate two strings into one.
; Receives: source string pointer, destination string pointer, source buffer size
; Returns: concatenated string in destionation pointer
;-----------------------------------------------------
	pushad
	mov edi, DWORD PTR [dst]			; Store the address of the destination buffer
    mov eax, sSize						; Save the length of the source string in eax

	; Check if the destination string is empty
    cmp BYTE PTR [edi], 0				; Compare the first byte of the destination buffer with null terminator
    jne NotEmpty						; If not empty, jump to NotEmpty

	; If destination string is empty, directly copy the source string to the destination buffer
    mov esi, DWORD PTR [src]			; Load address of source string
    cld									; Ensure direction flag is cleared (forward direction)
    rep movsb							; Copy bytes from [esi] to [edi]
    popad
    ret

NotEmpty:
; Find the null terminator
    xor ecx, ecx				; Initialize counter to 0
FindNull:
    cmp BYTE PTR [edi + ecx], 0	; Compare the byte at [edi + ecx] with null terminator
    je Copy						; If null terminator found, jump to Copy
    inc ecx						; Increment counter
    jmp FindNull				; Continue searching

Copy:
	add edi, ecx	            ; Move edi to the end of the destination string

    ; Copy the source string to the destination after the null terminator
    mov esi, [src]				; Load address of source string
    mov ecx, eax				; Copy the length of the source string
	cld							; Ensure direction flag is cleared (forward direction)
    rep movsb					; Copy bytes from [esi] to [edi]
	popad
	ret
ConcatString ENDP

;-----------------------------------------------------
PasswordInput PROC
;
; Input password and check the encrypted password with pre defined password.
; Receives: nothing
; Returns: nothing
;-----------------------------------------------------

	; Clear the password buffer
    mov edi, OFFSET password        ; Destination pointer (password buffer)
    mov ecx, BUFMAX                 ; Number of bytes to clear
    mov eax, 0                      ; Clear value (null terminator)
    rep stosb                       ; Fill the password buffer with null terminators

	; Read the password from the console
    mov edx, OFFSET password			; Pointer to the buffer
    mov ecx, BUFMAX						; Maximum character count
	call ReadPassword					; Read the input
	
	call Crlf
	invoke CheckPass					; Check the password against pre defined password
	ret
PasswordInput ENDP

;-----------------------------------------------------
TranslatePassword PROC text:DWORD, tSize:DWORD
;
; Encrypt and Decrypt password (Overwriting the original password data).
; Receives: password as text, password size as tSize
; Returns: encrypted password in the text buffer
;-----------------------------------------------------
	pushad					; Pushes the contents of the general-purpose registers onto the stack
	mov	ecx,tSize			; Loop counter
	mov	esi,[text]			; Start of the buffer

TranslationLoop:
	xor	BYTE PTR [esi],KEY	; Translate a byte with the KEY
	inc	esi					; Move to the next byte in the source buffer
	loop TranslationLoop	; Continue until all bytes are translated

	popad					; Pops the stack
	ret
TranslatePassword ENDP

;-----------------------------------------------------
ReadPassword PROC
;
; Input password without showing on the screen and store the character in the EDX.
; Receives: nothing
; Returns: EDX with the password
;-----------------------------------------------------
ReadInput:
	call ReadChar					; Read a character from the console
    cmp al, 13						; Check if Enter key pressed
    je EndInput						; If Enter key pressed, end input
	cmp al, 8						; Check if Backspace key pressed
	je EraseInput					; If Backspace key pressed, erase input
    mov BYTE PTR [edx], al			; Store the character in the buffer
    inc edx							; Move to the next character in the buffer
	loop ReadInput
EraseInput:
	dec edx							; Move edx back by one character
	jmp ReadInput					; Reading the input again
EndInput:
    mov BYTE PTR [edx], 0			; Null-terminate the input buffer
	ret								; Return
ReadPassword ENDP

;-----------------------------------------------------
AppendToFile PROC data:DWORD, dSize:DWORD, file:PTR BYTE
;
; Append data to file.
; Receives: buffer as data, buffer size as dSize
; Returns: EDX with the password
;-----------------------------------------------------
	LOCAL newData:BYTE						; Local buffer to hold the appended byte
	pushad

	mov fileHandle, NULL					; Initialize the file handle

	; Open the file in append mode
    invoke CreateFile, file, FILE_APPEND_DATA, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ; Create the file if it does not exist and append the data on the file
	mov fileHandle, eax						; Move the return value (file handle) to fileHandle
    cmp fileHandle, INVALID_HANDLE_VALUE	; Check if the file handle is invalid
    je OpenFailed							; If invalid, go to OpenFailed

	; Move file pointer to the end of the file
    invoke SetFilePointer, fileHandle, 0, NULL, FILE_END

	; Append a newline character to the data
    mov BYTE PTR newData, 10    ; ASCII code for newline character

	; Write data to the file
    invoke WriteFile, fileHandle, data, dSize, ADDR bytesWritten, NULL
    test eax, eax	; Check if writing data is failed
    jz WriteFailed	; If zero, writing data is failed

	; Write the newline character to the file
    invoke WriteFile, fileHandle, ADDR newData, SIZEOF newData, ADDR bytesWritten, NULL
    test eax, eax
    jz WriteFailed

    invoke CloseHandle, fileHandle		; Close the file handle
	popad
    ret

OpenFailed:
	mov  edx,OFFSET fileOpenErrMsg		; Display error message
	call WriteString
    invoke CloseHandle, fileHandle		; Close the file handle
	popad
	ret

WriteFailed:
	mov  edx,OFFSET fileWriteErrMsg		; Display error message
	call WriteString
    invoke CloseHandle, fileHandle		; Close the file handle
	popad
	ret

AppendToFile ENDP

;-----------------------------------------------------
StrLen PROC, data:DWORD
;
; Get the length of string.
; Receives: buffer as data
; Returns: ECX as the length
;-----------------------------------------------------
	mov ecx, 0							; Initialize a counter to 0
	mov esi, data						; Move the data to source index
	mov edi, esi						; Copy the buffer to edi for comparison
	cld									; Set the direction flag to forward

CountChar:
	lodsb								; Load the next byte from the buffer into al and increment esi
	test al, al							; Check if the byte is null
	jz EndCount							; If null, jump to the end
	inc ecx								; Increment the counter
	jmp CountChar						; Counting the next character

EndCount:
	ret
StrLen ENDP

;-----------------------------------------------------
IntToString PROC, data:DWORD, resultBuffer:DWORD, bufferSize:DWORD
;
; Change integer to string.
; Receives: buffer as data, output variable as resultBuffer, the size of buffer as bufferSize
; Returns: resultBuffer
;-----------------------------------------------------
	pushad
	mov ebx, 10d			; EBX = divisor of 10
	mov eax, data			; Move the data to EAX
	xor ecx, ecx            ; Initialize counter to the length of the string
	mov esi, DWORD PTR [resultBuffer]   ; Store the address of the result buffer
    mov edi, bufferSize     ; Store the size of the result buffer

ConvertInt:
    mov edx, 0              ; Clear edx before division
    div ebx                 ; EAX = quot, EDX = remainder
    add dl, 30h             ; Convert EDX to ASCII char value
    cmp ecx, edi            ; Check if counter exceeds buffer size
    jae EndLoop             ; If so, exit the loop
    test eax, eax           ; Check if quotient is zero
	jnz NotSingleDigit		; If not zero, continue conversion digit by digit
	; Handle single digit number
    push edx				; Store ASCII character in stack
    inc ecx                 ; Increment counter
    jmp EndLoop				; Start reversing the digit

NotSingleDigit:
	push edx				; Store ASCII character in stack
    inc ecx                 ; Increment counter
    test eax, eax           ; Check if quotient is zero
    jnz ConvertInt          ; If not zero, continue conversion

EndLoop:
	mov esi, DWORD PTR [resultBuffer]   ; Store the address of the result buffer
    mov edi, ecx						; Store the counter
	xor edi, edi						; Initialized EDI, EDI = 0

ReverseLoop:
	pop ebx					; Pop digit from stack
	mov [esi+edi], bl		; Input digit to resultBuffer
	inc edi					; Increment the buffer
	loop ReverseLoop		; Loop until ECX = 0

EndReverse:
    mov ecx, esi            ; Move the start of the buffer to ecx
    add ecx, edi            ; Move ecx to the end of the buffer
    mov BYTE PTR [ecx], 0	; Null-terminate the string
	popad
	ret
IntToString ENDP

END main
