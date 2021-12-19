CHIP SN8F2288

//{{SONIX_CODE_OPTION
	; Options for Lenovo Compact Keyboard
	.Code_Option	Fcpu		"Fosc/4"
	.Code_Option	Fslow		"Flosc/2"
	.Code_Option	High_CLK	"12M_X'tal"
	.Code_Option	LVD		"LVD_M"
	.Code_Option	Reset_Pin	"P07"
	.Code_Option	Rst_Length	"No"
	.Code_Option	Security	"Enable"
	.Code_Option	Watch_Dog	"Enable"
//}}SONIX_CODE_OPTION

.DATA
_canary_check EQU 0x2880
_flasher      EQU 0x2890
UTX           EQU P0.6    ; S15
UTTXIRQ       EQU INTRQ1.3
URX           EQU P0.5    ; S10
S10           EQU P0.5
R6            EQU P1.5

.CODE
ORG 0x0 ; Reset vector
	; Jump to bootloader, checks canary and continues execution at 0x10 if found
	JMP _canary_check

ORG 0x8 ; Interrupt vector
	JMP _flasher

ORG 0x10 ; Bootloader jumps here on successful canary check, start of payload execution
_start:
	; Set stack pointer and disable interrupts
	MOV A, #7
	B0MOV STKP, A

	MOV A, #0
	B0MOV RBANK, A

	; Jump into bootloader if watchdog triggered or undefined reset source
	B0BTS1 FNT0
	JMP _flasher    ; NT0 == 0 => watchdog reset or undefined reason

	; Light up the power LED (P5.3/PWM0)
	B0BCLR P5.3   ; Set to low level to light up
	B0BSET P5M.3  ; Set to output

	; DS indicates watchdog may start running before CPU
	; Tickle it once so we have a well-defined time left
	MOV A, #0x5a
	B0MOV WDTR, A

	; Set up P0.6/UTX (UART TX)
	B0BSET P0UR.6 ; Enable pull-up (UART idle is high)
	B0BCLR P0M.6  ; Set to input (TXEN will override to output)
	MOV A, #0x60  ; Baud 115200
	B0MOV URBRC, A
	MOV A, #0x90  ; 24MHz clock, TX enabled, 8n1, 1-byte mode
	B0MOV URTX, A

	; Send a message that we are alive
	MOV A, #'H'
	CALL _uart_tx
	MOV A, #'i'
	CALL _uart_tx
	MOV A, #'!'
	CALL _uart_tx
	MOV A, #13
	CALL _uart_tx
	MOV A, #10
	CALL _uart_tx

	; Jump into bootloader if "Return" key (S10/R6) is held
	B0BSET P0M.5 ; Set S10 to output
	B0BCLR P1M.5 ; Set R6 to input
	B0BSET P1UR.5 ; Enable pull-up on R6

	B0BSET S10   ; Set S10 high
	CALL _delayshort
	B0BTS1 R6    ; Jump if R6 is low
	JMP @F
	B0BCLR S10   ; Set S10 low
	CALL _delayshort
	B0BTS1 R6    ; Jump if R6 is low
	JMP _return_held
@@:

	; Jump into bootloader if P0.5/P0.6 are shorted (URX/UTX)
	B0BCLR 0xa9.4 ; Switch UTX back to GPIO
	B0BSET P0M.6 ; Set UTX to output
	B0BCLR P0M.5 ; Set URX to input
	B0BSET P0UR.5 ; Enable pull-up on URX

	B0BSET UTX   ; Set P0.6/UTX high
	CALL _delayshort
	B0BTS1 URX   ; Jump if P0.5/URX is low
	JMP @F
	B0BCLR UTX   ; Set P0.6/UTX low
	CALL _delayshort
	B0BTS1 URX   ; Jump if P0.5/URX is low
	JMP _uart_shorted
@@:
	B0BSET 0xa9.4 ; Switch UTX back to UART


	; Reset either from undervoltage (power-on) or external reset
	; Cold reset state per datasheet:
	; - Clock is 12MHz PLL synced to external oscillator
	; - IOs set to input

	MOV A, #0
	B0MOV Y, A
@@:
	MOV A, Y
	CALL _uart_hex
	INCMS Y
	NOP
	JMP @B

	JMP _flasher

_return_held:
	MOV A, #'E'
	CALL _uart_tx
	MOV A, #'r'
	CALL _uart_tx
	JMP _flasher

_uart_shorted:
	B0BSET 0xa9.4 ; Switch UTX back to UART
	MOV A, #'E'
	CALL _uart_tx
	MOV A, #'s'
	CALL _uart_tx
	JMP _flasher

_uart_hex:
	MOV R, A
	SWAP R
	CALL _uart_nibble
	MOV A, R
	; fall-through

_uart_nibble:
	AND A, #0xf
	ADD A, #0xf6 ; -0xa
	B0BTS0 FC    ; Skip next insn if carry unset
	ADD A, #0x27 ; 'a' - '0' - 0xa
	ADD A, #0x3a ; '0' + 0xa
	; fall-through

_uart_tx:
	B0MOV URTXD1, A
@@:
	B0BTS1 FUTTXIRQ  ; Check if TX is done
	JMP @B
	B0BCLR FUTTXIRQ
	RET

_delayshort:
	MOV A, #0
	B0MOV R, A
@@:
	DECMS R
	JMP @B
	RET

ORG 0x27ff
	DW  0xaaaa          ; canary

ORG _canary_check
	JMP _start

ORG _flasher
	JMP $
