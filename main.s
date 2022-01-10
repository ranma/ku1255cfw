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

xlatVal1       DS 1
xlatVal2       DS 1


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
	JMP @B

_usb_sof:
	B0BCLR FSOF
	JMP _mainloop

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

_usb_init:
	MOV A, #0
	B0MOV usbState, A
	B0MOV usbState2, A
	B0MOV USTATUS, A
	MOV A, #0x80
	B0MOV UDA, A  ; Set address to 0 and enable
	B0BSET FDP_PU_EN ; Enable D+ pull-up
	B0BSET FSOF_INT_EN ; Enable SOF interrupt request
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
	MOV A, #'o'
	CALL _uart_tx

	B0BCLR FEP0OUT ; Ack OUT irq
	JMP _mainloop

_setup_dispatch_table:
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
	DW 0x8106  ; GET_DESCRIPTOR (interface)
	JMP _usb_dth_get_interface_descriptor
	DW 0xa101  ; HID GET_REPORT
	JMP _usb_setup_default
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
	B0MOV A, txSizeLo
	CALL _uart_hex

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
	MOV A, #0x20  ; ACK with no TX
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
