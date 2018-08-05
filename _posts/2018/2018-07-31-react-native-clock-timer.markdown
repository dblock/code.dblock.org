---
layout: post
title: "Implementing a Ticking Clock Timer in React Native"
date: "2018-07-31"
tags: [react native, 33 minutes]
---
In the [previous post](/2018/07/30/add-remove-list-items-react-native.html) I added and removed list items. In this post I will implement a ticking timer.

<a href='{{site.url}}/images/posts/2018/2018-07-31-react-native-clock-timer/timer.gif'><img src='{{site.url}}/images/posts/2018/2018-07-31-react-native-clock-timer/timer.gif' class="thumbnail"></a>

The React Native ecosystem promises a rich set of components that work seamlessly together, much like the Ruby world. My first timer implementation used [react-timer-machine](https://github.com/yassinedoghri/react-timer-machine), _a fully controllable and customizable timer component_.

{% highlight shell %}
$ yarn add react-timer-machine
{% endhighlight %}

{% highlight jsx %}
import TimerMachine from 'react-timer-machine'
{% endhighlight %}

Time duration math is implemented by combining [moment.js](https://momentjs.com) and [moment-duration-format](https://github.com/jsmreese/moment-duration-format).

{% highlight jsx %}
import moment from "moment";
import momentDurationFormatSetup from "moment-duration-format";
momentDurationFormatSetup(moment);
{% endhighlight %}

The timer itself will start as soon as the `isMeetingStarted` state is toggled.

{% highlight jsx %}
<TimerMachine
  timeStart={1000}
  started={this.state.isMeetingStarted}
  countdown={false}
  interval={1000}
  formatTimer={(time, ms) =>
    moment.duration(ms, "milliseconds").format("h [hours], m [minutes], s [seconds]")
  }
/>
{% endhighlight %}

It works, except when it doesn't. Expo doesn't support background tasks and so the [timer pauses when the app is backgrounded](https://github.com/yassinedoghri/react-timer-machine/issues/7). A simple [workaround](https://github.com/33-minutes/33-minutes-app/commit/2a5212f205d291d506de7effaabfdd8d221a762e) is to keep track of start and end time, but we might as well get rid of the timer altogether.

We can rely on `setInterval` to call a method every second in the foreground and update the elapsed time by subtracting two timestamps. I find simulating a timer in this manner pretty neat, as it takes full advantage of React re-rendering components when state changes. It obviously wouldn't be suitable for performing an action based on elapsed time since no events fire in the background.

{% highlight jsx %}
this.setState({ elapsedTime: moment().diff(this.state.meetingStartedAt) })
{% endhighlight %}

You can see this code in [33-minutes-app@0f1df4](https://github.com/33-minutes/33-minutes-app/commit/0f1df4c1c8036934874973480d7bf5ac37d86aa2).

