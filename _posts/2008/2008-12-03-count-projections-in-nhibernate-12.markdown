---
layout: post
title: "Count projections in NHibernate 1.2"
redirect_from: "/count-projections-in-nhibernate-12/"
date: 2008-12-03 14:45:00
tags: [hibernate]
comments: true
dblog_post_id: 22
---
For someone who got stuck with NHibernate 1.1 it was actually surprisingly hard to find much about projections. Before you had to do different queries for a `COUNT` or a `SELECT` and you couldn't use `ICriteria`.

{% highlight c# %}
int count = (int) session.CreateQuery(string.Format(
 "SELECT COUNT(instance) FROM Login instance WHERE Role='{0}'",
 TransitLoginRole.Administrator.ToString()))
 .UniqueResult();
{% endhighlight %}

This is resolved with a projection.

{% highlight c# %}
int count = session.CreateCriteria(typeof(Login))
 .Add(Expression.Eq("Role", TransitLoginRole.Administrator.ToString()))
 .SetProjection(Projections.Count("Id"))
 .UniqueResult<int>();

IList<Login> logins = session.CreateCriteria(typeof(Login))
 .Add(Expression.Eq("Role", TransitLoginRole.Administrator.ToString()))
 .List<Login>();
{% endhighlight %}

Nice and easy.

