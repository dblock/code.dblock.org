---
layout: post
title: "Ruby: Unlearning OOP and Embracing Anarchy"
redirect_from: "/ruby-unlearning-oop-and-embracing-anarchy/"
date: 2011-03-03 17:09:18
tags: [ruby, testing, java]
comments: true
---
![anarchy]({{ site.url }}/images/posts/2011/2011-03-03-ruby-unlearning-oop-and-embracing-anarchy/anarchy_4.jpg)

Ruby is an object oriented language, but not quite in the sense of Java or C++. It’s a **D** ynamically **I** nterpreted **L** anguage **B** ecoming **E** ventually **R** eflective and **T** yped (DILBERT), with a lot of OOP flavor sprinkled all over it. It’s basically magical.

Today I had to unlearn interfaces.

I have _Widgets_ and _Gadgets_ that can be scored according to some complex criteria. In Java I would create an _IScorable_ interface with a _score_ method and implement it inside _Widget_ and _Gadget_. The purpose of this is to be able to pass an _IScorable_ anywhere and call _IScorable.score_ in all the right places. My first reflex was to replicate it in Ruby and create a base abstract _Scorable_ class. My code reviewer then asked: _"Since this class doesn’t do anything, why do you need it?"_. Fair point! In Ruby this is completely unnecessary. You can pass anything to anyone and as long as they have a score method, call it. I don’t need a base interface and I don’t need to derive from it.

If you’re a Java programmer, you’re probably appalled by such a monstrosity. What is this? Anarchy? As far as I am concerned I think I am finally OK with this. It’s a different model of coding that requires you to rely on tests rather than on compile-time errors. With more tests you get better software in any programming language: more reliable since everything is automatically tested, and better and more elegant code since tests force you to rethink and refactor in terms of interfaces all the time. You just don’t need to declare those interfaces.
