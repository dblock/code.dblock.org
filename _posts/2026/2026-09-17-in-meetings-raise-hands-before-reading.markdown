---
layout: post
title: In Meetings, Raise Hands Before Reading
date: 2026-09-17
tags: [aws, management, people]
---

I spent five and a half years at AWS before moving (back) to Microsoft, where I work today. At Amazon, many meetings began with silent reading. Instead of presenting a document, the author gave everyone time to read it before the discussion started.

There was a small facilitation trick that made this work surprisingly well: when reading began, everyone raised a hand. When someone finished, they lowered it. The meeting started with all hands up and counted down to zero.

At Microsoft, I found the inverse practice: everyone began with their hands down and raised one when they finished. At the time of writing this, you'll find me hard at work changing the culture of raised hands at Microsoft, one meeting at a time. Raise your hand as you start reading, lower it when you are done.

Both approaches appear to communicate the same information. They do not. Counting down is better than counting up.

**TL;DR:**

* A raised hand shows who still needs time, which is the information the facilitator needs.
* Counting down ends unambiguously at zero without counting participants.
* A forgotten click makes the group wait instead of cutting off a reader.
* The facilitator can see progress and check in when only one reader remains.
* Reading ends with every hand down, so raising one can immediately mean "I want to speak."

But first, why read during the meeting at all? Jeff Bezos [explained the practice](https://www.cnbc.com/2018/04/23/what-jeff-bezos-learned-from-requiring-6-page-memos-at-amazon.html) at Amazon. I really like this as it forces one to prepare for the meeting, gets everyone on the same page, and offers some of the smartest but quietest people an opportunity to comment on their own pace.

Back to the hands.

At Amazon, a raised hand meant "I still need time." The signal described the state that mattered to the facilitator: these people were still reading. When the last hand went down, the group was ready. At Microsoft, a raised hand meant "I am done," which was less actionable. The facilitator did not need to know who was done. They needed to know who still needed time.

With hands up at the start, the meeting counts down. At zero, begin the conversation.

When hands go up as people finish, the facilitator must count them and compare that number with the expected number of readers. Was it ten people or eleven? Did someone join late? Did someone leave? Is a person without a raised hand still reading or not participating? Counting up requires knowing the denominator. Counting down only requires reaching zero.

People forget to click buttons. At Amazon, someone who forgot to lower their hand caused the group to wait a little longer. The facilitator could ask whether they were done.

At Microsoft, someone who forgot to raise their hand was indistinguishable from someone who was still reading. Worse, if the facilitator miscounted the expected readers, they might begin the discussion while someone was still trying to finish the document.

The Amazon model's failure mode was to give people more time. The Microsoft model could fail by cutting them off.

A decreasing number of hands makes the pace of the room obvious without interrupting the silence. If several hands are still up, the group needs more time. When one hand remains, the facilitator usually checks in with the last reader: "Do you need another minute?" The reader can ask for more time or say that they are ready, without polling the entire room.

This lets the facilitator adapt the reading period to the actual document and actual readers instead of guessing in advance or repeatedly asking, "How much more time do people need?"

At Amazon, people lowered their hands when done and moved on. The active signal belonged to the people who still needed something from the meeting: silence and time.

At Microsoft, finished readers accumulated raised hands and kept signaling a state that no longer required action. The display became increasingly busy while the useful information - who was still reading - remained represented by an absence.

The Amazon practice also created a clean transition from reading to discussion. By the time reading ended, every hand was down. Anyone could then raise a hand to signal that they wanted to speak.

The inverse practice left every finished reader's hand raised at exactly the moment the conversation began. Everyone first had to lower their hand before the same gesture could mean "I want to speak." If someone forgot, the facilitator could not tell whether it was a stale "I finished reading" signal or a new request to join the discussion. From the Systems Engineering perspective, good protocols reset their state before changing the meaning of a signal. Counting down naturally resets every hand to down, ready for the conversation.

**Start with every hand raised. Lower yours when you are done. Begin the conversation at zero.**
