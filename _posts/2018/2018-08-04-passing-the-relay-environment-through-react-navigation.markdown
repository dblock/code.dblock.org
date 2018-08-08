---
layout: post
title: "Passing The Relay Environment Through React Navigation"
date: "2018-08-04"
tags: [react native, 33 minutes]
---
Passing the [Relay environment](https://github.com/33-minutes/33-minutes-app/blob/master/app/Environment.js) around to make it available in each `QueryRenderer` with react-navigation seems unnecessarily difficult because of the difference between component props and screen props. I've successfully used [react-navigation-props-mapper](https://github.com/vonovak/react-navigation-props-mapper) to merge the two in [33-minutes-app](https://github.com/33-minutes/33-minutes-app).

### screenProps at App Level

{% highlight js %}
import React, { Component } from 'react';
import { createRootNavigator } from './app/Main';
import environment from './app/Environment';

export default class App extends Component {
  render() {
    const screenProps = {
      relay: {
        environment: environment
      }
    }

    const Layout = createRootNavigator();

    return (
      <Layout screenProps={ screenProps } />
    );
  }
}
{% endhighlight %}

### withMappedNavigationProps at Component Level

Using [react-navigation-props-mapper](https://github.com/vonovak/react-navigation-props-mapper) in each separate screen such as [Settings](https://github.com/33-minutes/33-minutes-app/blob/master/app/screens/Settings.js).

{% highlight js %}
import { withMappedNavigationProps } from 'react-navigation-props-mapper';

@withMappedNavigationProps()
class Settings extends React.Component {

  render() {
    return (
      <QueryRenderer
        environment={this.props.relay.environment}
        ...
      />
    )
  }
}
{% endhighlight %}

You no longer have to `import` the Relay environment all over the place.

{% highlight js %}
_signup() {
  const environment = this.props.relay.environment;
  CreateUserMutation.commit({
    environment,
    input: {

    }
  });
}
{% endhighlight %}
