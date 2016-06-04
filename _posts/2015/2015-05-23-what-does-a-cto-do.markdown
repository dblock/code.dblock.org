---
layout: post
title: "What does a CTO do?"
date: 2015-05-23
tags: [cto, head of engineering, vp of engineering]
comments: true
pinned: true
---
I now have an executive coach. I wish he just told me what to do, but we pay him a lot of money not to, which means I have to figure it out by myself. So I turned to my personal network and asked the following question.

> You're a CTO, what do you do?

Nobody gave me a list! A lot of replies described what _not_ to do. Some emphasized the [difference between a CTO and a VP or Head of Engineering](/2015/05/07/what-is-the-difference-between-cto-and-vp-or-head-of-engineering.html), but I thought I already had that nailed down reasonably well.

> A company has many possible successful outcomes. Organizations iterate and find a business by trial and error. The job of a CTO is to continuously ensure that all possible outcomes are enabled with technology, while the job of a VP or Head of Engineering is to execute on the outcome currently chosen.

So how do I find out what I should be doing every day? What is it that I _actually_ do?

I decided to apply test-driven development to this problem.

{% highlight ruby %}
shared_examples "is worthy of dB's time" do
  it 'is aligned with core values'
  it 'gets the company closer to its vision'
  it 'helps achieve the company mission in a big way'
  it 'has company-wide scope'
  it 'has long term impact'
  it 'has large scale impact'
  it 'is strategic'
  it 'is not mired in small details'
  it 'has a clearly defined outcome'
  it 'has a measurable outcome'
  # what else?
end
{% endhighlight %}

How do I find something to apply these tests to?

Lets begin with a hypothesis.

> Technology is not just a _tool_, it's also an _opportunity_.

So my job is to balance envisioning where the company's technology needs to go with creating technology that enables everyone at the company to meet their business goals. It's a combination of making new things possible and supporting existing projects. Technology also can't exist without _people_, and it has no purpose without a _business_.

This yields three clear priorities: _people_, _technology_ and _business_.

* Technology is built by people, therefore my job is to help attract and retain the best people and to create a culture where they do their best work.
* Technology is a unique multiplier, therefore my job is to build technology that makes big things possible.
* Technology helps the business grow, therefore my job is to drive the highest ROI on technology.

I now have priorities and a test to check against everything I do. This is definitely something I can work with!

My first actual work item was to reach out to team leads and ask: _What can I do for you?_

> Team Leads (on the bcc),
>
> This is one of those broad self-searching quests, brace yourselves :)
>
> I have been watching our increasingly strong Engineering team and am so happy to see it be totally self-sufficient and autonomous and really driving the company forward when it comes to software delivery, technology, etc. I am also excited about a newly forming product organization.
>
> I am a bit less needed around day-to-day code things, which probably means we're on the right track! And I have the luxury of having a bit more time to focus on new things, and am in a really privileged place where I know the company inside-out. I have a strong feeling that there're a lot of things I could be doing as CTO that I am not doing today that could make *your* job a lot easier. It could be meeting with customers, or something else, I want to find out! Two questions:
>
>  - What are the outcomes you are looking to achieve in *your* position in 2015?
>  - For any such outcome, is there anything *I* can do to help you achieve it?
>
>  Thanks!

I applied my test to _actively learning about other team's concrete goals and outcomes_ and it passed. It's medium to long term, strategic and aims at company-wide impact. It is also something very measurable: do I know, at all times, what each team's goals are? Am I following up on the asks from these teams with Engineering team leads? Are they acting on them?

The final step is to create a repeatable process around this. I already have 1:1s with every member of the Engineering team and am now working on scheduling 1:1s with every team lead at least once every six months. I am helping with our quarterly all-hands in order to ensure that each team has an opportunity to communicate their goals and priorities to other teams. Finally, I regularly, gently and quietly nudge team leads that aren't so great at communicating their progress to everyone to imitate those who are better at it.

This is one thing I now do.
