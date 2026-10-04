---
layout: post
title: "Universal Copy System Link for 97 Windows PCs"
date: 2026-10-03
tags: [ai, nostalgia]
---

In 1997 I wrote [UcsLink.Fusion](https://github.com/dblock/ucsLink.Fusion) for the [University of Geneva](https://www.unige.ch/). We had hundreds of PCs across the city, Sun and Windows NT servers, and Windows 95 and Linux workstations. Getting a user's software and settings onto whichever PC they sat down at was a job for login scripts. I wrote a Delphi 2.0 application to do it instead.

UCS stood for Universal Copy System. Fusion read a script that mapped network drives, copied shared software, created shortcuts, connected printers, set environment variables and synchronized the clock. It could include other scripts, test conditions and clean up files left by a previous run. The surviving configuration maps a personal drive, a software drive and a group drive, then chooses printers based on the workstation's location.

![The original UcsLink.Fusion user options browser](/images/posts/2026/2026-10-03-ucslink-fusion-configuring-university-workstations-in-1997/fusion_treeview.gif)

A user could disable optional software rather than wait for it to copy at every login, or install it later by double-clicking its icon. Administrators could make tasks mandatory and protect individual options. A tree showed the tasks and their settings; a second list showed what would run. User choices went into a personal profile, separate from the shared script.

When Fusion started at login, it displayed the little progress window below, showing the tasks as it configured the workstation.

![The original UcsLink.Fusion task list](/images/posts/2026/2026-10-03-ucslink-fusion-configuring-university-workstations-in-1997/fusion_listview.gif)

Fusion could scan a shared software directory and automatically add each application it found to the list of available software. Each application could come with its own script describing how to install and configure it. Tasks normally ran one after another, but a `detached` option let copies or banners run concurrently. Later, server-generated "virtual" scripts grouped applications into one file to avoid dozens of slow network accesses.

Fusion was released as [public-domain software](https://github.com/dblock/ucsLink.Fusion/blob/master/LICENSE). It was also used at [ITIC](https://web.archive.org/web/19980529151154/http://www.usu.br/1itic.htm), the Instituto de Tecnologia da Informação e da Comunicação (Institute of Information and Communication Technology) at [Universidade Santa Úrsula](https://usu.edu.br/) in Rio de Janeiro. Its [archived history page](https://web.archive.org/web/19980529152924/http://www.usu.br/2itichist.htm) says the institute was established on March 30, 1995, initially offering Computer Engineering. It later added an information technology degree and Library Science, with an emphasis on information management. Its [mission](https://web.archive.org/web/19980529152836/http://www.usu.br/2iticmiss.htm) included supporting the university's own information and communication technology needs. The illustration below says Fusion would configure the Windows 95 programs available to ITIC students.

![The original illustration of UcsLink.Fusion at ITIC](/images/posts/2026/2026-10-03-ucslink-fusion-configuring-university-workstations-in-1997/itic.gif)

Geneva was also helping Santa Úrsula with its campus network. An [archived University of Geneva page](https://web.archive.org/web/19991011062240/http://www.unige.ch/aides/bresil.htm) says that in April 1997, Chancellor Madre Maria de Fâtima Maron Ramos requested an independent assessment of the network installation. A first visit took place April 18–27, 1997, with Ethernet and Fast Ethernet planned for the campus and a fiber-optic backbone connecting buildings on opposite sides of a street. Later visits were made by Jean-François L'haire, from the University of Geneva's IT division, who came with students to propose hardware and software for Santa Úrsula. Fusion was one of these, along with [BpBatch](https://tldp.org/HOWTO/Remote-Boot-5.html), a remote boot program from the same university. L'haire also [taught at Santa Úrsula](https://www.unige.ch/presse/communique/98-99/conference_sur_internet.html), and in 1999 he gave a course there live from Geneva over the web.

The [last source code backup](https://github.com/dblock/ucsLink.Fusion/tree/master/original) is from September 29, 1997. There is a whole administrator reference, a [student guide](https://web.archive.org/web/19991008033249/http://cuiwww.unige.ch/info/pc/fusion/manual.html) and a C++Builder Windows Control Panel extension that launched the configuration browser. An application's script could define the name, icon and options shown to users in the configuration browser.

I haven't reconnected it to the university's old servers. A local demonstration creates a workspace, copies a welcome document and makes a Notepad shortcut, all in its own Wine prefix. The configuration browser works again; the network operations and separate Control Panel extension remain unverified.

![The restored UcsLink.Fusion configuration browser and local task demonstration](/images/posts/2026/2026-10-03-ucslink-fusion-configuring-university-workstations-in-1997/fusion.gif)

The original source and documentation, the port, and the build scripts are [on GitHub](https://github.com/dblock/ucsLink.Fusion).
