---
layout: post
title: How to Disagree and Commit like Switzerland
date: 2025-08-03 09:00:00
tags: [people, management]
comments: true
---
The most abused principle in dysfunctional organizations is "Disagree and Commit". In [Don't Tell Engineers What to Do](/2025/07/30/dont-tell-engineers-what-to-do.html) I said that _"telling people what to do, especially if they are in your direct reporting chain, must not be mistaken for "Disagree and Commit"_.

So, what is a healthy "Disagree and Commit"?

The best example I know is the Swiss government. Even when individual members of the Federal Council personally oppose a popular initiative, they publicly defend and implement it once it’s approved, acting as a unified body. This approach ensures stable governance and respect for democratic decisions, as officials set aside personal views to uphold the collective will and present a united front.

I was born in the USSR where people had opinions, then the Party decided. Then, I became Swiss in my teens, and lived in Geneva for 9 years. Having had this experience, it became quite obvious to me that the Swiss system was more sustainable, and I have always been impressed with it.

In this post I will teach you how to be Switzerland.

The keys to a healthy disagree and commit are to 1) identify the individual competent to make a decision, 2) lay out the arguments for one decision vs. the other, 3) let the decision maker decide, 4) collectively commit to the outcome sought by the decision.

### Identify the individual competent to make a decision

A decision requires clarity about who has the authority and expertise to make the final decision. It's best to identify this person upfront, not after disagreements arise, usually through a strong sense of ownership in the organization.

When identifying the decision maker remember that a local decision is faster and cheaper than a decision at a higher level, and you never want a team that is so helpless that to reach to the manager for every small decision.

Begin by separating "one way door" and "two way door" decisions. The former cannot, or may be very costly to "walk back" (e.g. adding a public API), while the latter can easily be undone (e.g. choosing a JSON parsing library). Critical, one way door decisions, will need more scrutiny, but two way door decisions can be made lower in the hierarchy. In both cases, look for the decision maker that is the true owner of the work in question. Who will be affected by this decision daily? Who is taking risks? Assuming we will have made the best decision, who will be celebrated as being right when the project is done? That should be the owner of the decision.

When making a significant one way door decision, look for a trusted tie breaker with authority in the hierarchy of the organization. At Amazon, Principal Engineers often step in as tie-breakers for any technical decision. For non-technical decisions use the organizational hierarchy to find the common denominator (e.g. a common manager). Be careful escalating the ask, though - the more senior the manager, the least context they have, and therefore are susceptible to the most articulate arguments (form vs. substance). In dysfunctional organization you will also find a lot of pass-through "leaders" who will refuse to make a decision and escalate to their manager, delaying the decision significantly. Watch a Director ask for more data, then question the existence of the whole project.

In general, I am of the opinion that a technical decision should almost never be made by a manager. A people manager carries organizational weight, often has veto power (can tell people what to do), usually has the least amount of detail regarding any technical decision no matter how technical they are, and will not be suffering the consequences of the decision on a daily basis.

### Lay out the arguments for one decision vs. the other

Once the decision maker is identified, all parties must present their arguments clearly and respectfully. Good arguments include data, examples, risks, and benefits, and should be written down. The goal is to ensure the decision maker has all relevant information and perspectives before making their choice and to get on the same page (literally). This prevents decisions made in ignorance, and ensures that even unpopular choices are made with full awareness of the alternatives. Soliciting broad input at this stage creates more visibility and therefore is an opportunity to FYI the decision to your manager or a senior staff member. Don't be scared, ask other people's opinions now! Give everyone time to think about the problem and to sleep on it.

It's critical that everyone can agree that each option is complete and viable, including yourself. Instead of thinking how you dislike one option (the cons), think in terms of its advantages and disadvantages (both pros and cons) and learn to articulate the pros, too. Finally, if you are the decision maker, avoid writing "recommended" next to any of the options until the last moment not to bias the group.

### Let the decision maker decide

After all arguments are presented, the decision maker must be given the space and authority to make their choice without interference. This means no lobbying after the fact, no attempts to undermine the decision, and no passive-aggressive resistance.

Don't lie by saying "I'd prefer the team to decide", when, in fact, you'd prefer to decide, and don't flex your decision making power, it just shows how insecure you are at wielding it. If you are a manager asked to make a decision in a room with subordinates, try saying "These are well laid arguments. I will let the team decide." as much as possible, then side with the majority. And if you are the most senior member of the technical staff, never say "I am the Principal Engineer, therefore I decide" - everyone already knows it, and that just makes you look like a d*ck.

The decision maker should explain their reasoning, and document the decision. Once the choice is made, it becomes the team's direction. This requires trust in the decision maker's judgment and a commitment to respect their authority, even when the outcome differs from one's personal preference.

### Collectively commit to the outcome sought by the decision

Everyone, regardless of their initial position, must fully commit to implementing the chosen direction. This means actively working toward the success of the decision, not just grudgingly complying. You must be able to explain and advocate for the decision to others, as if it were your own choice. This collective commitment transforms a potentially divisive decision into a unified team effort, ensuring the organization moves forward together rather than being pulled apart by lingering disagreements.

If you disagreed with the option chosen, this is your time to earn trust and commit visibly. I've recently disagreed with a decision made by a Principal Engineer to remove an emergency status from a project that gave the team extraordinary authority to pull additional resources in. This was an easy "disagree and commit" for me. The reasons were clearly laid out and while I had my pros and cons for the option to keep the emergency status, those were no longer relevant after the decision was made. After the PE made the decision I wrote: _"This is an easy disagree and commit for me, because I do agree that the project had achieved its original goals, and understand that the emergency status may no longer needed because problems should be resolved business as usual"._ Since then, I have defended the decision like it was mine.
