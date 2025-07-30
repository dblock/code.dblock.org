---
layout: post
title: Don't Tell Engineers What to Do
date: 2025-07-30 02:00:00
tags: [people, management]
comments: true
---
A famous example where telling Engineers what to do backfired was the Space Shuttle Challenger disaster in 1986. Engineers at Morton Thiokol, the contractor responsible for the shuttle’s solid rocket boosters, warned NASA management that the O-rings in the boosters could fail in cold weather. The night before launch, engineers strongly recommended delaying the launch due to unusually low temperatures. Management, under pressure to proceed, overruled the engineers’ concerns and told them to "make a recommendation based on data, not emotion." Eventually, management told the engineers to sign off on the launch, despite their objections. The shuttle launched in cold weather, the O-rings failed, and the Challenger exploded, killing all seven astronauts on board.

This wasn't a software problem, but plenty of software engineering disasters are documented. The Knight Capital Group trading loss (2012), where rushed deployment caused a $460M loss, the Ariane 5 rocket failure (1996), where reused code not designed for the new rocket led to its destruction, the Therac-25 radiation overdoses (1985–87), where ignoring software safety warnings resulted in patient deaths, and the Healthcare.gov launch (2013), where ignoring technical advice led to a high-profile, catastrophic rollout. In each case, sidelining engineering judgment in favor of business or schedule pressures led to major failures.

I bet you have your own disaster story. To quote you, "I told you so!".

Yet, engineering managers continue telling engineers what to do every day. And not just engineers - all subordinates. Sometimes, it's time pressure. More often it is because managers are also engineers, and occasionally more experienced, so we think we just know better. Do we?

I tell my direct reports that there's nothing I can _make_ them do, but that there may be real consequences. I once refused to do something highly problematic my manager asked me to do, and instead said I'll think about it. It was a clever response, so I thought. They responded that my refusal will become a performance problem, almost hung my remote exception over this, and told me that I failed at "disagree and commit". That's about the moment I decided to leave that company.

Speaking of "disagree and commit", telling people what to do, especially if they are in your direct reporting chain, must not be mistaken for it. A proper disagreement is usually amongst peers and begins with a careful understanding of multiple ways to do something, followed by different opinions on the option to take, and one person making the choice that others disagrees with. One must be able to articulate clearly the reasons for choosing their least favorable option, and be the messenger of that option moving forward, as if it were their preferred choice. A manager can be a tie breaker, but their power must be wielded with extreme caution.

For example, "disagree and commit" in the context of the Swiss government means that even when individual members of the Federal Council personally oppose a popular initiative, they publicly defend and implement it once it’s approved, acting as a unified body. This approach ensures stable governance and respect for democratic decisions, as officials set aside personal views to uphold the collective will and present a united front.

Everything else? That is just what it is, telling people what to do.

So, my advice is not to tell people what to do, unless they want you to, you are helping them move past a point of indecision, or you really strongly feel you must.

The first case is easy. Sometimes people want you to make a decision. For example, I ask others to tell me what to do because I think they are more competent than me. I always ask my lawyer what to do on legal matters, because I am not a lawyer. I like to provide input, but I will ultimately ask my manager to tell me what to do when it comes to organizational decisions that affect not just me, but also my peers. Of course, many people often would rather not make a decision because they don't want to own it, to cover their ass. My usual response in those cases is that I'll help you, but you decide. Note that the common denominator here is that the individual _asks_ you to tell them what to do.

The second is also easy. Sometimes we waste a lot of time figuring out what to do. To quote Tobi at Shopify, "if you can't decide, do what I say". I kinda love it because it's often helpful, and very startup like - we'd rather move fast more often than not.

The last case is much harder. Sometimes the decision is so bad, costly, or permanent, that you really must tell someone what to do. I tend to ask myself whether this decision is reversible or not (a 1-way door, or a 2-way door). For example, prioritizing a feature over another is not a 1-way door decision unless a customer is waiting on something by a deadline. Firing someone is literally a 1-way door. An API can be a 1-way door, but maybe we can find a compromise and label it experimental, turning a 1-way door decision into a 2-way door? Not doing something is usually a 2-way door.

Decisions of what to do belong to those doing the real work. Resist the urge to tell people what to do, and you'll create a much more motivated team that feels like it truly owns all its decisions. A manager is always a bottleneck with more general context, but partial project information. Therefore, teams that can make decisions without consulting their manager will have better velocity, as they are not constantly waiting on a manager's decision. Don't tell people what to do, and they might just go a lot faster.
