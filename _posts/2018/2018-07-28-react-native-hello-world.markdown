---
layout: post
title: "React Native Hello World"
date: "2018-07-28"
tags: [react native, 33 minutes]
---
I've made [too many Slack bots](/tags/slack/) since 2015, so I decided to try something new and less comfortable. If you've written many services and back-ends as I have, you may have developed the same mental block as I when it came to client-side or front-end code. Since Artsy had been doing [amazing things with React Native](http://artsy.github.io/series/react-native-at-artsy) for a while, I committed myself to writing a mobile app in React Native, from scratch.

My pet project is called *33 Minutes*, and it's a "Strava for meetings", starting with a basic weekly meeting budget tracker.

### Getting Started with React Native?

I was told to use [Expo](https://expo.io) and to bootstrap the project with [create react native app](https://github.com/react-community/create-react-native-app). Expo is a _free and open source toolchain built around React Native to help you build native iOS and Android projects using JavaScript and React_.

{% highlight shell %}
$ npm i -g create-react-native-app
{% endhighlight %}

Running `create-react-native-app` results with a bunch of code in a new folder. You can `npm install -g yarn`, `yarn install` and `yarn start` from the generated folder. Launch an iOS simulator with `i` and voila, a "Hello World", 230MB, app.

### Visual Studio Code

If you've never used [Visual Studio Code](https://code.visualstudio.com), this is a good time to switch to it.

### Hello World Code

The interesting part is in `App.js`.

{% highlight jsx %}
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

export default class App extends React.Component {
  render() {
    return (
      <View style={styles.container}>
        <Text>33 Minutes</Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center'
  }
});
{% endhighlight %}

This seems bizarre. It's neither JavaScript, nor HTML. It is called [JSX](https://reactjs.org/docs/introducing-jsx.html), and it is a syntax extension to JavaScript where UI components live next to JavaScript code, next to the component style. The above _component_ has a `render` method that is called every time the component state changes and it returns a view with some text.

### Code

The code from this post is [33-minutes-app#f2bf31](https://github.com/33-minutes/33-minutes-app/commit/f2bf315ca8423d459ffb15abd9365c908cc40864). In the [next post I will add a toggle button](/2018/07/29/react-native-toggle-button.html).

