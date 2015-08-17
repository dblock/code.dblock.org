---
layout: post
title: "Becoming Open Source by Default"
date: 2015-02-09
tags: [teams, people, open-source]
comments: true
pinned: true
---
tl;dr Watch [this video instead](https://vimeo.com/136554627)!

In 2004, fresh out of Microsoft, I began contributing to my [first public open-source project](https://github.com/dblock/dotnetinstaller). I've since helped [transform several corporate cultures from users to contributors](http://opensource.com/life/10/12/corporate-change-contributing-open-source) and have made open-source work a core tenet of the [Artsy](https://www.artsy.net/) development process with [open-source projects](http://artsy.github.io/open-source) that range from small libraries to entire applications. Finally, I've been maintaining several popular open-source libraries myself, including [Grape](https://github.com/ruby-grape/grape), [Hashie](https://github.com/intridea/hashie) or [JNA](https://github.com/twall/jna) with the help of thousands of companies and individuals around the world. I frequently [speak about the value of open-source](http://confreaks.com/videos/4166-gogaruco2014-taking-over-someone-else-s-open-source-projects) and the hard work involved.

I am very proud of my open-source contributions and would like to take it one step further by outlining my thinking around me, personally, _becoming open-source by default_.

<!-- more -->

First, I recognize that becoming open-source by default is emotionally, organizationally and, sometimes, technically hard. As such, this post is not a manifesto, it’s a step in the right direction that will guide my career and technology choices in the future. To quote Scott Berkun’s [A Year Without Pants](http://scottberkun.com/yearwithoutpants): _attributes of culture don’t arrive by some technique sprinkled around the company years after it started_. This applies to organizations and individuals alike - I didn't start my Engineering career with open-source, but my thinking has evolved, naturally, to a point where I was enthusiastic about it, and then to a place where I was doing it every day.

Nobody ever told me that I must write open-source software. I have written and continue to write mountains of closed-source code and create more closed-source projects every day. However, as many engineers, I am motivated to create smaller, nimbler, reusable and well-tested components. Well designed libraries reduce the size of any application and help keep code dry. Well documented systems are easier to use by new team members. Well tested ones are faster to add features to and don’t break as often. By default, I contribute to other people’s generic open-source solutions to save time and money by not reinventing the wheel. Taking this further, I spend significant amount of time extracting non-domain-specific code into new or existing open-source libraries, reducing the footprint of the proprietary applications I work on.

When starting a new service, library or application I am going to default to open. I am going to weigh whether there's any advantage of keeping a project closed-source, knowing and presuming that there’re numerous disadvantages. For my day-to-day paid work I am going to decide whether to open code in my name (under [my own Github account](https://github.com/dblock)) or under my employer's name (under the [Artsy Github account](https://github.com/artsy) today). Generally I feel responsible for my code, but often I can't rightfully assume ownership and will ask the Engineering team to stand behind a new company open-source project and commit resources to work on it as an organization.

For personal projects I get to choose what to open-source and what not to open-source. For company projects I'd like to eventually get to a place where we have enough trust in individual contributors not to require to seek permission from their manager or the company to create new open-source projects. I'd like to ideally remove any clearance or process.

I am going to default to the MIT License for all new projects, because it’s short and clear and protects everyone and to avoid frustrating discussions, such as [this one on the Jenkins mailing list](https://groups.google.com/forum/#!msg/jenkinsci-dev/ywCwlY569dI/J351N6JjXagJ) about one's inability to extend code under the EPL license and re-licensing it as MIT.

In general, I love and support community involvement in any of my projects because it encourages continuous and broad peer review by individuals smarter than me. This helps ensure better reliability and security of software, and also creates opportunities for me to interact with exceptional individuals from some of the best software teams around the world. I am naturally happy to see any such collaborations become well-known in technology circles and love speaking at technical conferences about technology and teams, with less slides and more open-source code in-hand.

Open-source by default is a no-brainer, personally, but it also makes perfect business sense.

Despite overwhelming evidence, many non-technical people are worried about risks surrounding open-source. I am convinced that any business success depends a lot more on your ability to serve customers and partners, the brand and culture and the commitment to hiring the best of the best in all fields, than on the hypothetical risks that a competitor might gain by taking advantage of your open-source software. Open-sourcing core intellectual property can seriously upset competitors, as long as you have proprietary value that you are monetizing. I have yet to see a company run away with someone else's open source project and build a better business - usually the one who open sources the technology is the expert in that area, so it's hard to out-execute them.

I am also convinced that defaulting to open-source creates more value by contributing to your team culture, values and your ability to hire, than the additional risks. I am clearly stating that open is a _better way of developing software_ and that there’s more social capital, technical reputation and overall value in giving away your best stuff than keeping it proprietary.

To conclude, I hope you join me someday, and begin your journey towards being open-source by default.
