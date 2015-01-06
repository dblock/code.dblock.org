---
layout: post
title: "10 Things Engineers and Non-Engineers Can Do to Make a Website Faster"
redirect_from: "/10-things-engineers-and-non-engineers-can-do-to-make-a-website-faster/"
date: 2012-12-23 18:57:38
tags: [teams, startups, performance, technology, people, agile]
comments: true
---
![]({{ site.url }}/images/posts/2012/2012-12-23-10-things-engineers-and-non-engineers-can-do-to-make-a-website-faster/image_3.jpg)

> An investor, a startup CEO, and an engineer walk into a bar to discuss [Page Weight Matters](http://blog.chriszacharias.com/page-weight-matters). They naturally end up talking about their own slow website.
>
> The CEO’s friend works in finance. She invested a bit of cash in her friend’s startup. She came home late, made herself dinner and read her personal email (her bank won’t let her do that at work). The website’s newsletter had something interesting, so she clicked. She stared at a white page for a bit, then it finally loaded after 8 seconds. She was already bored and figured it’s not worth it. "Something’s wrong with my internet", she thought. Google came up instantly, though, so she emailed her CEO friend.
>
> This morning the CEO had to make the difficult decision to invest into a new kind of reticulated spline, the 3-dimensional kind. After looking at the data gathered for the past two weeks by the early prototypes of the 2-dimensional spline, it became clear that users want that other, much more esoteric, 3rd dimension. Tomorrow he’ll gather the team to show them the user data. Also, a friend and early investor emailed him that his website was slow. Going to the website right now on his iPad confirms that, indeed, that 2D spline page takes 4 seconds to show up. Trying again was fast, though. Weird.
>
> The engineer was watching an API response graph that oscillated abnormally with 4 seconds peaks fetching the 2D spline when he received the investor’s email forwarded by the CEO. A large code refactor that enables a much faster 2D spline page rendering finally had a successful build and was now ready to be merged onto the master branch, pending code review. He replied to the CEO’s email with the good news of progress being made before leaving the office.
>
> They all meet at [Tom & Jerry’s](http://www.yelp.com/biz/tom-and-jerrys-new-york). Where else?

If you can find yourself in my story, you’re in a good place. You have the CEO doing his job having visions of the future based on the experiences of the past. You have engaged users that want you to succeed and are willing to provide feedback. You have engineers doing their job building new features as fast as they can and fixing issues, including performance, as they are found incrementally. You are in a bar in New York with cheap drinks.

Generally, though, the website is slow, and that’s a problem. What should you do?

The answer, in my opinion, lies in a basic equation. You can focus on performance, but your features won’t move forward. Build more features, and performance will suffer. To have both takes much more time. You want to find the right balance. Here’re 5 ideas for engineers and non-engineers for improving website performance.

For engineers:

1. Observe humans using your product and don’t make excuses, your system is slow until it’s not.
2. Optimize for simplicity, complex software is very hard to optimize for performance.
3. Measure your slowest components. As an individual contributor, address one a week.
4. Discuss alternate solutions to experiences that will perform poorly with the product and design team.
5. Regularly undertake large projects that address fundamental bottlenecks by your own initiative.

For non-engineers:

1. Learn about the engineering process and technical debt.
2. Avoid asking "When is it going to be done?". Organize features in a backlog rather than milestones with deadlines.
3. Be helpful, but don’t try to suggest technical or external solutions to performance problems, such as experts or consultants.
4. Give improvements time and assume that a good engineering team knows what they are doing.
5. Be constructive when reporting slow parts of the system and avoid broad "it’s too slow" statements.

