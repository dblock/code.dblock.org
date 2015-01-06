---
layout: post
title: "Why I Love Code Reviews"
redirect_from: "/why-i-love-code-reviews/"
date: 2012-06-28 13:12:41
tags: [teams, teaching, technology, art.sy, open source, people, agile]
comments: true
dblog_post_id: 340
---
I had a short, but lively debate over code reviews with [@skamille](https://twitter.com/skamille) at New York’s QCon 2012. That same day she wrote an [interesting blog post on code reviews](http://whilefalse.blogspot.com/2012/06/code-reviews-code-stories.html). She argues that "code reviews are just as likely to used to bully, score points, or waste time on pedantic style notes as they are to produce great software". Certainly, not the kind of team I’d ever want to work with!

I feel very strongly about the positive effect of code reviews. I would get rid of as much "process" as possible, but not code reviews.

#### Mechanics First

Mechanics are important, because not all code review systems are created equal.

We have a master repository on Github that every member of the team makes a fork of. Developers make pull requests into that repo. Each pull request is code reviewed by any team member chosen by the requester at random. A typical pull request will be titled hash-rocket-style. In the following example, I’m making a pull request to @maxis about a few reticulated splines. In practice I’d write a longer explanation, but reticulating splines is a well understood concept in 2012.

![]({{ site.url }}/images/posts/2012/2012-06-28-why-i-love-code-reviews/image4.jpg)

The code reviewer will look at the diff line-by-line, ask questions and comment on the pull request as a whole if they choose to do so. The reviewer will then merge the code with the magical green button or will send the code back to me with a list of "must haves", "should haves" and "nice to haves". Anyone else can comment on the pull request at any time. I would fix all the "must haves", open bugs for "should haves" in PivotalTracker and consider "nice to haves". I’d generally want my code reviewer to be happy, so I’ll make more changes than I have to.

You can see that we try to follow a similar process to Github’s style of collaborative development (read [this blog post](https://github.com/blog/1124-how-we-use-pull-requests-to-build-github)), except that we don’t design much within the pull request – we do this with humans on paper. Unlike the Github team, we tend to prefer smaller pull requests that are well rounded increments of features. This is what the open-source community has been doing for years, so we work like any open-source project in our closed-source environment.

#### Having Trust

Experienced developers do code reviews because they trust each-other.

In the field of software engineering I trust certain people to write excellent code without supervision and operate on production data without too many safety nets. I trust them to do the "right thing" in case of emergency. I trust their gut feel, their experience and will defer to them any important decision without hesitation.

I want a code review from better developers because I trust them to point out issues in my code so I can continue improving.

#### Earning Trust

Code reviews for junior developers is a learning opportunity for all.

Interns and junior hires always ask me what the team expects from them in terms of code quality. I usually say that we want the same final result as if anyone of us had written the code, but usually over a much more forgiving timeframe. I advise juniors to take bite-size work-items and iterate on them until their more experienced code reviewer says the code is really good and, most importantly, until the developer sees and understands why that code went from not good enough to really good. A typical such code review is riddled with notes, and every single one of them is gold.

The reviewer learns to balance "must haves", compromise where appropriate and produce clear written explanations. Teaching is a very important element in any engineer’s career and teaching is really hard.

#### Sharing Knowledge and Connecting People

Knowledge takes multiple forms and deserves to be shared.

Pull requests and their code reviews are the curated changelog of your application. You may use _git bisect_ to find a bug, but you will read code reviews to learn about what features are being built. If you read the high level of every single pull request, you would know what’s really going on. Read about it hours or days before it makes it to production and comment if you think it’s taking the wrong turn! Pull requests can replace some of the curated status reports too, since those include half truths and half lies. They also don’t interrupt anyone (the reviewer doesn’t have to jump on the code review right away) and provide an opportunity for non-technical people to comment in the developer’s context.

Is your product management disconnected from product development? This could be your fix.

#### Taking it Personally

If a code review makes you cranky, something is wrong. If you are being bullied in a code review, rebel!

In general, grow a thick skin and don’t take it personally. Other people may use adjectives and tell you the code sucks, but they don’t mean "you suck". They are usually, genuinely, trying to help your code get better. Of course, code reviews are no place for bullying. And as in all written communication both parties must learn to be civil, not call people names or insult them and consider how anything they write will be read by the recipient. And there’s no place for assholes on a team, period.

#### Praise the Code

The best code reviewers point out the good stuff as often as they point out the bad stuff.

[@gib](https://github.com/gib) made a pull request getting rid of `#!` in one of our projects. It spanned 79 commits with 150 files changed. Phew. The comments were overwhelming.

![]({{ site.url }}/images/posts/2012/2012-06-28-why-i-love-code-reviews/image_14.jpg)

Tell me these aren’t awesome!
