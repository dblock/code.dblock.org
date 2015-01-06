---
layout: post
title: "VirtualBox: Linux on Windows"
redirect_from: "/virtualbox-linux-on-windows"
date: 2011-04-09 21:10:13
tags: [linux, virtualbox, rails, ruby, vmware]
comments: true
---
I am going to say nice things about Oracle software. Brace yourself.

I got a bit tired of fighting Rails on Windows. As someone in the office mentioned, I must be the second biggest user of Rails on Windows, out of a total of two. So late Thursday night I decided to experiment with [Ubuntu](http://www.ubuntu.com/desktop) and installed it with [Wubi](http://www.ubuntu.com/desktop/get-ubuntu/windows-installer). I haven’t run a Linux on a desktop years, so I was pretty impressed, at least till about point number 5.

1. Downloaded the installer, which used a Torrent source, < 10 minutes to get 600Mb.
2. Created an installation without having to do any disk partitions. The entire Linux file system gets stored in a host’s file and I get access to all my Windows files.
3. Automatically updated packages, including kernel. The first time I saw a Windows-update-like system on Linux that just worked.
4. Got Ruby/Rails/Rvm setup in minutes and had my development environment with GEdit and GMate.
5. Bad news, neither hibernate nor standby worked on my Lenovo 410s. It would try, then return me to a login prompt. Tried to fight it for an hour unsuccessfully. Now I know far too much about how standby works in both software and hardware.
6. I do need e-mail. Tried without success to connect e-mail to my Exchange 2007 hosted personal account that I had for many years. Evolution e-mail client failed me, even with experimental MAPI support.
7. Tried 8 different blog editors, none worked with my custom blog or were crappy editors. Running Windows for a blog editor is humorous, but I _need_ my Windows LiveWriter!
8. Discovered [Oracle VirtualBox](http://www.virtualbox.org/) and to my amazement was running Windows 7 in "seamless mode": LiveWriter and Outlook became plain normal windows in my Ubuntu! VMWare Unity did that before, but this is free and worked incredibly well.
9. Ran out of disk space (I had that big Windows VM in my /home). Tried _wubi-add-virtual-disk_ from [here](https://wiki.ubuntu.com/WubiGuide#How do I resize the virtual disks?). It was promising as it did effectively split _/home_ into a new partition. But when it was copying files, _rsync_ hung trying to copy the large .vdi VirtualBox file. Then, suddenly, Ubuntu black-screened on me! I had to power-cycle it. It booted and I tried to complete the copy by hand. Same hang. I tried cp, mv and Nautilus. All hung at some point. Can Linux copy a 25GB file at all?! Finally, copy worked to a different disk, but not back. Gave up.
10. Good news: got my new huge monitor delivered to the office! Connected it. Bad news: it won’t display properly: the screen "shivered". Found [bug #541501](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/541501), tried every suggestion in it. No results. Tried upgrading to the _2.6.39-rc2_ kernel. Installation succeeded, but kernel wasn’t in my list in Grub when booting. Tried upgrading grub, which rendered my partition unbootable. Decided against fighting further and had a beer or two at the [GA happy hour](http://www.generalassemb.ly/), which made me significantly happier.

Overall this was a good experience turned real sour, real fast. But I still needed a better Rails environment, I wanted a Linux experience on my Windows. So I tried again, but this time vice-versa: VirtualBox on Windows 7 and Linux running as a VM. VirtualBox on Windows supports Seamless Mode the same way, which means I can have my Linux tools running inside Windows without having to switch anything! Amazing.

Here’s how it looks.

![]({{ site.url }}/images/posts/2011/2011-04-09-virtualbox-linux-on-windows/image%5b5%5d.jpg)

See that shell window in the back, that’s Ubuntu. And my Windows LiveWriter window is Windows. Pretty awesome!
