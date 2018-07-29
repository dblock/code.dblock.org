---
layout: post
title: "A Toggle Button in React Native"
date: "2018-07-29 2:30"
tags: [react native, 33 minutes]
---
In the [previous post](/2018/07/29/react-native-hello-world.html) I've setup a "Hello World" React Native app. I'll now add a button that toggles some text.

<a href='{{site.url}}/images/posts/2018/2018-07-29-react-native-toggle-button/start-stop-meeting.gif'><img src='{{site.url}}/images/posts/2018/2018-07-29-react-native-toggle-button/start-stop-meeting.gif' class="thumbnail"></a>

The button itself is changes title depending on whether a meeting has started or not. The initial state of a meeting will default to `false`.

{% highlight jsx %}
export default class App extends React.Component {
  state = {
    isMeetingStarted: false
  }

  render() {
    return (
      <View style={styles.container}>
        <Button title={ this.state.isMeetingStarted ? 'Stop Meeting' : 'Start Meeting' } />
      </View>
    )
  }
}
{% endhighlight %}

State is a core concept in React Native: every time state changes, all components affected by state will re-render. We will toggle the state of `isMeetingStarted` in JavaScript.

{% highlight jsx %}
toggleMeeting() {
  this.setState({
    isMeetingStarted: !this.state.isMeetingStarted
  })
}
{% endhighlight %}

{% highlight jsx %}
<Button onPress={() => this.toggleMeeting()} ... />
{% endhighlight %}

### Code, Tests and Travis CI

The above code is [33-minutes-app@599fd1](https://github.com/33-minutes/33-minutes-app/commit/599fd191ff4e2fef4a9aa5e728d172dcd5290420). I've also setup Travis-CI in [33-minutes-app@7445d1](https://github.com/33-minutes/33-minutes-app/commit/7445d1fa2f1dff57543b9d099ff484d10941f7f8) and have written some tests with [Jest](https://jestjs.io) in [33-minutes-app@b05d45](https://github.com/33-minutes/33-minutes-app/commit/b05d45de4f6d42f8b89148649c81bb6af37d7e9b). Tests work by taking a snapshot of the DOM and comparing the results before and after the button is pressed.
