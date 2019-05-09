---
layout: post
title: "Reflecting on 8 Years Building Artsy"
tags: [artsy, me me, jobs, organizations, people]
date: 2019-05-01
comments: true
---
Today I bid farewell to [Artsy](https://www.artsy.net). This post is my personal journey and my last post as CTO.

![]({{site.url}}/images/posts/2019/2019-05-01-reflecting-on-eight-years-building-artsy/2012-12-04-miami-basel.jpg)
<br><small>working at Art Basel Miami 2012, photo by <a href='https://www.zamiang.com/'>Brennan Moore</a></small>

> We have brought the art world online, built the [Art Market 1.0](/2019/03/07/art-market-one-point-o.html) and created the most read online art publication in the world.

### Getting Started

I was introduced to the Artsy founders Carter and Sebastian in late 2010. I remember getting a CD-ROM with artwork images from a Russian museum in the 90’s and finding it immediately valuable, so I easily connected with the mission of bringing the Art World online. At the time Artsy had already won a TechCrunch Rookie Disruptor award and were in their beginning stages of raising capital. The TechCrunch demo had visible technical difficulties, but despite these, the 23 y/o Artsy CEO, Carter Cleveland, pushed through that presentation with great success. I was impressed.

I officially [joined](/2011/03/01/artsy-change-the-world.html) Artsy as _Head of Engineering_ on March 1st, 2011. In hindsight, the job was a perfect fit for me. By then I had been an entrepreneur, managed fairly sizable Engineering teams, solved numerous technical challenges and have written a lot of code. I have also learned to be quite pragmatic about technology and was good at being resourceful and adaptable when it came to staffing, scoping and shipping.

Artsy had a CTO before me and one remote engineer. There were a couple new hires in New York, including a small Arts team. These were incredible humans and I looked up to them and immediately felt culture fit. Working amongst people who understood me as an artist was refreshing. They spoke many languages. Every week I would learn something mind-blowing about their life and work. I still think one of them was a former CIA agent! More importantly, they _truly loved and cared about art_.

The company took a couple of desks in the co-working space of General Assembly and, let me tell you, the energy there was contagious! They even had a weekly happy hour that would later be incorporated into an Artsy tradition.

![]({{site.url}}/images/posts/2019/2019-05-01-reflecting-on-eight-years-building-artsy/2011-06-01-artsy-team.jpg)
<br><small>Artsy team at General Assembly, June 2011, <a href="https://observer.com/2011/06/point-click-collect-art-sy-brings-the-art-world-online-again/">the Observer</a></small>

### Rebooting Tech

Artsy tech needed a full reboot. The existing website was built in PHP with a J2EE back-end running on JBoss and a MySQL database. It wasn’t working and looked like the large scale and expensive-looking Enterprise software that I was building prior to Artsy. Unfortunately, I had no idea how to build startup systems in 2011, but the New York startup ecosystem was uniquely collaborative and busy people were happy to give free advice. I organized a tour of Foursquare, MongoDB and a few other New York startup darlings, and asked their VPs and CTOs to help us pick a new programming language, a web framework and a database. The discussions with other startup leaders turned out to be so educational and fun! Visiting FourSquare was how we ended up with Ruby on Rails and MongoDB. I had barely heard of these technologies at the time and I was excited to crawl out from under my big Enterprise software rock.

### Collaborating

After seeing how much startup leaders  were willing to help us, I made a point to help newcomers in the New York startup community. In 2011 I taught a Ruby on Rails class, gave startup talks at General Assembly, and met every entrepreneur and Engineer in the coworking space. I created time for anyone who asked, while simultaneously coding and managing a rapidly expanding team. That investment would pay off tenfold.

I immediately got addicted to [Hacker News](https://news.ycombinator.com/). Don’t roll your eyes, because it became very important when it came to hiring and building an Engineering brand. The post [Dear California Engineer - Your Commute is Killing You? Move to New York!](/2011/05/29/dear-california-engineer-your-commute-is-killing-you-move-to-new-york.html) was the first one to go viral. This was quickly followed the very controversial [Github is your Resume](/2011/07/14/github-is-your-new-resume.html).

One of my early contributions to a nascent product function at Artsy was the introduction of [Domain Driven Design](https://opensource.com/life/11/1/intersection-core-values-open-source-and-domain-driven-design). It was merely one tool, but it helped break down the limitations of the early organization. The team began co-authoring a wiki of art-related nouns, which enabled Humans to connect with Engineers and made for a better domain model in code. We learned to speak the same language. It was the foundation of an exceptional collaboration between product and business that Artsy has exemplified for years. We had also introduced Github, Pivotal Tracker, Scrum, testing, continuous integration and deployment with Heroku and had our first Demo Days. I ended up running the first 52 sprints before we formalized a product organization. Much of that foundational work is detailed in a [presentation called 0-60 in Startup Tech](https://www.slideshare.net/dblockdotorg/hackyale-060-in-startup-tech) and truly stands out compared to the barely functioning software and systems of so many other startups.

I tried to be innovative in ways to develop software and established the Artsy open-source culture, early. I had [written about this on opensource.com](https://opensource.com/business/11/5/thinking-open-source-how-startups-destroy-culture-fear), which mentioned our first open-source project called [heroku-bartender](https://github.com/sarcilav/heroku-bartender). I wrote a lot of code myself, including parts of some complex components such as an API caching framework called [garner](https://github.com/artsy/garner) or a proxy to beat Heroku's 60s boot time limit called [heroku-forward](https://github.com/dblock/heroku-forward).

We hired an agency to build an iPhone app for collectors to use during Art Basel 2011. One could take a picture and Artsy would recognize it and provide more information, which was truly innovative at the time. We ultimately and successfully demoed the Artsy website at Fondation Beyeler in Switzerland. 2011 ended with an Engineering team of 8 and a handful of part timers or interns. The [Artsy Engineering Blog was born](https://artsy.github.io/blog/2012/01/05/hello-world) as we began showing what we built to the world. We delivered a website, a functional Art Genome Project, a basic CMS, rudimentary artwork inquiry process and a lot more. We [raised a Series A](https://techcrunch.com/2011/11/03/art-sy-6-million-thiel-thrive-murdoch-zhukova/).

I also appeared in [this unfortunate article in Business Insider](https://www.businessinsider.com/the-sexiest-programmers-alive-2011-5). Can you imagine an article entitled "The Sexiest Programmers Alive!" in 2019? Being [mentioned in Wired](https://www.wired.com/2011/11/mf-artsy/) was better.

It was the best year I’ve ever had professionally and I would feel that way for many years to come.

### Launching Art.sy

Artsy was private for the first 2 years and we issued a limited number of user invites on a case-by-case basis. The amount of inbound requests to get an invite grew exponentially throughout the year 2012. Artsy quickly became the hottest website one couldn’t get access to and people began literally begging for an invitation. I was very frustrated with our delayed launch, but in hindsight that was the right strategy.

Internally, we spent most of 2012 struggling with getting any sort of validation from our gallery partners around the quality of search results. We were truly innovating at the intersection of Art and Science, but we faced significant challenges. I remember one of our earliest and most important gallery partners looking at “related works” and exclaiming how terrible those results were on a weekly basis. The solution came from having cleaner and more consistent data, a purely human effort by the Art Genome team. That was the first time in my experience that I saw the true power of good data. I remain convinced that software is always a liability, while data is the true competitive advantage.

Artsy launched as _art.sy_ in October 2012 in partnership with just 50 art institutions and 275 galleries on top of [this tech stack](https://artsy.github.io/blog/2012/10/10/artsy-technology-stack). We knew that there was going to be a [New York Times article](https://www.nytimes.com/2012/10/09/arts/design/artsy-is-mapping-the-world-of-art-on-the-web.html), but we had no idea what kind of traffic to expect. We hit 1500 simultaneous users on the site instantly and everything worked well. [Thank you, Heroku and the AWS Cloud!](https://code.dblock.org/2012/10/13/the-tech-it-just-worked-thanks-aws.html)

### Finding Product/Market Fit

After failing to purchase artsy.com a few times, I bought artsy.net as a defensive move from an Artsy user. That was a lucky call, because on January 1st, 2013 our DNS records with the Syrian TLD have expired, and art.sy disappeared from the Internet. We were able to relaunch as [artsy.net](https://www.artsy.net/) in 24 hours and were never able to renew the art.sy domain because of U.S. sanctions imposed on Syria.

In September 2013 we shipped the Artsy iOS app that was quickly downloaded by 100,000 people and is now used by millions. The rest of 2013 and 2014 are best summarized in [2013.artsy.net](http://2013.artsy.net) and [2014.artsy.net](http://2014.artsy.net).

The Armory Show 2013 was the biggest transformational moment for Artsy. By then we became a real player in the online art space with a paid subscription service for Galleries and Institutions.

From a technology point of view, we were scared to move into online bidding. These events are _fight or flight_ and software _must work_. I [glued together some prototype code that could do bidding](https://artsy.github.io/blog/2014/04/17/building-an-english-auction-with-mongodb/), focusing on simplicity and resiliency. We continued innovating with bidding projection screens, enabled people to bid on their phones or place bids with team members on [bidding kiosks](https://github.com/artsy/eidolon). In November we executed our first non-profit auction with Independent Curators International. We'd move into Live auctions later and in 2018 Artsy operated 400 auctions.

The fact that a customer was willing to give Artsy actual money was one enormous milestone. A total of $101MM of investor cash enabled us to innovate and grow the business further. Fast forwarding to 3100 galleries paying Artsy over a million dollars every month and to millions of dollars of art transacting via the platform today is nothing short of spectacular. Artsy has found its product/market fit!

### Hiring and Writing Open Source

Software doesn’t exist without humans making it. Hiring and growing a world class Engineering team was my responsibility for the last 8 years. This team is now 35 and is truly exceptional. I cannot thank enough every Artsy team member. Hiring these people was not easy. Artsy was able to attract some of the best Engineers squarely because of its value-based culture and exceptional Engineering brand, built on top of its open-source work. We were able to *lead* and not *follow* with a very small team. Artsy Engineers [made and continue co-maintaining CocoaPods](https://en.wikipedia.org/wiki/CocoaPods), were the first to bring truly [isomorphic JavaScript](https://artsy.github.io/blog/2013/11/30/rendering-on-the-server-and-client-in-node-dot-js) to production, became big in [React Native](https://artsy.github.io/blog/2019/03/17/three-years-of-react-native) and, more recently, [TypeScript](https://artsy.github.io/blog/2019/04/05/omakase-typescript). The [open-source by default nature of this team](https://code.dblock.org/2015/02/09/becoming-open-source-by-default.html) continues to be smart business, but also sets the Artsy technology team brand apart in a meaningful way. Much of this work is detailed in [an epic post on the Artsy Engineering blog](https://artsy.github.io/blog/2019/04/29/how-did-artsy-become-oss-by-default/).

I focused a lot of my own energy on building the team, layer by layer, and establishing a scalable culture that would eventually not need my presence. I [gave away all my legos](https://code.dblock.org/2015/11/25/zooming-out-to-give-away-your-legos.html), relentlessly. It's amazing to be able to see this continue making progress in [artsy/README](https://github.com/artsy/README) with [new leadership](http://www.artnews.com/2019/04/02/samuel-rozenberg-artsy).

When it came to code, I started contributing and eventually became the co-maintainer of [ruby-grape](https://github.com/ruby-grape) in 2011, one of the most actively used Ruby projects today. I ended up organizing the [mongoid](https://github.com/mongoid) org on Github and writing many related gems. I built much of [slack-ruby](https://github.com/slack-ruby) and was very active in [alexa-js](https://github.com/alexa-js). I made the wildly popular [Jenkins AnsiColor plugin](https://code.dblock.org/2011/09/07/implementing-my-first-jenkins-plugin-ansicolor.html), had my hands in [Java Native Access](https://github.com/java-native-access/jna) and dozens of other popular libraries.

Internally at Artsy, Live Auctions Integration in 2016 was the first big effort that I have not written code for as my role [evolved from Head of Engineering to CTO](/2015/05/07/what-is-the-difference-between-cto-and-vp-or-head-of-engineering.html). I was now spending a lot of energy on strategy and communication. And while I was still doing a lot of open-source, I have never gotten over missing coding larger systems or frequently reaching the kind of meditative, uninterrupted flow that I loved so much.

My next career move will reflect that.

### Building a Technology Company

Artsy today is a true technology company operated by 220 individuals. Product, Design, Data and Engineering functions are not cost centers but opportunities to win business and grow. While we uniquely leverage the forces of gravity in the art world as it moves online, true scale comes from more machines operated by intelligent humans. I am convinced that we will see much more of that scale over the next couple of years with exponential growth in e-commerce and by focusing on transforming Artsy into a more significant platform for the art world. I am excited for the future of Artsy and the magnificent team who will continue on to represent a groundbreaking culture. I cannot be more proud of what I am leaving the team with.

Finally, leveraging software to win over partners and collectors is always a significant challenge and Artsy meets that challenge every day. As a company and brand we always strive for exceptional customer service and customer obsession has been a pillar of this organization from the early days of convincing museums and institutions to lend their brand to Artsy, uploading thousands of works, selling subscriptions, building strong and long lasting relations with gallery partners and celebrating wins with bidders and e-commerce buyers. Artsy is creating a world with more art and more galleries, a world where more artists can make a living because of us.

### Reading about Art

Beyond technology, it was a privilege to see Artsy Editorial grow alongside the tech. Artsy’s publication is truly special to me. Whereas art commerce is necessary for the survival of this business, Artsy Editorial speaks to me on a personal and significant level. My grandfather was a Soviet writer and my father, a poetry translator. Writing is rooted deeply in the heart of my family’s history and I have been immersed in books for many years before playing with computers. In the end, what puts Artsy on the right side of history is the deep investment in the art and the artists who make it. I am looking forward to continuing to read [Artsy Editorial](https://www.artsy.net/articles) which inspires my family and I every day.

### Thank You

I cannot thank each and every Artsy team member enough for giving me the life changing opportunity to be *their* CTO for over the last 8 years. I owe many thanks to Carter Cleveland (CEO), Sebastian Cwilich (COO), the Board, Artsy investors and the Leadership team for giving me the Artsy platform to work alongside with them in building an extraordinary company. Artsy has changed my life and the professional I am. I am forever grateful.

![]({{site.url}}/images/posts/2019/2019-05-01-reflecting-on-eight-years-building-artsy/2018-05-10-artsy-with-jerry-saltz.jpg)
<br><small>Artsy leadership team at David Zwirner Gallery, May 2018, w/Jerry Saltz</small>

