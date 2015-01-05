---
layout: post
title: "Can you believe it? I wrote this code over 10 years ago..."
redirect_from: "/can-you-believe-it-i-wrote-this-code-over-10-years-ago"
date: 2009-09-19 04:45:00
tags: [dos]
comments: true
---
I wonder whether it still compiles and runs.

```asm
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Beep speaker; period given by beep_div, duration by beep_len.
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
beep proc
	pushx ax,bx,cx,dx,si,di,es,ds ;preserve registers
	mov al,10110110b ; select 8253
	mov dx,43h ; control port address
	out dx,al
	dec dx ; timer 2 address
	mov ax,cs:[beep_div]
	out dx,al ; low byte of divisor
	xchg ah,al
	out dx,al ; high byte of divisor
	mov dx,61h
	in al, dx ; get current value of control bits
        push ax
	or al,3
	out dx,al ; turn speaker on
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Wait for desired duration by monitoring time-of-day 18 Hz clock
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	mov bx,cs:[timer_low]
	mov cx,-1
beeplp: mov ax,cs:[timer_low]
	sub ax, bx
	cmp ax,cs:[beep_len]
	jg beepover
	loop beeplp
beepover:
	; Turn off speaker
        pop ax
	and al,not 3 ; turn speaker off
	out dx,al
	popx ds,es,di,si,dx,cx,bx,ax
	ret
beep endp
```



