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
URX           EQU P0.5    ; S10
S10           EQU P0.5
R6            EQU P1.5
EP0_BYTES     EQU 8

dispatchArg   DS 1

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
	; FIXME: PnUR is write-only, B0BSET/B0BCLR are likely broken
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
	B0BSET P1UR.5 ; Enable pull-up on R6.

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

	CALL _test_dispatch
	JMP $

_dispatch:
	B0MOV  dispatchArg, A
	JMP _dispatch_next
_dispatch_loop:
	B0MOV  A, R
	CMPRS  A, #0      ; Jump if last entry
	JMP _dispatch_jump_indirect
	CALL _inc_yz      ; skip jump target
	CALL _inc_yz
_dispatch_next:
	MOVC   ; Read ROM word into R (hi) and A (lo)
	CMPRS  A, dispatchArg ; Jump if not yet equal
	JMP _dispatch_loop
_dispatch_jump_indirect:
	CALL _inc_yz
	CALL _jmp_yz
	RET ; never reached, kept for disassembler

_inc_yz:
	INCMS Z
	JMP @F
	INCMS Y
	RET
@@:
	RET

_jmp_yz:  ; FIXME: Interrupts must be disabled
	; DS is underspecified, but experimentally it
	; looks like if CALL goes from level 0 to level 1,
	; then the return PC is stored in STK0H/STK0L
	;
	; Level STKPB2 STKPB1 STKPB0 HighByte LowByte
	;     0      1      1      1      n/a     n/a
	;     1      1      1      0    STK0H   STK0L
	;     2      1      0      1    STK1H   STK1L
	;     [...]
	;     6      0      0      1    STK5H   STK5L
	;     7      0      0      0    STK6H   STK6L
	;     8      1      1      1    STK7H   STK7L
	B0MOV A, STKP
	AND   A, #7
	B0ADD PCL, A
	JMP _set_stack_6 ; STKP 0 / Level 7
	JMP _set_stack_5 ; STKP 1 / Level 6
	JMP _set_stack_4 ; STKP 2 / Level 5
	JMP _set_stack_3 ; STKP 3 / Level 4
	JMP _set_stack_2 ; STKP 4 / Level 3
	JMP _set_stack_1 ; STKP 5 / Level 2
	JMP _set_stack_0 ; STKP 6 / Level 1
	JMP _set_stack_7 ; STKP 7 / Level 8 [or 0]
_set_stack_0:
	B0MOV A, Y
	B0MOV STK0H, A
	B0MOV A, Z
	B0MOV STK0L, A
	RET
_set_stack_1:
	B0MOV A, Y
	B0MOV STK1H, A
	B0MOV A, Z
	B0MOV STK1L, A
	RET
_set_stack_2:
	B0MOV A, Y
	B0MOV STK2H, A
	B0MOV A, Z
	B0MOV STK2L, A
	RET
_set_stack_3:
	B0MOV A, Y
	B0MOV STK3H, A
	B0MOV A, Z
	B0MOV STK3L, A
	RET
_set_stack_4:
	B0MOV A, Y
	B0MOV STK4H, A
	B0MOV A, Z
	B0MOV STK4L, A
	RET
_set_stack_5:
	B0MOV A, Y
	B0MOV STK5H, A
	B0MOV A, Z
	B0MOV STK5L, A
	RET
_set_stack_6:
	B0MOV A, Y
	B0MOV STK6H, A
	B0MOV A, Z
	B0MOV STK6L, A
	RET
_set_stack_7:
	B0MOV A, Y
	B0MOV STK7H, A
	B0MOV A, Z
	B0MOV STK7L, A
	RET

_test_dispatch1:
	DW 0x0001
	JMP _test_dispatch2
	DW 0xFFFF
	JMP _test_dispatch_err

_test_dispatch3:
	DW 0x0001
	JMP _test_dispatch4
	DW 0xFFFF
	JMP _test_dispatch_err

_test_dispatch5:
	DW 0x0001
	JMP _test_dispatch6
	DW 0xFFFF
	JMP _test_dispatch_err

_test_dispatch_err:
	MOV    A, #'E'
	CALL _uart_tx
	JMP $

_test_dispatch:
	; Should print "D246cba" (tested to do so on HW)
	MOV A, #'D'
	CALL _uart_tx
	MOV    A, #_test_dispatch1$M
	B0MOV  Y, A
	MOV    A, #_test_dispatch1$L
	B0MOV  Z, A
	MOV    A, #1
	CALL _dispatch
	MOV A, #'a'
	CALL _uart_tx
	RET

_test_dispatch2:
	MOV A, #'2'
	CALL _uart_tx
	MOV    A, #_test_dispatch3$M
	B0MOV  Y, A
	MOV    A, #_test_dispatch3$L
	B0MOV  Z, A
	MOV    A, #1
	CALL _dispatch
	MOV A, #'b'
	CALL _uart_tx
	RET

_test_dispatch4:
	MOV A, #'4'
	CALL _uart_tx
	MOV    A, #_test_dispatch5$M
	B0MOV  Y, A
	MOV    A, #_test_dispatch5$L
	B0MOV  Z, A
	MOV    A, #1
	CALL _dispatch
	MOV A, #'c'
	CALL _uart_tx
	RET

_test_dispatch6:
	MOV A, #'6'
	CALL _uart_tx
	RET


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

_device_descriptor:
	DB  0x12a      ; bLength
	DB  1          ; bDescriptorType (DEVICE)
	DB  0x00, 0x02 ; bcdUSB (2.00)
	DB  0, 0, 0    ; Class/Subclass/Protocol
	DB  EP0_BYTES  ; EP0 max packet size
	DB  0xef, 0x17 ; Vendor 0x17ef (Lenovo)
	DB  0x47, 0x60 ; Device 0x6047 (Lenovo ThinkPad Compact Keyboard with TrackPoint)
	DB  0x00, 0x01 ; bcdDevice (1.0)
	DB  1          ; iManufacturer (String 1)
	DB  2          ; iProduct (String 2)
	DB  0          ; iSerial (n/a)
_device_descriptor_end:

_configuration_descriptor:
	DB  9          ; bLength
	DB  2          ; bDescriptorType (CONFIGURATION)
	DB  0x3b, 0x00 ; wTotalLength
	DB  2          ; bNumInterfaces
	DB  1          ; bConfigurationValue
	DB  0          ; iConfiguration (n/a)
	DB  0xa0       ; bmAttributes (BUS_POWERED, REMOTE_WAKEUP)
	DB  50         ; bMaxPower (100mA)

	; Keyboard interface
	DB  9          ; bLength
	DB  4          ; bDescriptorType (INTERFACE)
	DB  0          ; bInterfaceNumber
	DB  0          ; bAlternateSetting
	DB  1          ; bNumEndpoints
	DB  3          ; bInterfaceClass (HID)
	DB  1          ; bInterfaceSubClass (boot interface)
	DB  1          ; bInterfaceProtocol (keyboard)
	DB  0          ; iInterface (n/a)
	DB  7          ; bLength
	DB  5          ; bDescriptorType (ENDPOINT)
	DB  0x81       ; bEndpointAddress (EP1 IN)
	DB  0x03       ; bmAttributes (Interrupt, Data)
	DB  0x08, 0x00 ; wMaxPacketSize (8 bytes)
	DB  1          ; bInterval (1ms)

	; Mouse interface
	DB  9          ; bLength
	DB  4          ; bDescriptorType (INTERFACE)
	DB  1          ; bInterfaceNumber
	DB  0          ; bAlternateSetting
	DB  1          ; bNumEndpoints
	DB  3          ; bInterfaceClass (HID)
	DB  1          ; bInterfaceSubClass (boot interface)
	DB  2          ; bInterfaceProtocol (mouse)
	DB  0          ; iInterface (n/a)
	DB  7          ; bLength
	DB  5          ; bDescriptorType (ENDPOINT)
	DB  0x82       ; bEndpointAddress (EP2 IN)
	DB  0x03       ; bmAttributes (Interrupt, Data)
	DB  0x08, 0x00 ; wMaxPacketSize (8 bytes)
	DB  1          ; bInterval (1ms)
_configuration_descriptor_end:

_str_mfg:
	DB "ranma", 0
_str_product:
	DB "ThinkPad Compact USB Keyboard with TrackPoint (Custom Firmware)", 0

ORG 0x27ff
	DW  0xaaaa          ; canary

ORG _canary_check
	JMP _start

ORG _flasher
	JMP $
