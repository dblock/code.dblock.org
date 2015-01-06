---
layout: post
title: "Corporate Change: Contributing to Open Source"
redirect_from: "/corporate-change-contributing-to-open-source/"
date: 2010-11-04 11:30:00
tags: [appsecinc, open source, organizations, people]
comments: true
---

This is a story of corporate change. It’s a tale about how an unlikely organization embraced open-source. It starts with pain and suffering and may even read like an "I hate my boss" diatribe. I don’t. On the contrary, this story ends better than I would have ever hoped. It will give you hope too.

#### In the Beginning

When I left Microsoft eight years ago I wished I could take http://toolbox with me. Toolbox was an internal Microsoft website dedicated to shared utilities. I found myself needing the same applications, again and again, "out there here in the real world".

Fast forward a couple of years. I was a manager in another software firm in New York City. We wrote a nice little command-line utility for driving virtual machines for integration testing. It turned out to be quite a success. We were getting so much coverage and full regression testing with very little effort. We’ve definitely eradicated install and upgrade failures and our customers have noticed. Was I going to have to write that again at my next job? Was I going back to square zero and wishing I could take our version of Toolbox with me?

With this in mind I went to executive management to propose to open-source this piece of software. The code had nothing to do with our primary business and should have been a no-brainer. Yet, it took two years. I have succeeded beyond my own expectations, and in this process I learned a few valuable lessons.

#### The Mission

I had a chat with my VP-level boss about open-sourcing a project. This was the tenth item among the other twenty more important things that were going on. We were running a business, software sold for millions of dollars. It took me three months to realize that all we were doing is chatting and I was desperately trying to convince him about the worth of my initiative. It wasn’t going anywhere. Here’s why.

I forgot that I was facing traditional executive management. Our type of organizations never seem to care about anything that doesn’t directly or indirectly add to the company’s revenue. The first impression that I got is that if I couldn’t put my project in the perspective of added revenue, it couldn’t happen. But trying to put revenue on things that don’t have any is an easy target for an experienced sales-driven group or manager. For example, I tried to come up with a clever plot and pretend as if open-sourcing our test automation tool could make the company money. I was making up stories, it was obvious to me that we were not going to extract a dollar of revenue from this. Being an engineer I quickly lost arguments that involved cash. I even tried to push the idea, that open-sourcing a tool will result in external contributors that would rush on our implementation and therefore add hundreds of man-hours to our project, improving and bug fixing it. That’s money! But I quickly realized that executive management was as excited about free developer hands for some internal tool as about the fact that we switched from version X to Y of yet another technology widget. After all, if we really needed more headcount to work on tools, maybe we should have had that conversation instead?

I didn’t need to shift opinions. I needed my pet project open-sourced.

#### Clarity

I put the project terms clearly in an e-mail and clearly stated my question.

> Project: Remote Installer, a tool that enables integration and system automation testing for installers.
> Internal website: ...
> Contributors: ... (3 people)
> Lines of code: 2,829
> What’s the next step?

I’ve now thrown the ball in my boss’s hands. I also made it clear, in writing, that I don’t plan to back off.

Replies to specific action items usually come quickly. I learned that we needed to get an IP attorney’s opinion in order to protect the company. An IP attorney would simply review the details and state that the source code does not contain any core intellectual property and that it doesn’t represent a risk if it were published. No executive would make a call to open-source anything without an IP attorney’s written document. I now realize that it was actually a good thing. As a shareholder of the company I wouldn’t want anyone to do anything radical that could have compromised the hard work and the massive amounts of intellectual property.

An IP attorney’s involvement costs a few grand. My direct manager had the money and I needed him to spend it. But times were tough, recession and unemployment climbing, and he kept doing nothing about it. I didn’t expect him to make this a priority, after-all there’s no perceived benefit of the project.

I got tired of asking. I chose to re-develop the tool on my copious free time as free software. I was effectively giving up on my employer to support my project. At that very moment I was filled with disappointment and sadness and had decided to take a vacation to work on my pet. I booked time off and made it clear to my boss that his level of support for this project would have strong and direct impact on my job satisfaction. I further explained that this was no less important to me than career path or compensation and I wanted some genuine support for my idea.

If you understand why I had put my job on the line for a small technical project, then you’re a little bit like me.

#### Leverage

Effectively I used leverage. I didn’t see it this way, but I could have done it on purpose. Leverage is always a complicated, personal and risky business. It could have cost me my job, a healthy relationship with my boss or both. Instead, with my vacation approaching, an IP attorney was paid.

It took a mind gobbling amount of back-and-forth to explain to the lawyer the gist of the software and to correct the documents to represent reality and not some legalese fiction. Nevertheless the lawyer insisted on a clean separation between the open-source project and the company’s intellectual property, recommended releasing the software under the Eclipse Public License and amended the standard software EULA of our products to reflect this.

I was holding a tangible, paid for, legal opinion.

#### Sunrise

Something interesting happened. Sometimes I let my direct reports work on things I disapprove and every so often they prove me wrong. Those are humbling moments that make me feel really good about any decision taken despite my own position as a leap of faith. In a similar style, my boss was no longer resisting, and almost supporting my mission. It seemed that he really got the message of how important the project is to me and chose not to listen to his own arguments, but just do it.

The legal paperwork was taken to a randomly selected group of executives in a 1-on-1 manner.

I am not sure what happened behind closed doors, but I am positive that the benefits outlined did not include some grand mission for the company. I don’t know the contents of the discussion, but I am confident that everyone was happy to do anything as long as it didn’t affect their organizations in a big way. A broad consensus was reached quickly and it appeared in front of the CEO. The latter was actually unexpectedly supportive and the project got approved.

#### Sunset

We had our <a href="https://github.com/dblock/remoteinstall">first open-source project</a>! In-fact, we had <a href="https://github.com/dblock/msiext">two</a>. Both were met with relative disinterest from the open-source community. I counted enthusiasts, contributors and users on a couple of hands. There was a mention on an online tech TV show that nobody watched. If this were a commercial project it would have been an astounding failure. But it didn’t really matter to me because my team developed the tools for ourselves, not for others. We weren’t on some kind of global mission for the greater good, we were just hoping it could be useful.

More importantly, my company operated a major mental shift. And a third project went open-source quietly.

Then everything went wrong. Thousands of downloads, major contributors, dozens of happy users. This <a href="https://github.com/dblock/waffle/">last project</a> became wildly successful.

#### Policy

With this success I finally had an opportunity to make contributing to open-source a company policy. I wrote two documents and had the executive management team approve them (with my boss’s help). Use them as a template for your own. The first one outlines simple rules of releasing software as open-source.

> #### Releasing Software as Open Source
>
> #### Overview
>
> The company is an active contributor to open-source and funds a number of open-sourced projects. Engineers are encouraged to create new open-source projects that are born from the company's business needs.
>
> #### Open Candidates
>
> Any good quality generic tool or piece of software infrastructure that does not represent a competitive edge for the company is a candidate for open-source. Core intellectual property is not.
>
> For example, a test tool is a good candidate, while the core IP service XYZ is not.
>
> #### Steps
>
> 1. Identify a project clearly, in writing. If the software has already been written, specify which artifacts you wish to open-source, specifically source code in SVN.
> 2. Prepare a 1-2 slide presentation to clearly explain the project. A sample presentation can be found at ... .
> 3. Email the presentation to your manager and get their approval.
> 4. Schedule a 1 hour meeting with the following people: CEO, VP of Engineering, VP of Corporate Development, VP of Products, Open Source Cheerleader (Me), Your Manager.
> 5. Present your project. The group will discuss it and approve or deny or require additional activities, such as clearing the project with an attorney.
> 6. If approved, the group will identify the proper license (currently the Eclipse Public License) and give you the go-ahead.
> 7. Schedule an open-source release date and corresponding review date with the VP of Engineering. Sites like <a href="http://www.codeplex.com/">CodePlex</a> allow draft projects before they are published. It is essential that a review of this public release be completed immediately preceding the release.
> 8. Publish the project and tell the world about it.

The second clarifies the rules of engagement with existing open-source projects. We can finally commit changes to projects we use and put the company’s name in them.

> #### Contributing to Open Source
>
> #### Overview
>
> The Company is an active open-source contributor and funds several open-source projects. The Company encourages you to contribute to such open-source projects on company time provided that it's cleared with your manager.
>
> #### Clearance
>
> You must notify your manager and clear, in writing, your plans to contribute to an open-source project. Describe the purpose of your efforts.
>
> Usually, but not always, such projects directly benefit the Company. Those are typically directly or indirectly used by a Company product, service or partner and  often require improvements to further benefit the company.
>
> You may also be a contributor to free and open-source projects that improve your technical skills and further your career as an engineer or help with networking among peers that work for other companies. A percentage of your work time may be allocated to such contributions with your manager's approval.
>
> #### Copyright
>
> When contributing to open-source projects on company time you must identify yourself as an employee of the Company and include (c) Company and your name, in every appropriate source code location.
>
> #### Publication
>
> We encourage you to blog about your personal contribution to an open-source project in places that identify yourself as an employee of the Company.
>
> #### Limitations
>
> You may not contribute to any open-source projects in the areas of the Company’s primary mission. This includes, but is not limited to our core business of ....
>
> #### Common Sense
>
> Keep in mind that the primary goal of the Company is to be the market leader in our core business. of ... Use common sense as far as how much time or effort you're willing to dedicate to open-source projects and features on company dollars that aren't directly improving by shipping software.

#### Announcements

I gave a talk about our new policies at the last Engineering all-hands, including one on personal technical blogging. There were skeptics and there were supporters. Then, several people contacted me in private to say how excited they were by these changes, how they got the "become a craftsman, learn from other craftsmen" message. That alone deserves another blog post.

Today I am sitting in a much different <a href="http://www.appsecinc.com/">AppSecInc.</a> office on Madison Ave., one with hope and some level of renewed enthusiasm. Enabling engineers to contribute to open source was a major shift for a company which has Database Security, Risk and Compliance as primary business. We employ the world’s <a href="http://www.teamshatter.com/">best database security research team</a> and we know how to keep our mouths shut. We are advised and trusted by the world’s most secretive organizations. We sit on critical zero-day vulnerabilities for months before vendors fix them. Open-source was so remote for us two years ago, yet we’re now more open than ever. Now, my engineers will grow active soldiers of an army of hundreds of thousands, with opportunities to work with the best technologists while still making  a tremendous impact on the software which both pays their bills and solves real business problems. The open source initiative will benefit the company in a big way, affecting hearts and minds, those priceless bits of individual motivation.
