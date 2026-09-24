# Blog Voice

## Every Post Is Authored by dB

Every post on this blog is authored by dB, by hand. The opinions, stories, conclusions, and final words are his. He reads and edits every sentence before publishing it.

AI-generated posts are worthless by themselves. Do not publish a plausible collection of words merely because it is grammatically correct, well structured, or sounds vaguely like dB. A post must contain a real opinion, experience, discovery, failure, or result that he actually cares about.

AI is a tool for saving time:

- turn rough ideas and notes into an initial flow
- organize an argument without sanding off its edges
- find gaps, repetitions, and weak transitions
- produce the first pass of tedious technical examples
- reproduce examples across languages, tools, or frameworks
- check that commands and code are complete enough for a reader to use

Technical examples must actually work. Run the commands, execute the code, verify the output, and fix what the AI invented or misunderstood. Include links, commits, tests, screenshots, or other receipts when useful.

dB supplies the judgment, point of view, examples, edits, and final words. AI buys him time to make a post better; it does not author the post or make it worth reading.

Use the rest of this guide when helping draft or edit posts.

## Core Voice

dB writes as an experienced engineer-manager with strong opinions, concrete examples, and enough self-awareness to make the opinion feel earned rather than performative. The voice is direct, practical, slightly contrarian, and personal. It is comfortable saying "I", "we", and "you", and often turns an individual experience into a broader lesson for engineering, management, open source, or AI.

The writing should feel like a senior practitioner talking plainly after having debugged the same human or technical failure many times.

The voice is not "thought leadership". It is a working notebook with receipts: links, commands, pull requests, screenshots, commit history, numbers, failures, and the occasional joke made by someone who has earned the right to be blunt.

## Shape of a Post

Most posts follow one of these patterns.

1. Start with a concrete hook: a personal story, a recent event, an observed dysfunction, a question, or a small piece of data.
2. State the opinion early, sometimes as a `tl;dr`.
3. Explain the path to the conclusion with examples, numbers, commands, pull requests, anecdotes, or a failure.
4. Generalize into practical advice.
5. End with a short punchline, recommendation, joke, or personal aside rather than a formal summary.

Prefer headings that are simple and literal: `### Collecting Data`, `### The Manager Path`, `### Implementation`, `### Should You Do This?`. Use numbered lists when presenting a process, categories, or principles.

Common post shapes:

- **Provocation -> explanation -> practical rule.** Example: "Do Not Fix Bugs Reported in Your Open Source Projects" becomes a maintainer workflow.
- **Failure -> advice.** Example: failing a coding interview becomes advice for juniors, seniors, and AI-era interviewing.
- **Data collection -> imperfect conclusion.** Example: count meetings, pull requests, commits, or usage, acknowledge the data is messy, then say what it means.
- **Before/after baseline.** Compare a manual process to an AI-assisted process, or management to IC, with timestamps, counts, and a tradeoff.
- **Bug archaeology.** Walk from bug report to reproduction to root cause to fix, then compare the same trap across ecosystems.
- **Question-driven coaching.** Start with a question such as "What does a CTO do?" or "How do you grow leads?", then work toward one useful pattern.
- **Tiny useful note.** A short post can be just a command, link, surprising syntax, or small discovery with one paragraph of context and a quick reaction.
- **Pattern rules.** Use headings like "Manual Tasks Become Features", "Automated Tasks Become Business Logic with Tests", or "Friday Changes Become Monday Changes" to turn a behavior into a memorable rule.
- **Corporate change story.** Tell a multi-stage story with plain headings such as "The Mission", "Clarity", "Leverage", "Sunrise", "Sunset", and "Policy".

Titles can be blunt and specific. Prefer "Don't Tell Engineers What to Do" over "Empowering Engineering Teams", and "I Failed to Implement the Diameter of a Binary Tree in a Coding Interview" over "Lessons from Interviewing".

## Tone

- Be direct and opinionated, but not academic.
- Prefer "here is what I did and what I learned" over abstract advice.
- Use humor, dry sarcasm, and cultural references sparingly but confidently.
- Allow self-deprecation: admit obsession, mistakes, broken production features, burnout, confusion, and changed opinions.
- Make the reader feel the conclusion was earned through experience.
- Do not sand off sharp edges. A title or claim can be provocative if the body is practical and fair.

Good dB-style moves:

- "This is not about A.I., so let's get back to..."
- "I don't know how to conclude this post..."
- "YMMV."
- "You can do it!"
- "The data says..."
- "This is a joke, but..."
- "What a waste of time and energy!"
- "Honestly, wow."
- "Good luck with your interviews!"
- "If you start a CHANGELOG, tell me about it!"
- "Longtime readers know where this is going."
- "There is a real job and a life in between those timestamps."
- "By 'I', I mean GitHub Copilot CLI and I."
- "What the heck is this [] syntax?!"
- "Awesome."
- "Here's the same in a Gist for you to comment and improve."
- "I am not a patient person."
- "I love this concept."
- "This is normal, git is very powerful and can be very confusing."
- "If you understand why..., then you're a little bit like me."

## Point of View

Write from first-hand experience. dB often uses:

- personal career history
- specific teams, projects, tools, and organizations
- GitHub issues, pull requests, commits, and commands
- numbers collected from real systems
- 1:1 conversations and paraphrased quotes
- open-source maintainer experience
- manager and IC perspective in the same post
- older posts as source material for newer posts
- quotes from managers, engineers, interviewers, or users
- screenshots and small visual proofs when they make the story concrete
- classroom and mentoring situations as a reason to write a reusable post
- "I got asked this a lot" as a legitimate opening
- external articles or talks as a jumping-off point, followed quickly by the personal angle

Avoid generic thought leadership. If a sentence could appear in a corporate blog post without changing anything, rewrite it with a concrete example, a scar, a number, or a personal stake.

It is fine to name employers, projects, tools, and public organizations when they are essential to the story, but avoid turning the post into a press release. The point is what was learned.

## Arguments

dB makes arguments by combining opinion with evidence.

- Use data when possible, even if the data is imperfect.
- Show the command, query, or source used to get the data.
- Include the surprising or suspicious detail.
- Acknowledge the limitation, then still draw a useful conclusion.
- Balance strong statements with a practical caveat.
- Turn comparisons into concrete baselines: 3 weeks vs. 3 days, 20 commits vs. 15 commits, 2,882 meetings, 1,566 PRs, 87.95% coverage.
- When making a broad claim, immediately anchor it in something observable.

Example pattern:

```markdown
First, let's try to use data and find out whether ...

...

We can conclude that ...
```

For management posts, connect individual pain to organizational mechanics. For technical posts, connect implementation details to maintainability, automation, or developer experience.

For technical bug posts, use this pattern:

1. Introduce the library or system in one sentence.
2. Show the bug report or symptom.
3. Reproduce the failure with a small real example.
4. Explain why the old code looked reasonable.
5. Reveal the real-world edge case.
6. Show the fix.
7. Generalize the lesson beyond the immediate bug.

For tutorial posts, use this pattern:

1. Explain the situation in one paragraph.
2. State the goal in practical terms.
3. Walk through commands in order, with expected output.
4. Explain scary or destructive-looking steps before using them.
5. Name common errors and say that they are normal.
6. End with the underlying rule, not just the mechanical steps.

For short technical notes, do not pad. A post can be only a discovery, a command, and "Awesome." if that is all it needs.

## Language and Mechanics

- Use short, clear sentences mixed with occasional longer explanatory ones.
- Use contractions: "don't", "can't", "I've", "it's".
- Use complete sentences and punctuate them. Periods matter.
- Prefer plain verbs: build, fix, ask, write, read, ship, break, learn.
- Use "Engineer", "Engineering", "Manager", and "IC" as dB often does when referring to roles.
- Link generously to prior posts, GitHub issues, pull requests, commits, tools, and source material.
- Use inline code for commands, filenames, APIs, labels, and literal terms.
- Use code blocks for commands and outputs; show the actual workflow, not just the result.
- Prefer ASCII punctuation unless a post already needs a specific symbol.
- Use `tl;dr` when a post benefits from a direct upfront conclusion.
- Use italics for emphasis and quoted thoughts: _"why the hell am I here doing this to myself?"_.
- Use parenthetical asides naturally, including self-corrections and caveats.
- Let paragraphs be medium length. Do not chop everything into marketing-sized fragments.

Do not over-polish into a neutral brand voice. The blog should sound like one person with history, habits, and opinions.

Recurring diction:

- "This is not surprising because..."
- "It turns out..."
- "In my experience..."
- "The gist is..."
- "The common denominator..."
- "The real fix..."
- "This is a strictly more general version of..."
- "I am of the opinion that..."
- "Start by..."
- "Finally,..."
- "Turns out..."
- "Here's what..."
- "Let's examine..."
- "The cost of..."
- "The biggest issue was..."
- "No need to..."
- "You're all set."

## Humor and Color

Use vivid analogies and jokes when they clarify the point or reveal personality.

Examples of acceptable flavor:

- Soviet bureaucracy, Politburo, apparatchiks, or Siberia as management metaphors.
- Russian sayings or personal cultural references.
- "pointy-haired boss"
- "Copious Free Time(TM)"
- "where the bodies are being buried because I hold the shovel"
- "AI sh*t is wild"
- "deep inside the borg"
- "mother ship"
- "face-to-palm moments"
- "pouring hot pitch on a candidate's head"
- "nine pregnant women problem making one child"
- "align the ducks"
- "copious free time"
- "square zero"
- "mind gobbling amount of back-and-forth"

Do not force jokes into every paragraph. One memorable aside is better than constant cleverness.

Images can carry humor. Older posts often include a screenshot or image followed by a short quoted caption. Use this when the visual joke is part of the point, not as decoration.

## Technical Posts

Technical posts should be reproducible and grounded.

- Start with why the problem matters.
- Show the smallest working example.
- Include commands, code, URLs, outputs, screenshots, or links.
- Explain the key idea in plain language.
- Mention constraints, such as GitHub Pages not supporting custom plugins.
- End with the project, gem, pull request, commit, or practical next step.
- Show real command output when useful.
- Include diffs when the change is easier to understand than a prose description.
- Compare behavior before and after the fix.
- When exploring an ecosystem, test multiple languages or libraries and report the result plainly.
- Explain why an apparently reasonable implementation fails in a real edge case.
- If the post is a cross-language survey, keep each language section parallel: small intro, code, output or link.
- When posting a command-only trick, include just enough context to make it searchable later.
- Prefer exact tool names and versions when they matter, but do not turn a post into release notes unless that is the point.

The post should help a reader copy the approach, not just understand the concept.

## Tutorials and How-To Posts

Tutorials should feel like helping someone get unstuck at your desk.

- Assume the reader has already made a mess or is about to.
- Use branch names, prompts, command output, and exact recovery commands.
- Warn about losing work before using destructive commands.
- Normalize confusion: say when an error or messy state is expected.
- Teach the invariant behind the workflow, such as keeping `master` clean and doing work on feature branches.
- Finish with cleanup steps when appropriate.

Do not skip the boring operational parts. The boring parts are often why the post is useful.

## Management and Career Posts

Management posts should be human, specific, and unsentimental.

- Start from an observed dysfunction or personal career transition.
- Use concrete stories from 1:1s, team dynamics, hiring, RTO, status reporting, or open source.
- Name the tradeoff instead of pretending there is a universal answer.
- Give direct advice to managers and ICs.
- Tie advice back to outcomes: people growing, teams shipping, less bureaucracy, better systems.
- Separate authority from competence, and decisions from ownership.
- Treat managers as possible bottlenecks with broader context but less project detail.
- Prefer questions that help someone see the answer over telling them what to do.
- Say when a management behavior is harmful, dumb, or political, but explain the mechanism.

Avoid generic leadership language unless immediately grounded in behavior. "Align teams" is fine if followed by what to do on Monday.

## Open Source Posts

Open-source posts should treat being a maintainer as practical community building.

- Encourage contributors to do real work.
- Push responsibility to users where appropriate.
- Prefer "ask them to write a failing test" over "fix it yourself".
- Show examples from actual projects and issues.
- Make the maintainer incentive explicit.
- Start contributors with tiny, concrete actions: fix a typo, add a test, update a dependency, reproduce a bug.
- Frame open source as motivated by real need, not idealism alone.
- Make sustainability part of the advice.
- It is acceptable to say "I am not an idealist" and then explain the practical motivation.
- For corporate open-source stories, emphasize incentives, legal/IP concerns, written clarity, leverage, and policy.
- Include templates or policy excerpts when they help others copy the approach.

The tone can be blunt because the advice is rooted in sustaining healthy projects.

## AI Posts

AI posts should be pragmatic and experiential.

- Avoid hype for its own sake.
- Describe what was attempted, what worked, what broke, and what changed permanently.
- Treat AI as a tool that shifts bottlenecks to human attention, review, workflow, and judgment.
- Include specific tools and workflows.
- Be willing to say the change is irreversible when the experience supports it.
- Compare AI-assisted work to a prior manual baseline.
- Include failures that shipped, tests that missed them, and the production reality check.
- Emphasize that AI increases output, making senior judgment, review, and tests more important.
- Say "AI slop" when the point is plausible-looking but globally wrong output.

## Endings

Endings are usually short. Do not add a polished recap just because the post feels like it needs one.

Common endings:

- A direct recommendation: "Optimize for that."
- A personal invitation: "If you start a CHANGELOG, tell me about it!"
- A dry joke or aside: "Plus, we will soon all work for AI anyway, so might as well get on its good side."
- A practical next step or link.
- A final encouraging sentence: "You can do it!" or "Good luck with your interviews!"
- A callback to the opening story.
- A tiny emotional reaction: "Awesome."
- A request for comments, stories, or improvements when the post is exploratory.
- A final invariant after a long tutorial.

## Length and Depth

dB posts vary widely in length.

- A micro-post can be a command, a quote, or a link with a reaction.
- A medium post usually has one sharp idea and a few examples.
- A long post earns its length through story, data, code, policy, or a reusable walkthrough.

Do not expand a short idea into a long essay. Do not compress a hard-won tutorial into a clever summary.

## Things to Avoid

- Generic motivational endings.
- Sanitized corporate phrasing.
- Claims like "AI will transform everything" without a concrete workflow.
- Long literature-review introductions.
- Excessive hedging before making the point.
- Anonymous abstractions such as "organizations should leverage synergies".
- Perfectly balanced essays with no clear opinion.
- Introductions that define common terms before telling the story.
- Claims without receipts.
- Saying "we should consider" when the post means "do this".
- Hiding the author's mistakes.
- Ending with "In conclusion" unless the post is intentionally being plain or slightly funny about it.
- Padding a short post to make it look substantial.
- Removing the messy context that explains why the lesson mattered.
- Turning a reusable command or workflow into vague advice.

## Editing Checklist

Before publishing, ask:

1. Is there a concrete personal hook or data point?
2. Does the post say what dB actually thinks?
3. Are there examples, links, commands, issues, pull requests, or numbers?
4. Is there at least one memorable sentence or aside?
5. Are complete sentences punctuated consistently?
6. Could a corporate communications team have written this? If yes, make it more specific and personal.
7. Does the ending stop quickly instead of summarizing everything again?
8. If the post is technical, can a reader reproduce the important part?
9. If the post is managerial, does it name the behavior and the mechanism?
10. If the post is short, did it stay short?
11. If the post teaches a workflow, does it include cleanup and the invariant?
