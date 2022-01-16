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
	.Code_Option	Watch_Dog	"Enable"  ; On except for Green/Powerdown modes
//}}SONIX_CODE_OPTION

.DATA
_canary_check EQU 0x2880
_flasher      EQU 0x2890
UTX           EQU P0.6    ; S15
URX           EQU P0.5    ; S10
S0            EQU P2.2
S0M           EQU P2M.2
S1            EQU P2.0
S1M           EQU P2M.0
S2            EQU P4.0
S2M           EQU P4M.0
S3            EQU P4.5
S3M           EQU P4M.5
S4            EQU P4.1
S4M           EQU P4M.1
S5            EQU P2.1
S5M           EQU P2M.1
S6            EQU P4.4
S6M           EQU P4M.4
S7            EQU P4.2
S7M           EQU P4M.2
S8            EQU P4.3
S8M           EQU P4M.3
S9            EQU P2.3
S9M           EQU P2M.3
S10           EQU P0.5
S10M          EQU P0M.5
S11           EQU P0.4
S11M          EQU P0M.4
S12           EQU P4.6
S12M          EQU P4M.6
S13           EQU P4.7
S13M          EQU P4M.7
S14           EQU P0.3
S14M          EQU P0M.3
S15           EQU P0.6
S15M          EQU P0M.6
R0            EQU P1.0
R0M           EQU P1M.0
R1            EQU P1.7
R1M           EQU P1M.7
R2            EQU P1.2
R2M           EQU P1M.2
R3            EQU P1.1
R3M           EQU P1M.1
R4            EQU P1.4
R4M           EQU P1M.4
R5            EQU P1.3
R5M           EQU P1M.3
R6            EQU P1.5
R6M           EQU P1M.5
R7            EQU P1.6
R7M           EQU P1M.6

EP0_BYTES     EQU 8
EP1_BYTES     EQU 8
EP2_BYTES     EQU 8

bmRequestType  DS 1
bRequest       DS 1
wValueLo       DS 1
wValueHi       DS 1
wIndexLo       DS 1
wIndexHi       DS 1
wLengthLo      DS 1
wLengthHi      DS 1

txPtrLo        DS 1
txPtrHi        DS 1
txSizeLo       DS 1
txSizeHi       DS 1
txPktLen       DS 1
txTmpCnt       DS 1

usbState       DS 1
usbStateSetupInvalid EQU usbState.0
usbStateSetAddress   EQU usbState.1
usbStateIn0Done      EQU usbState.3
usbStateZeroPad      EQU usbState.4
usbStateStringCnt    EQU usbState.5
usbStateCopyRAM      EQU usbState.6
usbStateHTDData      EQU usbState.7

usbState2      DS 1
usbStateAddressValid EQU usbState2.0
usbStateEnterFlasher EQU usbState2.1

xlatVal1       DS 1
xlatVal2       DS 1

kbdRow         DS 1
kbdRowsLow     DS 1

bootKeyIdx     DS 1
bootKeyVal     DS 1
keyStateIdx    DS 1
keyStateVal    DS 1

modifierState1 DS 1 ; 224-231
modifierState2 DS 1 ; FN key
bootKeys0      DS 1
bootKeys1      DS 1
bootKeys2      DS 1
bootKeys3      DS 1
bootKeys4      DS 1
bootKeys5      DS 1

keyState0      DS 1 ; 0-7
keyState1      DS 1 ; 8-15
keyState2      DS 1 ; 16-
keyState3      DS 1 ; 24-
keyState4      DS 1 ; 32-
keyState5      DS 1 ; 40-
keyState6      DS 1 ; 48-
keyState7      DS 1 ; 56-
keyState8      DS 1 ; 64-
keyState9      DS 1 ; 72-
keyState10     DS 1 ; 80-
keyState11     DS 1 ; 88-
keyState12     DS 1 ; 96-
keyState13     DS 1 ; 104-
keyState14     DS 1 ; 112-
keyState15     DS 1 ; 120-
keyState16     DS 1 ; 128-
keyState17     DS 1 ; 136-

ramClearEnd    DS 1

keyNONE            EQU keyState0.0
keyErrorRollOver   EQU keyState0.1  ; Too many keys pressed or scan error
keyA               EQU keyState0.4
keyB               EQU keyState0.5
keyC               EQU keyState0.6
keyD               EQU keyState0.7
keyE               EQU keyState1.0  ; 8
keyF               EQU keyState1.1
keyG               EQU keyState1.2
keyH               EQU keyState1.3
keyI               EQU keyState1.4
keyJ               EQU keyState1.5
keyK               EQU keyState1.6
keyL               EQU keyState1.7
keyM               EQU keyState2.0  ; 16
keyN               EQU keyState2.1
keyO               EQU keyState2.2
keyP               EQU keyState2.3
keyQ               EQU keyState2.4
keyR               EQU keyState2.5
keyS               EQU keyState2.6
keyT               EQU keyState2.7
keyU               EQU keyState3.0  ; 24
keyV               EQU keyState3.1
keyW               EQU keyState3.2
keyX               EQU keyState3.3
keyY               EQU keyState3.4
keyZ               EQU keyState3.5
key1               EQU keyState3.6
key2               EQU keyState3.7
key3               EQU keyState4.0  ; 32
key4               EQU keyState4.1
key5               EQU keyState4.2
key6               EQU keyState4.3
key7               EQU keyState4.4
key8               EQU keyState4.5
key9               EQU keyState4.6
key0               EQU keyState4.7
keyRETURN          EQU keyState5.0  ; 40
keyESC             EQU keyState5.1
keyBACKSPACE       EQU keyState5.2
keyTAB             EQU keyState5.3
keySPACE           EQU keyState5.4
keyMINUS           EQU keyState5.5
keyEQUALS          EQU keyState5.6
keyLEFTBRACKET     EQU keyState5.7
keyRIGHTBRACKET    EQU keyState6.0  ; 48
keyBACKSLASH       EQU keyState6.1
keyNONUSHASH       EQU keyState6.2
keySEMICOLON       EQU keyState6.3
keyAPOSTROPHE      EQU keyState6.4
keyGRAVE           EQU keyState6.5
keyCOMMA           EQU keyState6.6
keyPERIOD          EQU keyState6.7
keySLASH           EQU keyState7.0  ; 56
keyCAPSLOCK        EQU keyState7.1
keyF1              EQU keyState7.2
keyF2              EQU keyState7.3
keyF3              EQU keyState7.4
keyF4              EQU keyState7.5
keyF5              EQU keyState7.6
keyF6              EQU keyState7.7
keyF7              EQU keyState8.0  ; 64
keyF8              EQU keyState8.1
keyF9              EQU keyState8.2
keyF10             EQU keyState8.3
keyF11             EQU keyState8.4
keyF12             EQU keyState8.5
keyPRINTSCREEN     EQU keyState8.6
keySCROLLLOCK      EQU keyState8.7
keyPAUSE           EQU keyState9.0  ; 72
keyINSERT          EQU keyState9.1
keyHOME            EQU keyState9.2
keyPAGEUP          EQU keyState9.3
keyDELETE          EQU keyState9.4
keyEND             EQU keyState9.5
keyPAGEDOWN        EQU keyState9.6
keyRIGHT           EQU keyState9.7
keyLEFT            EQU keyState10.0  ; 80
keyDOWN            EQU keyState10.1
keyUP              EQU keyState10.2
keyNUMLOCK         EQU keyState10.3
keyKPDIV           EQU keyState10.4
keyKPMUL           EQU keyState10.5
keyKPMINUS         EQU keyState10.6
keyKPPLUS          EQU keyState10.7
keyKPENTER         EQU keyState11.0  ; 88
keyKP1             EQU keyState11.1
keyKP2             EQU keyState11.2
keyKP3             EQU keyState11.3
keyKP4             EQU keyState11.4
keyKP5             EQU keyState11.5
keyKP6             EQU keyState11.6
keyKP7             EQU keyState11.7
keyKP8             EQU keyState12.0  ; 96
keyKP9             EQU keyState12.1
keyKP0             EQU keyState12.2
keyKPCOLON         EQU keyState12.3
keyNONUSBACKSLASH  EQU keyState12.4
keyAPPLICATION     EQU keyState12.5
keyPOWER           EQU keyState12.6
keyKPEQUALS        EQU keyState12.7  ; 103

keyFIND            EQU keyState15.6  ; 126
keyMUTE            EQU keyState15.7  ; 127
keyVOLUMEUP        EQU keyState16.0  ; 128
keyVOLUMEDOWN      EQU keyState16.1  ; 129

keyINTERNATIONAL1  EQU keyState16.7  ; 135
keyINTERNATIONAL2  EQU keyState17.0
keyINTERNATIONAL3  EQU keyState17.1
keyINTERNATIONAL4  EQU keyState17.2
keyINTERNATIONAL5  EQU keyState17.3
keyINTERNATIONAL6  EQU keyState17.4
keyINTERNATIONAL7  EQU keyState17.5
keyINTERNATIONAL8  EQU keyState17.6
keyINTERNATIONAL9  EQU keyState17.7  ; 143

; keyKPMEMSTORE      EQU 208
; keyKPMEMRECALL     EQU 209
; keyKPMEMCLEAR      EQU 210
; keyKPMEMADD        EQU 211
; keyKPMEMSUBTRACT   EQU 212
; keyKPMEMMULTIPLY   EQU 213
; keyKPMEMDIVIDE     EQU 214

keyLCTRL           EQU modifierState1.0  ; 224
keyLSHIFT          EQU modifierState1.1
keyLALT            EQU modifierState1.2
keyLGUI            EQU modifierState1.3
keyRCTRL           EQU modifierState1.4
keyRSHIFT          EQU modifierState1.5
keyRALT            EQU modifierState1.6
keyRGUI            EQU modifierState1.7  ; 231

keyFN              EQU modifierState2.0
stateFnLock        EQU modifierState2.1
stateFnCtrlSwap    EQU modifierState2.2


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

	; Clear RAM
	B0MOV Y, #0
	B0MOV Z, #ramClearEnd$L
	MOV   A, #0
@@:
	B0MOV @YZ, A
	DECMS Z
	JMP @B
	B0MOV @YZ, A

	B0BSET keyA
	B0BSET keyINTERNATIONAL2
	CALL _kbd_update_boot_keys

	B0MOV A, bootKeys0
	CALL _uart_hex
	B0MOV A, bootKeys1
	CALL _uart_hex
	B0MOV A, bootKeys2
	CALL _uart_hex

	; Setup GPIO
	CALL _gpio_init
	; Setup USB registers
	CALL _usb_init

_mainloop:
	; Tickle watchdog
	MOV A, #0x5a
	B0MOV WDTR, A
@@:
	B0BTS0 FEP0SETUP ; Jump if SETUP packet rx'd
	JMP _usb_setup
	B0BTS0 FEP0OUT
	JMP _usb_ep0_out
	B0BTS0 FEP0IN
	JMP _usb_ep0_in
	B0BTS0 FBUS_RST
	JMP _usb_reset
	B0BTS0 FSOF
	JMP _usb_sof
	B0BTS0 FSUSPEND
	JMP _usb_suspend
	JMP @B

_usb_suspend:
	MOV A, #'P'
	CALL _uart_tx
	MOV A, #'D'
	CALL _uart_tx

	; enter suspend
	B0BCLR 0xa9.4 ; Switch UTX to INPUT
	B0BCLR P5M.3  ; Disable power LED

	; output low on sense lines
	B0BSET S0M
	B0BSET S1M
	B0BSET S2M
	B0BSET S3M
	B0BSET S4M
	B0BSET S5M
	B0BSET S6M
	B0BSET S7M
	B0BSET S8M
	B0BSET S9M
	B0BSET S10M
	B0BSET S11M
	B0BSET S12M
	B0BSET S13M
	B0BSET S14M
	B0BSET S15M

	B0BSET FCPUM0 ; Enter sleep mode
	NOP
	NOP

	; exit suspend
	CALL _gpio_init
	B0BSET 0xa9.4 ; Switch UTX to UART

	; did host wake us?
	B0BTS1 FSUSPEND
	JMP @F

	; key-press wake?
	MOV A, #'!'
	CALL _uart_tx

	; Signal K state to wake host

	; Drive D+ low, D- high (K state)
	MOV A, #0x05
	B0MOV UPID, A
	; FIXME: Wait at least 1ms, no longer than 15ms
	CALL _delayshort
	CALL _delayshort
	CALL _delayshort
	CALL _delayshort
	CALL _delayshort
	CALL _delayshort
	; Revert back to default
	MOV A, #0x00
	B0MOV UPID, A

@@:
	MOV A, #'W'
	CALL _uart_tx
	MOV A, #'U'
	CALL _uart_tx
	JMP _mainloop

_usb_sof:
	B0BCLR FSOF

	; Check for cross-talk from too many depressed keys
	CALL _kbd_count_rows_low
	; Read the columns
	CALL _kbd_sense
	; Release the scanned row
	CALL _kbd_set_row_input
	; Increment row
	INCMS kbdRow
	MOV A, #0x07
	AND kbdRow, A
	; Lower the next row
	CALL _kbd_set_row_output
	; Update boot keys
	CALL _kbd_update_boot_keys

	; Update EP1 buffer
	CALL _kbd_write_ep1

	B0MOV A, bootKeys0
	OR    A, bootKeys1
	B0BTS0 FZ  ; Jump if kbdState is zero
	JMP _mainloop

	MOV A, #' '
	CALL _uart_tx
	MOV A, #'K'
	CALL _uart_tx
	B0MOV A, kbdRow
	CALL _uart_hex
	B0MOV A, bootKeys0
	CALL _uart_hex
	B0MOV A, bootKeys1
	CALL _uart_hex

	JMP _mainloop

_kbd_write_ep1:
	B0BTS0 FUE1M0 ; Skip if zero
	RET
	; FUE1M0 is zero (NAK)
	MOV A, #8   ; EP1 begins at offset 8
	B0MOV UDP0, A

	B0MOV A, modifierState1
	B0MOV UDR0_W, A
	INCMS UDP0
	MOV A, #0   ; reserved byte
	B0MOV UDR0_W, A
	INCMS UDP0
	B0MOV A, bootKeys0
	B0MOV UDR0_W, A
	INCMS UDP0
	B0MOV A, bootKeys1
	B0MOV UDR0_W, A
	INCMS UDP0
	B0MOV A, bootKeys2
	B0MOV UDR0_W, A
	INCMS UDP0
	B0MOV A, bootKeys3
	B0MOV UDR0_W, A
	INCMS UDP0
	B0MOV A, bootKeys4
	B0MOV UDR0_W, A
	INCMS UDP0
	B0MOV A, bootKeys5
	B0MOV UDR0_W, A
	INCMS UDP0

	MOV A, #8  ; EP1 count is 8
	B0MOV UE1R_C, A

	; Set EP1 to ACK
	B0BSET FUE1M0

	MOV A, #','
	CALL _uart_tx
	RET

_usb_reset:
	MOV A, #13
	CALL _uart_tx
	MOV A, #10
	CALL _uart_tx
	MOV A, #'R'
	CALL _uart_tx
	CALL _usb_init
	; Wait until reset is de-asserted
_usb_reset_wait:
	B0BTS0 FBUS_RST
	JMP _usb_reset_wait
	JMP _mainloop

_gpio_init:
	; Enable all pull-ups
	MOV A, #0xff
	B0MOV P0UR, A
	B0MOV P1UR, A
	B0MOV P2UR, A
	B0MOV P4UR, A
	B0MOV P5UR, A
	; Enable P1 wakeup
	B0MOV P1W, A
	; Switch all to input
	MOV A, #0x00
	B0MOV P0M, A
	B0MOV P1M, A
	B0MOV P2M, A
	B0MOV P4M, A
	B0MOV P5M, A
	; Set port output data to 0
	B0MOV P0, A
	B0MOV P1, A
	B0MOV P2, A
	B0MOV P4, A
	B0MOV P5, A
	; Reset kbd scan state
	B0MOV kbdRow, A
	; Re-light LED
	B0BCLR P5.3   ; Set to low level to light up
	B0BSET P5M.3  ; Set to output
	;; Set UTX/URX to open-drain
	;MOV A, #0x0c
	;B0MOV P1OC, A
	RET

_usb_init:
	MOV A, #0
	B0MOV usbState, A
	B0MOV usbState2, A
	B0MOV USTATUS, A
	MOV A, #0x80
	B0MOV UDA, A  ; Set address to 0 and enable
	B0MOV UE1R, A ; Enable EP1, set to NAK
	B0MOV UE2R, A ; Enable EP2, set to NAK
	B0BSET FDP_PU_EN ; Enable D+ pull-up
	B0BSET FSOF_INT_EN ; Enable SOF interrupt request
	RET

_kbd_update_boot_keys:
	; Update boot interface key bytes
	B0BTS0 keyErrorRollOver  ; Jump if rollover error
	JMP _kbd_update_boot_keys_rollover

	MOV A, #0
	B0MOV bootKeys0, A
	B0MOV bootKeys1, A
	B0MOV bootKeys2, A
	B0MOV bootKeys3, A
	B0MOV bootKeys4, A
	B0MOV bootKeys5, A
	B0MOV bootKeyVal, A
	B0MOV Y, A

	MOV A, #bootKeys0$L
	B0MOV bootKeyIdx, A
	MOV A, #keyState0$L
	B0MOV keyStateIdx, A

_kbd_update_boot_keys_loop:
	B0MOV A, keyStateIdx
	MOV   Z, A
	B0MOV A, @YZ
	B0BTS0 FZ  ; Jump if zero
	JMP _kbd_update_boot_keys_nextbyte

	B0MOV keyStateVal, A
	B0MOV R, #0x8

@@:
	RRCM keyStateVal
	B0BTS1 FC  ; Jump if not carry set
	JMP _kbd_update_boot_keys_nextbit

	; Write the boot key value
	B0MOV A, bootKeyIdx
	MOV   Z, A

	; Check if we still have space
	SUB   A, #1
	SUB   A, #bootKeys5$L
	B0BTS0 FC  ; Jump if carry set
	JMP _kbd_update_boot_keys_rollover

	; Write the value
	B0MOV A, bootKeyVal
	B0MOV @YZ, A

	; Update pointer
	INCMS bootKeyIdx

_kbd_update_boot_keys_nextbit:
	INCMS bootKeyVal
	DECMS R
	JMP @B
	JMP @F

_kbd_update_boot_keys_nextbyte:
	MOV A, #8
	ADD bootKeyVal, A
@@:
	INCMS keyStateIdx
	; Check if we the idx has reached the bitfield end
	MOV A, keyStateIdx
	SUB A, #1
	SUB A, #keyState17
	B0BTS1 FC  ; Jump if not carry set
	JMP _kbd_update_boot_keys_loop

	; normal exit
	RET

_kbd_update_boot_keys_rollover:
	MOV A, #1
	B0MOV bootKeys0, A
	B0MOV bootKeys1, A
	B0MOV bootKeys2, A
	B0MOV bootKeys3, A
	B0MOV bootKeys4, A
	B0MOV bootKeys5, A
	RET

_kbd_sense:
	B0MOV A, kbdRow
	AND A, #0x7
.ALIGN 16
	B0ADD PCL, A
	JMP _kbd_sense_row0
	JMP _kbd_sense_row1
	JMP _kbd_sense_row2
	JMP _kbd_sense_row3
	JMP _kbd_sense_row4
	JMP _kbd_sense_row5
	JMP _kbd_sense_row6
	JMP _kbd_sense_row7

_kbd_sense_row0:
	; DB keyESC, keyF4, keyNONUSBACKSLASH, keyNONE, keyG, keyH, keyF6, keyINTERNATIONAL4
	B0BTS0 S0
	B0BCLR keyESC
	B0BTS1 S0
	B0BSET keyESC
	B0BTS0 S1
	B0BCLR keyF4
	B0BTS1 S1
	B0BSET keyF4
	B0BTS0 S2
	B0BCLR keyNONUSBACKSLASH
	B0BTS1 S2
	B0BSET keyNONUSBACKSLASH
	B0BTS0 S3
	B0BCLR keyNONE
	B0BTS1 S3
	B0BSET keyNONE
	B0BTS0 S4
	B0BCLR keyG
	B0BTS1 S4
	B0BSET keyG
	B0BTS0 S5
	B0BCLR keyH
	B0BTS1 S5
	B0BSET keyH
	B0BTS0 S6
	B0BCLR keyF6
	B0BTS1 S6
	B0BSET keyF6
	B0BTS0 S7
	B0BCLR keyINTERNATIONAL4
	B0BTS1 S7
	B0BSET keyINTERNATIONAL4

	; DB keyAPOSTROPHE, keyNONE, keyF5, keyNONE, keyLALT, keyNONE, keyUP, keyNONE
	B0BTS0 S8
	B0BCLR keyAPOSTROPHE
	B0BTS1 S8
	B0BSET keyAPOSTROPHE
	B0BTS0 S9
	B0BCLR keyNONE
	B0BTS1 S9
	B0BSET keyNONE
	B0BTS0 S10
	B0BCLR keyF5
	B0BTS1 S10
	B0BSET keyF5
	B0BTS0 S11
	B0BCLR keyNONE
	B0BTS1 S11
	B0BSET keyNONE
	B0BTS0 S12
	B0BCLR keyLALT
	B0BTS1 S12
	B0BSET keyLALT
	B0BTS0 S13
	B0BCLR keyNONE
	B0BTS1 S13
	B0BSET keyNONE
	B0BTS0 S14
	B0BCLR keyUP
	B0BTS1 S14
	B0BSET keyUP
	B0BTS0 S15
	B0BCLR keyNONE
	B0BTS1 S15
	B0BSET keyNONE
	RET

_key_f3_clear:
	B0BCLR keyF3
	B0BCLR keyVOLUMEUP
	RET
_key_f3_set:
	B0BTS0 keyFN
	JMP @F
	B0BSET keyF3
	RET
@@:
	B0BSET keyVOLUMEUP
	RET

_kbd_sense_row1:
	; DB keyTAB, keyF3, keyCAPSLOCK, keyNONE, keyT, keyY, keyRIGHTBRACKET, keyF7
	B0BTS0 S0
	B0BCLR keyTAB
	B0BTS1 S0
	B0BSET keyTAB
	B0BTS0 S1
	CALL _key_f3_clear
	B0BTS1 S1
	CALL _key_f3_set
	B0BTS0 S2
	B0BCLR keyCAPSLOCK
	B0BTS1 S2
	B0BSET keyCAPSLOCK
	B0BTS0 S3
	B0BCLR keyNONE
	B0BTS1 S3
	B0BSET keyNONE
	B0BTS0 S4
	B0BCLR keyT
	B0BTS1 S4
	B0BSET keyT
	B0BTS0 S5
	B0BCLR keyY
	B0BTS1 S5
	B0BSET keyY
	B0BTS0 S6
	B0BCLR keyRIGHTBRACKET
	B0BTS1 S6
	B0BSET keyRIGHTBRACKET
	B0BTS0 S7
	B0BCLR keyF7
	B0BTS1 S7
	B0BSET keyF7

	; DB keyLEFTBRACKET, keyLSHIFT, keyBACKSPACE, keyNONE, keyNONE, keyLGUI, keyKPMEMSTORE, keyNONE
	B0BTS0 S8
	B0BCLR keyLEFTBRACKET
	B0BTS1 S8
	B0BSET keyLEFTBRACKET
	B0BTS0 S9
	B0BCLR keyLSHIFT
	B0BTS1 S9
	B0BSET keyLSHIFT
	B0BTS0 S10
	B0BCLR keyBACKSPACE
	B0BTS1 S10
	B0BSET keyBACKSPACE
	B0BTS0 S11
	B0BCLR keyNONE
	B0BTS1 S11
	B0BSET keyNONE
	B0BTS0 S12
	B0BCLR keyNONE
	B0BTS1 S12
	B0BSET keyNONE
	B0BTS0 S13
	B0BCLR keyLGUI
	B0BTS1 S13
	B0BSET keyLGUI
	B0BTS0 S14
	B0BCLR keyNONE
	B0BTS1 S14
	B0BSET keyNONE
	B0BTS0 S15
	B0BCLR keyNONE
	B0BTS1 S15
	B0BSET keyNONE
	RET

_kbd_sense_row2:
	; DB keyQ, keyE, keyW, keyNONE, keyR, keyU, keyI, keyO
	B0BTS0 S0
	B0BCLR keyQ
	B0BTS1 S0
	B0BSET keyQ
	B0BTS0 S1
	B0BCLR keyE
	B0BTS1 S1
	B0BSET keyE
	B0BTS0 S2
	B0BCLR keyW
	B0BTS1 S2
	B0BSET keyW
	B0BTS0 S3
	B0BCLR keyNONE
	B0BTS1 S3
	B0BSET keyNONE
	B0BTS0 S4
	B0BCLR keyR
	B0BTS1 S4
	B0BSET keyR
	B0BTS0 S5
	B0BCLR keyU
	B0BTS1 S5
	B0BSET keyU
	B0BTS0 S6
	B0BCLR keyI
	B0BTS1 S6
	B0BSET keyI
	B0BTS0 S7
	B0BCLR keyO
	B0BTS1 S7
	B0BSET keyO

	; DB keyP, keyNONE, keyINTERNATIONAL3, keyNONE, keyNONE, keyKPMEMCLEAR, keyNONE, keyNONE
	B0BTS0 S8
	B0BCLR keyP
	B0BTS1 S8
	B0BSET keyP
	B0BTS0 S9
	B0BCLR keyNONE
	B0BTS1 S9
	B0BSET keyNONE
	B0BTS0 S10
	B0BCLR keyINTERNATIONAL3
	B0BTS1 S10
	B0BSET keyINTERNATIONAL3
	B0BTS0 S11
	B0BCLR keyNONE
	B0BTS1 S11
	B0BSET keyNONE
	B0BTS0 S12
	B0BCLR keyNONE
	B0BTS1 S12
	B0BSET keyNONE
	B0BTS0 S13
	B0BCLR keyNONE
	B0BTS1 S13
	B0BSET keyNONE
	B0BTS0 S14
	B0BCLR keyNONE
	B0BTS1 S14
	B0BSET keyNONE
	B0BTS0 S15
	B0BCLR keyNONE
	B0BTS1 S15
	B0BSET keyNONE
	RET

_key_f1_clear:
	B0BCLR keyF1
	B0BCLR keyMUTE
	RET
_key_f1_set:
	B0BTS0 keyFN
	JMP @F
	B0BSET keyF1
	RET
@@:
	B0BSET keyMUTE
	RET

_key_f2_clear:
	B0BCLR keyF2
	B0BCLR keyVOLUMEDOWN
	RET
_key_f2_set:
	B0BTS0 keyFN
	JMP @F
	B0BSET keyF2
	RET
@@:
	B0BSET keyVOLUMEDOWN
	RET

_kbd_sense_row3:
	; DB keyGRAVE, keyF2, keyF1, keyLCTRL, key5, key6, keyEQUALS, keyF8
	B0BTS0 S0
	B0BCLR keyGRAVE
	B0BTS1 S0
	B0BSET keyGRAVE
	B0BTS0 S1
	CALL _key_f2_clear
	B0BTS1 S1
	CALL _key_f2_set
	B0BTS0 S2
	CALL _key_f1_clear
	B0BTS1 S2
	CALL _key_f1_set
	B0BTS0 S3
	B0BCLR keyLCTRL
	B0BTS1 S3
	B0BSET keyLCTRL
	B0BTS0 S4
	B0BCLR key5
	B0BTS1 S4
	B0BSET key5
	B0BTS0 S5
	B0BCLR key6
	B0BTS1 S5
	B0BSET key6
	B0BTS0 S6
	B0BCLR keyEQUALS
	B0BTS1 S6
	B0BSET keyEQUALS
	B0BTS0 S7
	B0BCLR keyF8
	B0BTS1 S7
	B0BSET keyF8

	; DB keyMINUS, keyNONE, keyF9, keyHOME, keyKPMEMSUBTRACT, keyNONE, keyNONE, keyDELETE
	B0BTS0 S8
	B0BCLR keyMINUS
	B0BTS1 S8
	B0BSET keyMINUS
	B0BTS0 S9
	B0BCLR keyNONE
	B0BTS1 S9
	B0BSET keyNONE
	B0BTS0 S10
	B0BCLR keyF9
	B0BTS1 S10
	B0BSET keyF9
	B0BTS0 S11
	B0BCLR keyHOME
	B0BTS1 S11
	B0BSET keyHOME
	B0BTS0 S12
	B0BCLR keyNONE
	B0BTS1 S12
	B0BSET keyNONE
	B0BTS0 S13
	B0BCLR keyNONE
	B0BTS1 S13
	B0BSET keyNONE
	B0BTS0 S14
	B0BCLR keyNONE
	B0BTS1 S14
	B0BSET keyNONE
	B0BTS0 S15
	B0BCLR keyDELETE
	B0BTS1 S15
	B0BSET keyDELETE
	RET

_kbd_sense_row4:
	; DB keyA, keyD, keyS, keyNONE, keyF, keyJ, keyK, keyL
	B0BTS0 S0
	B0BCLR keyA
	B0BTS1 S0
	B0BSET keyA
	B0BTS0 S1
	B0BCLR keyD
	B0BTS1 S1
	B0BSET keyD
	B0BTS0 S2
	B0BCLR keyS
	B0BTS1 S2
	B0BSET keyS
	B0BTS0 S3
	B0BCLR keyNONE
	B0BTS1 S3
	B0BSET keyNONE
	B0BTS0 S4
	B0BCLR keyF
	B0BTS1 S4
	B0BSET keyF
	B0BTS0 S5
	B0BCLR keyJ
	B0BTS1 S5
	B0BSET keyJ
	B0BTS0 S6
	B0BCLR keyK
	B0BTS1 S6
	B0BSET keyK
	B0BTS0 S7
	B0BCLR keyL
	B0BTS1 S7
	B0BSET keyL

	; DB keySEMICOLON, keyNONE, keyBACKSLASH, keyNONE, keyNONE, keyNONE, keyFN, keyPRINTSCREEN
	B0BTS0 S8
	B0BCLR keySEMICOLON
	B0BTS1 S8
	B0BSET keySEMICOLON
	B0BTS0 S9
	B0BCLR keyNONE
	B0BTS1 S9
	B0BSET keyNONE
	B0BTS0 S10
	B0BCLR keyBACKSLASH
	B0BTS1 S10
	B0BSET keyBACKSLASH
	B0BTS0 S11
	B0BCLR keyNONE
	B0BTS1 S11
	B0BSET keyNONE
	B0BTS0 S12
	B0BCLR keyNONE
	B0BTS1 S12
	B0BSET keyNONE
	B0BTS0 S13
	B0BCLR keyNONE
	B0BTS1 S13
	B0BSET keyNONE
	B0BTS0 S14
	B0BCLR keyFN
	B0BTS1 S14
	B0BSET keyFN
	B0BTS0 S15
	B0BCLR keyPRINTSCREEN
	B0BTS1 S15
	B0BSET keyPRINTSCREEN
	RET

_kbd_sense_row5:
	; DB key1, key3, key2, keyNONE, key4, key7, key8, key9
	B0BTS0 S0
	B0BCLR key1
	B0BTS1 S0
	B0BSET key1
	B0BTS0 S1
	B0BCLR key3
	B0BTS1 S1
	B0BSET key3
	B0BTS0 S2
	B0BCLR key2
	B0BTS1 S2
	B0BSET key2
	B0BTS0 S3
	B0BCLR keyNONE
	B0BTS1 S3
	B0BSET keyNONE
	B0BTS0 S4
	B0BCLR key4
	B0BTS1 S4
	B0BSET key4
	B0BTS0 S5
	B0BCLR key7
	B0BTS1 S5
	B0BSET key7
	B0BTS0 S6
	B0BCLR key8
	B0BTS1 S6
	B0BSET key8
	B0BTS0 S7
	B0BCLR key9
	B0BTS1 S7
	B0BSET key9

	; DB key0, keyNONE, keyF10, keyF11, keyNONE, keyF12, keyEND, keyINSERT
	B0BTS0 S8
	B0BCLR key0
	B0BTS1 S8
	B0BSET key0
	B0BTS0 S9
	B0BCLR keyNONE
	B0BTS1 S9
	B0BSET keyNONE
	B0BTS0 S10
	B0BCLR keyF10
	B0BTS1 S10
	B0BSET keyF10
	B0BTS0 S11
	B0BCLR keyF11
	B0BTS1 S11
	B0BSET keyF11
	B0BTS0 S12
	B0BCLR keyNONE
	B0BTS1 S12
	B0BSET keyNONE
	B0BTS0 S13
	B0BCLR keyF12
	B0BTS1 S13
	B0BSET keyF12
	B0BTS0 S14
	B0BCLR keyEND
	B0BTS1 S14
	B0BSET keyEND
	B0BTS0 S15
	B0BCLR keyINSERT
	B0BTS1 S15
	B0BSET keyINSERT
	RET

_kbd_sense_row6:
	; DB keyZ, keyC, keyX, keyRCTRL, keyV, keyM, keyCOMMA, keyPERIOD
	B0BTS0 S0
	B0BCLR keyZ
	B0BTS1 S0
	B0BSET keyZ
	B0BTS0 S1
	B0BCLR keyC
	B0BTS1 S1
	B0BSET keyC
	B0BTS0 S2
	B0BCLR keyX
	B0BTS1 S2
	B0BSET keyX
	B0BTS0 S3
	B0BCLR keyRCTRL
	B0BTS1 S3
	B0BSET keyRCTRL
	B0BTS0 S4
	B0BCLR keyV
	B0BTS1 S4
	B0BSET keyV
	B0BTS0 S5
	B0BCLR keyM
	B0BTS1 S5
	B0BSET keyM
	B0BTS0 S6
	B0BCLR keyCOMMA
	B0BTS1 S6
	B0BSET keyCOMMA
	B0BTS0 S7
	B0BCLR keyPERIOD
	B0BTS1 S7
	B0BSET keyPERIOD

	; DB keyNONUSHASH, keyRSHIFT, keyRETURN, keyNONE, keyNONE, keyNONE, keyPAUSE, keyPAGEUP
	B0BTS0 S8
	B0BCLR keyNONUSHASH
	B0BTS1 S8
	B0BSET keyNONUSHASH
	B0BTS0 S9
	B0BCLR keyRSHIFT
	B0BTS1 S9
	B0BSET keyRSHIFT
	B0BTS0 S10
	B0BCLR keyRETURN
	B0BTS1 S10
	B0BSET keyRETURN
	B0BTS0 S11
	B0BCLR keyNONE
	B0BTS1 S11
	B0BSET keyNONE
	B0BTS0 S12
	B0BCLR keyNONE
	B0BTS1 S12
	B0BSET keyNONE
	B0BTS0 S13
	B0BCLR keyNONE
	B0BTS1 S13
	B0BSET keyNONE
	B0BTS0 S14
	B0BCLR keyPAUSE
	B0BTS1 S14
	B0BSET keyPAUSE
	B0BTS0 S15
	B0BCLR keyPAGEUP
	B0BTS1 S15
	B0BSET keyPAGEUP
	RET

_kbd_sense_row7:
	; DB keyINTERNATIONAL5, keyNONE, keyNONE, keyNONE, keyB, keyN, keyINTERNATIONAL1, keyINTERNATIONAL2
	B0BTS0 S0
	B0BCLR keyINTERNATIONAL5
	B0BTS1 S0
	B0BSET keyINTERNATIONAL5
	B0BTS0 S1
	B0BCLR keyNONE
	B0BTS1 S1
	B0BSET keyNONE
	B0BTS0 S2
	B0BCLR keyNONE
	B0BTS1 S2
	B0BSET keyNONE
	B0BTS0 S3
	B0BCLR keyNONE
	B0BTS1 S3
	B0BSET keyNONE
	B0BTS0 S4
	B0BCLR keyB
	B0BTS1 S4
	B0BSET keyB
	B0BTS0 S5
	B0BCLR keyN
	B0BTS1 S5
	B0BSET keyN
	B0BTS0 S6
	B0BCLR keyINTERNATIONAL1
	B0BTS1 S6
	B0BSET keyINTERNATIONAL1
	B0BTS0 S7
	B0BCLR keyINTERNATIONAL2
	B0BTS1 S7
	B0BSET keyINTERNATIONAL2

	; DB keySLASH, keyNONE, keySPACE, keyDOWN, keyRALT, keyRIGHT, keyLEFT, keyPAGEDOWN
	B0BTS0 S8
	B0BCLR keySLASH
	B0BTS1 S8
	B0BSET keySLASH
	B0BTS0 S9
	B0BCLR keyNONE
	B0BTS1 S9
	B0BSET keyNONE
	B0BTS0 S10
	B0BCLR keySPACE
	B0BTS1 S10
	B0BSET keySPACE
	B0BTS0 S11
	B0BCLR keyDOWN
	B0BTS1 S11
	B0BSET keyDOWN
	B0BTS0 S12
	B0BCLR keyRALT
	B0BTS1 S12
	B0BSET keyRALT
	B0BTS0 S13
	B0BCLR keyRIGHT
	B0BTS1 S13
	B0BSET keyRIGHT
	B0BTS0 S14
	B0BCLR keyLEFT
	B0BTS1 S14
	B0BSET keyLEFT
	B0BTS0 S15
	B0BCLR keyPAGEDOWN
	B0BTS1 S15
	B0BSET keyPAGEDOWN
	RET

_kbd_set_row_output:
	B0MOV A, kbdRow
	ADD   A, kbdRow
	AND   A, #0xf
.ALIGN 16
	B0ADD PCL, A
	B0BSET R0M
	RET
	B0BSET R1M
	RET
	B0BSET R2M
	RET
	B0BSET R3M
	RET
	B0BSET R4M
	RET
	B0BSET R5M
	RET
	B0BSET R6M
	RET
	B0BSET R7M
	RET

_kbd_set_row_input:
	B0MOV A, kbdRow
	ADD   A, kbdRow
	AND   A, #0xf
.ALIGN 16
	B0ADD PCL, A
	B0BCLR R0M
	RET
	B0BCLR R1M
	RET
	B0BCLR R2M
	RET
	B0BCLR R3M
	RET
	B0BCLR R4M
	RET
	B0BCLR R5M
	RET
	B0BCLR R6M
	RET
	B0BCLR R7M
	RET

_kbd_count_rows_low:
	MOV A, #0
	B0MOV kbdRowsLow, A
	B0BTS1 R0
	INCMS kbdRowsLow
	B0BTS1 R1
	INCMS kbdRowsLow
	B0BTS1 R2
	INCMS kbdRowsLow
	B0BTS1 R3
	INCMS kbdRowsLow
	B0BTS1 R4
	INCMS kbdRowsLow
	B0BTS1 R5
	INCMS kbdRowsLow
	B0BTS1 R6
	INCMS kbdRowsLow
	B0BTS1 R7
	INCMS kbdRowsLow
	NOP
	RET

_usb_ep0_in:
	B0BCLR FEP0IN ; Early ack of IN irq, we can't get a new one until EP0 NAK state is cleared
	MOV A, #'i'
	CALL _uart_tx
	CALL _usb_write_ep0
	B0BTS0 usbStateSetAddress
	JMP _usb_ep0_set_addr
	JMP _mainloop

_usb_ep0_set_addr:
	B0BSET wValueLo.7
	B0MOV A, wValueLo
	B0MOV UDA, A ; Update address register
	MOV A, #'A'
	CALL _uart_tx
	B0MOV A, wValueLo
	CALL _uart_hex
	JMP _mainloop

_usb_ep0_out:
	B0BCLR FEP0OUT ; Ack OUT irq

	MOV A, #'o'
	CALL _uart_tx

	B0MOV A, EP0OUT_CNT
	B0BTS1 FZ ; Call if non-zero
	CALL _uart_hex

	B0BTS0 usbStateHTDData
	JMP _usb_setup_htd_got_data
	JMP _mainloop

_setup_dispatch_table:
	DW 0x0001  ; CLEAR_FEATURE (device)
	JMP _usb_htd_clear_feature
	DW 0x0003  ; SET_FEATURE (device)
	JMP _usb_htd_set_feature
	DW 0x0005  ; SET_ADDRESS
	JMP _usb_htd_set_address
	DW 0x0009  ; SET_CONFIGURATION
	JMP _usb_htd_set_configuration
	DW 0x2109  ; HID SET_REPORT
	JMP _usb_htd_hid_set_report
	DW 0x210a  ; HID SET_IDLE
	JMP _usb_htd_hid_set_idle
	DW 0x210b  ; HID SET_PROTOCOL
	JMP _usb_setup_default
	DW 0x8000  ; GET_STATUS
	JMP _usb_dth_get_status
	DW 0x8006  ; GET_DESCRIPTOR (device)
	JMP _usb_dth_get_device_descriptor
	DW 0x8008  ; GET_CONFIGURATION (device)
	JMP _usb_dth_get_device_configuration
	DW 0x8106  ; GET_DESCRIPTOR (interface)
	JMP _usb_dth_get_interface_descriptor
	DW 0x810a  ; GET_INTERFACE (interface)
	JMP _usb_dth_get_interface
	DW 0xa101  ; HID GET_REPORT
	JMP _usb_dth_hid_get_report
	DW 0xa102  ; HID GET_IDLE
	JMP _usb_setup_default
	DW 0xa103  ; HID GET_PROTOCOL
	JMP _usb_setup_default
	DW 0xFFFF
	JMP _usb_setup_default

_usb_setup_default:
	B0BSET usbStateSetupInvalid
	MOV A, #'?'
	CALL _uart_tx
	B0MOV A, bmRequestType
	CALL _uart_hex
	B0MOV A, bRequest
	CALL _uart_hex
	RET

_usb_dth_get_device_descriptor:
	B0MOV A, wValueHi
	ADD A, #0xfc
	B0BTS0 FC
	JMP _usb_get_desc_badidx
	B0MOV A, wValueHi
.ALIGN 8
	B0ADD PCL, A
	JMP _usb_get_desc_badidx
	JMP _usb_get_desc_device
	JMP _usb_get_desc_config
	JMP _usb_get_desc_string

_usb_dth_get_interface_descriptor:
	B0MOV A, wValueHi
	SUB A, #0x20
	ADD A, #0xfc
	B0BTS0 FC
	JMP _usb_get_desc_badidx
	B0MOV A, wValueHi
	SUB A, #0x20
.ALIGN 8
	B0ADD PCL, A
	JMP _usb_get_desc_badidx
	JMP _usb_get_desc_hid
	JMP _usb_get_desc_report
	JMP _usb_get_desc_physical

_usb_get_desc_badidx:
	MOV A, #'d'
	CALL _uart_tx
	B0MOV A, wValueHi
	CALL _uart_hex
	B0MOV A, wValueLo
	CALL _uart_hex
	B0BSET usbStateSetupInvalid
	RET

_device_descriptor:
	DB  0x12       ; bLength
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
	DB  1          ; bNumConfigurations (1)
_device_descriptor_end:

_configuration_descriptor:
	DB  9          ; bLength
	DB  2          ; bDescriptorType (CONFIGURATION)
	DB  0x32, 0x00 ; wTotalLength
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

	DB  9          ; bLength
	DB  0x21       ; bDescriptorType (HID)
	DB  0x00, 0x01 ; bcdHID (1.00)
	DB  0          ; bCountryCode (Not Supported)
	DB  1          ; bNumDescriptors
	DB  0x22       ; bDescriptorType (Report)
	DB  63, 0      ; wDescriptorLength (63)

	DB  7          ; bLength
	DB  5          ; bDescriptorType (ENDPOINT)
	DB  0x81       ; bEndpointAddress (EP1 IN)
	DB  0x03       ; bmAttributes (Interrupt, Data)
	DB  0x3f, 0x00 ; wMaxPacketSize (63 bytes)
	DB  10         ; bInterval (10ms)

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

	; FIXME: Add Mouse HID descriptor once Keyboard is working.

	DB  7          ; bLength
	DB  5          ; bDescriptorType (ENDPOINT)
	DB  0x82       ; bEndpointAddress (EP2 IN)
	DB  0x03       ; bmAttributes (Interrupt, Data)
	DB  0x3f, 0x00 ; wMaxPacketSize (63 bytes)
	DB  10         ; bInterval (10ms)
_configuration_descriptor_end:

_string_langids:
	DB 4, 3, 9, 4
_string_mfg:
	DB 14, 3
	DW "Lenovo"
_string_product:
	DB 92, 3
	DW "ThinkPad Compact USB Keyboard with TrackPoint"

_usb_status_ok:
	DW 0

_usb_configuration:
	DB 1

_kbd_hid_descriptor:
	DB 9           ; bLength
	DB 0x21        ; bDescriptorType (HID)
	DB 0x00, 0x01  ; bcdHID (1.00)
	DB 0           ; bCountryCode (Not Supported)
	DB 1           ; bNumDescriptors
	DB 0x22        ; bDescriptorType (Report)
	DB 63, 0       ; wDescriptorLength (63)
_kbd_hid_descriptor_end:

_kbd_report_descriptor:
	; Boot-compatible descriptor
	DB 0x05, 1     ; Usage Page (Generic Desktop)
	DB 0x09, 6     ; Usage (Keyboard)
	DB 0xa1, 1     ; Collection (Application)

	; Modifier keys
	DB 0x05, 7     ;   Usage Page (Key Codes)
	DB 0x19, 224   ;   Usage Minimum (224)
	DB 0x29, 231   ;   Usage Maximum (231)
	DB 0x15, 0     ;   Logical Minimum (0)
	DB 0x25, 1     ;   Logical Minimum (1)
	DB 0x75, 1     ;   Report Size (1)
	DB 0x95, 8     ;   Report Count (8)
	DB 0x81, 2     ;   Input (Data, Variable, Absolute)

	; Reserved byte
	DB 0x95, 1     ;   Report Count (1)
	DB 0x75, 8     ;   Report Size (8)
	DB 0x81, 1     ;   Input (Constant, Absolute)

	; LED byte (5 bits + 3 bits padding)
	DB 0x95, 5     ;   Report Count (5)
	DB 0x75, 1     ;   Report Size (1)
	DB 0x05, 8     ;   Usage Page (LEDs)
	DB 0x19, 1     ;   Usage Minimum (1)
	DB 0x29, 5     ;   Usage Maximum (5)
	DB 0x91, 2     ;   Output (Data, Variable, Absolute)
	DB 0x95, 1     ;   Report Count (1)
	DB 0x75, 3     ;   Report Size (3)
	DB 0x91, 1     ;   Output (Data, Variable, Absolute)

	; 6 key code bytes
	DB 0x95, 6     ;   Report Count (6)
	DB 0x75, 8     ;   Report Size (8)
	DB 0x15, 0     ;   Logical Minimum (0)
	DB 0x25, 175   ;   Logical Maximum (175)
	DB 0x05, 7     ;   Usage Page (Key Codes)
	DB 0x19, 0     ;   Usage Minimum (0)
	DB 0x29, 175   ;   Usage Maximum (175)
	DB 0x81, 0     ;   Input (Data, Array)

	DB 0xc0        ; End Collection (Application)
_kbd_report_descriptor_end:

_clamp_size:
	B0MOV A, wLengthLo
	SUB   A, txSizeLo
	B0MOV A, wLengthHi
	SBC   A, txSizeHi
	B0BTS0 FC ; Return if carry set
	RET
	B0MOV A, wLengthLo
	B0MOV txSizeLo, A
	B0MOV A, wLengthHi
	B0MOV txSizeHi, A
	RET

_usb_get_desc_device:
	MOV A, #'D'
	CALL _uart_tx
	MOV A, #_device_descriptor$M
	B0MOV txPtrHi, A
	MOV A, #_device_descriptor$L
	B0MOV txPtrLo, A
	MOV   A, #0x12
	B0MOV txSizeLo, A
_usb_get_desc:
	CALL _clamp_size
	CALL _usb_write_ep0
	RET

_usb_get_desc_config:
	MOV A, #'C'
	CALL _uart_tx
	MOV A, #_configuration_descriptor$M
	B0MOV txPtrHi, A
	MOV A, #_configuration_descriptor$L
	B0MOV txPtrLo, A
	MOV   A, #0x32
	B0MOV txSizeLo, A
	JMP _usb_get_desc

_usb_get_desc_string:
	B0MOV A, wValueLo
	ADD A, #0xfd
	B0BTS0 FC
	JMP _usb_get_desc_badidx
	B0MOV A, wValueLo
.ALIGN 8
	B0ADD PCL, A
	JMP _usb_get_string_langids
	JMP _usb_get_string_mfg
	JMP _usb_get_string_product

_usb_get_string_langids:
	MOV A, #_string_langids$M
	B0MOV txPtrHi, A
	MOV A, #_string_langids$L
	B0MOV txPtrLo, A
	MOV   A, #4
	B0MOV txSizeLo, A
	JMP _usb_get_desc

_usb_get_string_mfg:
	MOV A, #_string_mfg$M
	B0MOV txPtrHi, A
	MOV A, #_string_mfg$L
	B0MOV txPtrLo, A
	MOV   A, #14
	B0MOV txSizeLo, A
	JMP _usb_get_desc

_usb_get_string_product:
	MOV A, #_string_product$M
	B0MOV txPtrHi, A
	MOV A, #_string_product$L
	B0MOV txPtrLo, A
	MOV   A, #92
	B0MOV txSizeLo, A
	JMP _usb_get_desc

_usb_get_desc_hid:
_usb_get_desc_report:
_usb_get_desc_physical:
	MOV A, #_kbd_report_descriptor$M
	B0MOV txPtrHi, A
	MOV A, #_kbd_report_descriptor$L
	B0MOV txPtrLo, A
	MOV   A, #63
	B0MOV txSizeLo, A
	JMP _usb_get_desc

_usb_write_ep0:
	MOV A, #'W'
	CALL _uart_tx

	; Check if this is a 0byte-write and bail out early
	B0MOV A, txSizeLo
	OR    A, txSizeHi
	B0BTS0 FZ ; Jump if zero
	JMP _write_empty_to_ep0

	; Clamp packet byte count to EP0 size
	B0MOV A, txSizeHi
	B0BTS1 FZ ; Jump if not zero
	JMP _write_to_ep0_big
	MOV A, txSizeLo
	B0MOV R, A
	MOV A, #EP0_BYTES
	SUB A, txSizeLo
	B0BTS1 FC ; Skip if carry
_write_to_ep0_big:
	B0MOV R, #EP0_BYTES

_write_to_ep0_copy:
	; Save packet size fo updating UE0R later
	MOV A, R
	B0MOV txPktLen, A
	B0MOV txTmpCnt, A

	; Copy data into EP0 xmit buffer
	MOV A, #0
	B0MOV UDP0, A
_write_to_ep0_copy_loop:
	B0MOV A, txPtrHi
	B0MOV Y, A
	B0MOV A, txPtrLo
	B0MOV Z, A
	MOVC
	B0MOV UDR0_W, A
	INCMS UDP0
	B0MOV A, R
	B0MOV UDR0_W, A
	INCMS UDP0
	INCMS txPtrLo
	JMP @F
	INCMS txPtrHi
@@:
	DECMS txTmpCnt
	JMP @F
	JMP _write_to_ep0_update_len
@@:
	DECMS txTmpCnt
	JMP _write_to_ep0_copy_loop

_write_to_ep0_update_len:
	B0MOV A, txPktLen
	XCH A, txSizeLo
	SUB txSizeLo, A  ; M = A - M
	MOV A, #0
	XCH A, txSizeHi
	SBC txSizeHi, A  ; M = A - M - /C

	B0MOV A, txPktLen
	OR A, #0x20  ; Set to ACK for
	B0MOV UE0R, A

	B0MOV A, txPktLen
	CALL _uart_hex

	B0MOV A, txPktLen
	B0BTS0 FZ ; Skip if not zero
_write_done:
	B0BSET usbStateIn0Done
_write_not_yet_done:
	RET

_write_empty_to_ep0:
	B0MOV txPktLen, A
	B0BTS1 usbStateIn0Done ; Jump if unset
	JMP _write_to_ep0_update_len
	MOV A, #'s'
	CALL _uart_tx
	JMP _write_to_ep0_update_len
	;B0BSET FUE0M1 ; Stall EP0 (FUE0M0 doesn't matter)
	;RET

_usb_dth_get_interface:
	; There's not altsettings, so always return 0
	MOV A, #_usb_status_ok$M
	B0MOV txPtrHi, A
	MOV A, #_usb_status_ok$L
	B0MOV txPtrLo, A
	MOV   A, #1
	B0MOV txSizeLo, A
	JMP _usb_write_ep0

_usb_dth_get_device_configuration:
	; There's only a single configuration, always return 1
	MOV A, #_usb_configuration$M
	B0MOV txPtrHi, A
	MOV A, #_usb_configuration$L
	B0MOV txPtrLo, A
	MOV   A, #1
	B0MOV txSizeLo, A
	JMP _usb_write_ep0

_usb_dth_get_status:
	MOV A, #_usb_status_ok$M
	B0MOV txPtrHi, A
	MOV A, #_usb_status_ok$L
	B0MOV txPtrLo, A
	MOV   A, #2
	B0MOV txSizeLo, A
	JMP _usb_write_ep0

_usb_htd_set_configuration:
	; Only one configuration, nothing to do.
	MOV A, #0x20  ; ACK with no TX
	B0MOV UE0R, A
	RET

_usb_htd_clear_feature:
_usb_htd_set_feature:
	; FIXME: For now we'll just ignore these
	MOV A, #0x20  ; ACK with no TX
	B0MOV UE0R, A
	RET

_usb_htd_set_address:
	MOV A, #'a'
	CALL _uart_tx
	B0BSET usbStateSetAddress
	MOV A, #0x20  ; ACK with no TX
	B0MOV UE0R, A
	RET

_usb_htd_hid_set_idle:
	MOV A, #'I'
	CALL _uart_tx
	MOV A, #0x20  ; ACK with no TX
	B0MOV UE0R, A
	RET

_usb_htd_hid_set_report:
	MOV A, #'r'
	CALL _uart_tx
	B0MOV A, EP0OUT_CNT
	CALL _uart_hex

	; First, set the "enter flasher bit"
	B0BSET usbStateEnterFlasher

	; Check each bit against the expected pattern and clear the flag if mismatch
	B0MOV A, EP0OUT_CNT
	CMPRS A, #0x08
	B0BCLR usbStateEnterFlasher

	MOV A, #0
	B0MOV UDP0, A
	B0MOV A, UDR0_R
	CMPRS A, #0xaa
	B0BCLR usbStateEnterFlasher
	CALL _uart_hex

	INCMS UDP0
	B0MOV A, UDR0_R
	CMPRS A, #0x55
	B0BCLR usbStateEnterFlasher
	CALL _uart_hex

	INCMS UDP0
	B0MOV A, UDR0_R
	CMPRS A, #0xa5
	B0BCLR usbStateEnterFlasher
	CALL _uart_hex

	INCMS UDP0
	B0MOV A, UDR0_R
	CMPRS A, #0x5a
	B0BCLR usbStateEnterFlasher
	CALL _uart_hex

	MOV A, #0x20  ; ACK with no TX
	B0MOV UE0R, A

	; Enter flasher if flag is still set
	B0BTS0 usbStateEnterFlasher
	JMP _flasher
	RET

_usb_dth_hid_get_report:
	MOV A, #'g'
	CALL _uart_tx
	; Send last 8 bytes in buffer
	; FIXME: Handle this properly
	MOV A, #0x28
	B0MOV UE0R, A
	RET

_usb_setup:
	MOV A, #0      ; Unstall & NAK EP0 IN/OUT
	B0MOV UE0R, A
	B0MOV txSizeLo, A
	B0MOV txSizeHi, A
	B0MOV usbState, A

	MOV A, #' '
	CALL _uart_tx
	MOV A, #'S'
	CALL _uart_tx

	; Copy setup packet
	MOV A, #8
	B0MOV R, A
	B0MOV Y, #bmRequestType$M
	B0MOV Z, #bmRequestType$L
	MOV A, #0
	B0MOV UDP0, A
@@:
	B0MOV A, UDR0_R
	B0MOV @YZ, A
	INCMS UDP0
	INCMS Z
	DECMS R
	JMP @B
	NOP

	; Log bRequest
	MOV A, #1
	B0MOV UDP0, A
	B0MOV A, UDR0_R
	CALL _uart_hex

	B0BTS0 bmRequestType.7  ; Jump if bit7 set
	JMP _usb_setup_dth

	; host is writing to device, check if there will be OUT with data.
	MOV A, wLengthLo
	OR  A, wLengthHi
	B0BTS0 FZ  ; Jump if length is 0
	JMP _usb_setup_htd_no_data

	B0BSET FUE0M0   ; Change EP0 to ACK, wait for data
	B0BSET usbStateHTDData
	JMP _usb_setup_exit

_usb_setup_htd_got_data:
_usb_setup_htd_no_data:
_usb_setup_dth:
	B0MOV  Y, #_setup_dispatch_table$M
	B0MOV  Z, #_setup_dispatch_table$L

_usb_setup_do_dispatch:
	B0MOV  A, bmRequestType
	B0MOV  R, A
	B0MOV  A, bRequest
	CALL _dispatch

	B0BTS1 usbStateSetupInvalid
	JMP _setup_done_valid

	B0BSET FUE0M1   ; Stall EP0

_setup_done_valid:
	B0BTS1 bmRequestType.7  ; Skip if bit7 set
	B0BSET FUE0M0   ; Unnak EP0 IN for final ACK

_usb_setup_exit:
	B0BCLR FEP0SETUP ; Late ack of SETUP irq
	JMP _mainloop


_dispatch:
	B0MOV  xlatVal1, A
	MOV A, R
	B0MOV  xlatVal2, A
	JMP _xlat_next
_xlat_loop:
	AND    A, R
	CMPRS  A, #0xff   ; Jump if last entry
	JMP @F
	JMP _xlat_do_indirect_jump
@@:
	CALL _inc_yz      ; skip jump target
	CALL _inc_yz
_xlat_next:
	MOVC   ; Read ROM word into R (hi) and A (lo)
	CMPRS  A, xlatVal1 ; Jump if A != xlatVal1
	JMP _xlat_loop
	XCH    A, R
	CMPRS  A, xlatVal2 ; Jump if R != xlatVal2
	JMP _xlat_loop
_xlat_do_indirect_jump:
	CALL _inc_yz
	CALL _jmp_yz
	RET ; never reached, kept for disassembler

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
.ALIGN 16
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

_inc_yz:
	INCMS Z
	JMP @F
	INCMS Y
	RET
@@:
	RET

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
