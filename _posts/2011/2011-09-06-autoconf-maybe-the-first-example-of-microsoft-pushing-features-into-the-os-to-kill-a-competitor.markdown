---
layout: post
title: "Autoconf: Maybe the First Example of Microsoft Pushing Features into the OS to Kill a Competitor"
redirect_from: "/autoconf-maybe-the-first-example-of-microsoft-pushing-features-into-the-os-to-kill-a-competitor/"
date: 2011-09-06 03:24:54
tags: [vestris]
comments: true
dblog_post_id: 260
---
17 ears ago I wrote autoconf that enabled DOS users to boot multiple configurations without any menus or pause. I admit, I copied the original source from SVM, but ended up working on it for a very long time and extending the features for at least two or three years. The name was unfortunate since GNU already had an autoconf, but I was completely unfamiliar with the *nix side of the world since all I had was a 386 PC. Autoconf went on to be widely used, especially in Europe until DOS 6.2 which introduced multiple configurations that were "good enough". I spent a month writing a converter from DOS configurations into Autoconf configurations, but it was too late, Microsoft pushed me out of the multi-boot market by embedding a crappier default implementation into the operating system. Anyway, I forgive you, Bill.

Here’s the code that let you declare `DEVICE=something.sys` in your config.sys file. I included the juiciest commented parts below. The preamble is already priceless.

{% highlight asm %}
;----------------------------------------------------------------------------
; This code is so simple I just couldn't beleive it. So forget about all
; books on assembler, cause this DOES ALWAYS WORK and is the shortest way
; to do it!
;----------------------------------------------------------------------------
{% endhighlight %}

I used macros stolen from someone’s 3D rendering engine’s source code to avoid typing _push_ and _pop_ too many times. That someone was probably sitting next to me in the basement of [Infomaniak in Geneva](https://www.infomaniak.com/). ASM recursive macros must blow your mind!

{% highlight asm %}
pushx macro r1, r2, r3, r4, r5, r6, r7, r8  ;that's a usefull macro
    ifnb <r1>                               ;stolen it from the source
    push r1                                 ;of a 3D vector engine...
    pushx r2, r3, r4, r5, r6, r7, r8        ;pushx + 8 registers max
    endif
endm                                        ;assembled depending from
                                            ;pushed quantity
popx macro r1, r2, r3, r4, r5, r6, r7, r8
    ifnb <r1>
    pop r1
    popx r2, r3, r4, r5, r6, r7, r8
    endif
endm
{% endhighlight %}

The following seems pretty magical to me right now. Oh yeah, otherwise it STUCKS!

{% highlight asm %}
ORG 0000h                                    ;INDESPENSABLE, SINCE OTHERWISE IT STUCKS

driver_suiv     dw      -1                   ;ALL THIS IS NECESSARY FOR
        dw      -1                           ;DOS COMPATIBILITY AND
attribut        dw      8004h                ;CONFLICT AVOID, if you remove
req             dw      offset sys_request   ;it will stuck the machine
run             dw      offset init          ;CRAZY DOS!!!!
nom_device      db      'NUL    '
{% endhighlight %}

Who uses DOS 3.2, seriously?

{% highlight asm %}
lds     bx,dword ptr cs:[req_ofs]       ;verify the DOS rubbish
mov     word ptr [bx+14],0              ;version -> stay resident
mov     word ptr [bx+16],cs             ;or not
push    bx                              ;who uses DOS 3.2 ????
mov     ah,30h
int     21h                             ;HAS TO STAY RESIDENT BEFORE
pop     bx                              ;DOS 3.2, cause otherwise
cmp     al,3                            ;IT WILL GO CRAZY
{% endhighlight %}

Finally ...

{% highlight asm %}
END                     ;oh finally the end...
{% endhighlight %}

The entire source for this gem is [here](https://raw.github.com/dblock/autoconf/master/src/CLRBUFF.ASM). And I’ve published the complete autoconf source [here on Github](https://github.com/dblock/autoconf).
