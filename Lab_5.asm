;************************************************************************
; Filename: Lab_5														*
;																		*
; ELEC3450 - Microprocessors											*
; Wentworth Institute of Technology										*
; Professor Bruce Decker												*
;																		*
; Student #1 Name: Takaris Seales										*
; Course Section: 03													*
; Date of Lab: <06-21-2017>												*
; Semester: Summer 2017													*
;																		*
; Function: This program uses an analog to digital converter (ADC)		* 
; to digitize the input of a simulated sensor signal conditioning  		*
; circuit (SCC). An external power supply is used to vary the input		*
; power and observe the conversion as an ouput to LEDs.		 	        *	
;																		*
; Wiring: 																*
; One RA7 switch connected to LED       								*			*
;************************************************************************												*
; A register may hold an instruction, a storage address, or any kind of data
;(such as a bit sequence or individual characters)
;BYTE-ORIENTED INSTRUCTION:	
;'f'-specifies which register is to be used by the instruction	
;'d'-designation designator: where the result of the operation is to be placed
;BIT-ORIENTED INSTRUCTION:
;'b'-bit field designator: selects # of bit affected by operation
;'f'-represents # of file in which the bit is located
;
;'W'-working register: accumulator of device. Used as an operand in conjunction with
;	 the ALU during two operand instructions															*
;************************************************************************

		#include <p16f877a.inc>

TEMP_W					EQU 0X21			
TEMP_STATUS				EQU 0X22			


		__CONFIG		0X373A 				;Control bits for CONFIG Register w/o WDT enabled			

		
		ORG				0X0000				;Start of memory
		GOTO 		MAIN

		ORG 			0X0004				;INTR Vector Address
PUSH										;Stores Status and W register in temp. registers

		MOVWF 		TEMP_W
		SWAPF		STATUS,W
		MOVWF 		TEMP_STATUS
		BTFSC		PIR1, ADIF
		GOTO		ADINTR

POP											;Restores W and Status registers
	
		SWAPF		TEMP_STATUS,W
		MOVWF		STATUS
		SWAPF		TEMP_W,F
		SWAPF		TEMP_W,W				
		RETFIE

ADINTR										;ISR FOR ADC
		BCF			PIR1,  ADIF
		MOVF		ADRESH, W				;Moves High Result to W Register
		MOVWF		PORTD					;Moves High Result to PortD from W register
		BSF			ADCON0, GO				;Start next conversion
		GOTO 		POP
				


MAIN
		CLRF 		PORTD
		BCF			INTCON, GIE				;Disable all interrupts
		CLRF 		PORTD					;Clear GPIO to be used	
		BCF			STATUS, RP0				;Bank0
		MOVLW		0X81
		MOVWF		ADCON0
		BSF			INTCON, PEIE			;Enable Peripheral Interrupts				
		BSF			STATUS, RP0				;Bank1 
		MOVLW		0X0F					;Left-Justified, External Power Supply, Analog Inputs AN0, AN2, AN3
		MOVWF		ADCON1
		MOVLW		0X0D					;Port 0,2,3 as inputs
		MOVWF		TRISA
		MOVLW		0X00					;TRISD is 0000 0000 to have all outputs
		MOVWF 		TRISD
		BSF			PIE1, ADIE
		BCF			STATUS, RP0				;Bank 0
		BSF			INTCON, GIE				;Enable all interrupts


Conversion				
		BSF			ADCON0, GO				;Start A/D Conversion. ADIF Bit set and Go/Done bit cleared upon completion
		


LOOP
		NOP


		GOTO		LOOP

	


		END
