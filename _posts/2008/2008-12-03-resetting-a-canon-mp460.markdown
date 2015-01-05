---
layout: post
title: "Resetting a Canon MP460"
redirect_from: "/resetting-a-canon-mp460"
date: 2008-12-03 04:25:03
tags: [hardware]
comments: true
---
This is going to be my first hardware post. We'll start simple - I do have a copy of [The Art of Electronics](http://www.amazon.com/Art-Electronics-Paul-Horowitz/dp/0521370957) and a welder, so there's a chance I might post something meaningful one day.

I was about to throw my MP460 Canon printer (80$) out of the window (8th floor, 10$ a flight of stairs). I was trying to setup a wireless print server and finally got that working, when the printer came back with an obscure 5100 error. I tried everything, including shaking it violently. What worked was a reset, and [this page](http://tricks-collections.com/2008/04/reset-printer-canon-mp140-mp160-mp180-mp210-mp220-mp460-mp470-mp500-mp510-mp530-mp600-mp610-mp800-mp820-mp810-mp830-mp960-mp970/) explains how.

1. Turn off the printer
2. Hold the Resume Button (red circle in the triangle), add a printer (click "Power") an indicator light green.
3. Hold the Power Button, release the Resume Button.
4. Not releasing the Power Button, double click "Resume" and release Both Buttons.
5. Click "Resume" for Four times
6. Once you click "Power", to confirm the selected action (reset counter absorber). To disable the printer "Power" button to click again.

On the wireless front, I got a Linksys [WPS54G](http://www.linksys.com/servlet/Satellite?c=L_Product_C2&childpagename=US%2FLayout&cid=1114037289494&pagename=Linksys%2FCommon%2FVisitorWrapper). None of the wizards worked, go figure. I ended up being able to connect to the printer's HTTP configuration interface, but couldn't configure it on Vista. It wasn't too hard to configure manually with [some help](http://forums.linksys.com/linksys/board/message?board.id=Wireless_Print_Servers&thread.id=1476).

1. Add the appropriate printer from _Control Panel_, _Printers_, _Add Printer_
2. Select _Local Printer_ and select _Create New Port_, _Standard TCP/IP Port_
3. _Device Type_, _TCP/IP Device._
4. _HostName_ or _IPAddress_ should be the IP Address of the Print Server Device. I configured it with a static IP.
5. After nothing is detected choose _Custom_, _Settings_
6. Select _LPR_, set _Queue Name_ to _L2_ for USB printer.
7. Turn on _LPR Byte Counting Enabled_. 
8. Select the printer, install the driver.

Easy? Ahem.


