---
layout: post
title: "Adding and Removing List Items in React Native"
date: "2018-07-30"
tags: [react native, 33 minutes]
---
In the [previous post](/2018/07/29/react-native-toggle-button.html) I added a React Native toggle button. In this post I will add and remove list items.

<a href='{{site.url}}/images/posts/2018/2018-07-30-add-remove-list-items-react-native/add-remove-list-items.gif'><img src='{{site.url}}/images/posts/2018/2018-07-30-add-remove-list-items-react-native/add-remove-list-items.gif' class="thumbnail"></a>

We're going to be storing an array of meetings, adding to it and removing from it.

First, we extract a meeting into a specialized class.

```jsx
export default class Meeting extends React.Component {
  render() {
    return (
      <View style={styles.meeting}>
        <Text style={styles.meetingText}>{this.props.val.startDateTime.toString()}</Text>
      </View>
    );
  }
}
```

The first thing to notice is the usage of `props`. These are passed into the `Meeting` component at creation time via a `constructor(props)`. It's possible to declare required props for a component using `propTypes`.

```jsx
import PropTypes from 'prop-types';
```

```jsx
Meeting.propTypes = {
  val: PropTypes.object
}
```

The parent component renders a list of meetings inside a scrollable view.

```jsx
export default class Main extends React.Component {
  state = {
    meetings: []
  }

  render() {
    let meetings = this.state.meetings.map((val, key) => {
      return <Meeting key={key} val={val} />
    })

    return (
      <View>
        <ScrollView>
          { meetings }
        </ScrollView>
      </View>
    )
  }
}
```

### Adding Meetings

A meeting has a start and an end date, so we will also need to remember when a meeting started.

```jsx
state = {
  meetingStartedAt: null
}
```

A meeting is pushed into the `meetings` array when it ends.

```jsx
endMeeting() {
  this.state.meetings.push({
    startDateTime: this.state.meetingStartedAt
  })

  this.setState({
    meetingStartedAt: null,
    meetings: this.state.meetings
  })
}
```

A meeting can be removed from the `meetings` array by key.

```jsx
removeMeetingByKey(key) {
  this.state.meetings.splice(key, 1)
  this.setState({ meetings: this.state.meetings })
}
```

See the complete code with additional and removal wired up is in [33-minutes-app@249dd0](https://github.com/33-minutes/33-minutes-app/commit/249dd0096a444f4d7fb88c992988156ecc0d7165). In the [next post I will add a meeting clock timer](/2018/07/31/react-native-clock-timer.html).
