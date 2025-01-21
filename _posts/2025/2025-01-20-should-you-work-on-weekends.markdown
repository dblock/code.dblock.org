---
layout: post
title: Should You Work on Weekends?
date: 2025-01-20 01:00:00
tags: [open source, people, work]
comments: true
---
Should you work on week-ends?

_tl;dr Only 2% of my paid work was accomplished on weekends, which matches my opinion that you should not._

### Collecting Data

First, let's try to use data and find out whether I actually work on week-ends. I've contributed to the open-source OpenSearch since 2021 as part of my day job, so I tried looking through my GitHub commits, but had hard time excluding forks. I settled on fetching pull requests. The following query collects my PRs for the first two weeks of 2025.

```bash
{% raw %}
gh search prs \
  --author "@me" \
  --created "2025-01-01..2025-01-20" \
  --json repository,number,title,createdAt \
  --template '{{range .}}{{tablerow
    (timefmt "Monday" .createdAt)
    .repository.nameWithOwner 
    (printf "#%v" .number) 
    (truncate 20 .title)
    (timeago .createdAt)
    }}{{end}}'
{% endraw %}
```

```
Sunday     dblock/discord-strava                            #32   Lock setup-firefox.   1 day ago
Friday     dblock/discord-strava                            #30   Upgrade Firefox i...  3 days ago
Tuesday    opensearch-project/opensearch-api-specification  #793  Warn if file path...  6 days ago
Friday     opensearch-project/opensearch-php                #253  Added optional he...  10 days ago
Thursday   opensearch-project/opensearch-php                #249  Adding @kimpepper...  12 days ago
Wednesday  dblock/code.dblock.org                           #139  Meeting Open Sour...  12 days ago
Wednesday  opensearch-project/opensearch-php                #247  Fix up UPGRADING.md.  12 days ago
Tuesday    opensearch-project/opensearch-api-specification  #772  Evaluate payload ...  13 days ago
Monday     opensearch-project/opensearch-api-specification  #768  Fix flaky snapsho...  14 days ago
Monday     opensearch-project/opensearch-api-specification  #767  Upload test spec ...  15 days ago
Wednesday  dblock/code.dblock.org                           #137  Only vale modifie...  19 days ago
```

Repeating this pattern using different date ranges and a larger `--limit` I found 1,566 PRs, including 1,264 PRs into the opensearch-project GitHub organization since April 2021, the time of the OpenSearch fork. Excluding PRs made on Saturday and Sunday I got 1,234. It's a suspicious number (1, 2, 3, 4, really?), but it checks out. The data says that I made 30 PRs on week-ends for work, and 225 PRs not for work. Finally, these exclude the many commits I made into my pet projects directly to `main`.

We can conclude that only 2% of my paid work was accomplished on weekends.

### Which Day is More Productive?

Here's the distribution of PRs into opensearch-project (aka work) by day of week.

| Day       | Count |
|-----------|-------|
| Monday    | 221   |
| Tuesday   | 331   |
| Wednesday | 193   |
| Thursday  | 321   |
| Friday    | 168   |
| Saturday  | 17    |
| Sunday    | 13    |

It looks like Tuesdays and Thursdays are the busiest with fewer results on Friday, which is consistent with my opinion about the benefits of _finishing earlier or doing other types of work than code on Fridays_. Work is not just pull requests, it's also attending meetings, and I [participated in 2882 meetings in 5 years](/2024/12/20/i-participated-in-2882-meetings-in-5-years.html).

### Should You Work on Weekends?

In my opinion, an experienced Engineer or a People Manager working on weekends shows a bad example. It sets an unreasonable expectation that everyone must be available 7 days a week for productive work, reduces the overall velocity of a team by wearing people out, and diminishes the quality of the code we collectively produce. Us, humans, need to be able to step back away from the machine to recharge, and we need time to think, therefore working harder or more hours is usually not correlated with better results.

### What About Looming Deadlines?

Over the years I observed that developers that bang out code on a Sunday tend to bang out a lot less code on Monday. Those on-call on weekends are exhausted the entire week. Individuals that can't find time to focus on code during the work week tend to compensate by coding on weekends, which demonstrates that they are unproductive during the week - a net negative. Having to work on a weekend to meet a deadline is usually a failure of planning. There are certainly exceptions, but they should be exceedingly rare.

### What About Pet Projects and Open-Source?

Pet projects and open-source contributions outside of paid work are a wonderful source of independence and dopamine, I have [several](https://www.vestris.com/). I like doing that type of work on weekends, but only for a small amount of hours, and never feeling that it takes away from my main week-end activities that include spending time with family or friends. I think this attitude evolved over the years as I used to spend a lot of time coding on week-ends, but I believe I have consistently tried to make sure that was not paid work that I _had to do_. Finally, I am lucky to be paid to do open-source work, but I absolutely consider that _work_ and avoid doing it outside of work hours.

### Creating Discipline

Not working on weekends and not burning out requires discipline. If you find it difficult to detach yourself from the computer on weekends, begin your Saturday and Sunday with the hardest thing to do. For me, this meant forcing myself to open a book before my laptop, or putting my shoes on and going for a long run, first thing in the morning.

You can do it!
