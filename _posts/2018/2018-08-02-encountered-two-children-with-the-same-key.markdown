---
layout: post
title: "Warning: Encountered two children with same key"
date: "2018-08-02"
tags: [react native, 33 minutes]
---
This drove me crazy.

In the [previous post](/2018/08/01/wiring-up-a-react-native-client-to-a-rails-graphql-server.html) I wired up a React Native client app to a GraphQL Rails server. My app records meeting duration, so I added the server-side models in [33-minutes-server@838200](https://github.com/33-minutes/33-minutes-server/commit/8382006996c82eb267f25854739487f2e26bedc3) and client-side mutations in [33-minutes-app@b79e65](https://github.com/33-minutes/33-minutes-app/commit/b79e65ea0bb7bc1f6f3974004069a01588a7928d) and [33-minutes-app@f253e4](https://github.com/33-minutes/33-minutes-app/commit/f253e488b754f77df9ff050b7bd56ef7ed92a3b3).

When creating a second item I would encounter the following error: _Encountered two children with the same key, &lt;id&gt;. Child keys must be unique; when two children share a key, only the first child will be used._ This was odd, because I knew all IDs were unique. Turns out, this is a Relay bug, with a proposed fix in [relay#2349](https://github.com/facebook/relay/pull/2349) that is yet to be merged. This is fairly basic and is a good demonstration of how <strike>immature</strike> cutting edge this ecosystem is.

You can work around this by supplying a unique ID into each GraphQL mutation, which is an optional field [in the Relay spec](https://facebook.github.io/relay/graphql/mutations.htm).

{% highlight js %}
import { graphql } from 'react-relay'
import commitMutation from 'relay-commit-mutation-promise'
import uuid from 'uuid/v4';

const mutation = graphql`
  mutation LoginMutation($input: loginInput!) {
    login(input: $input) {
      clientMutationId,
      user {
        id
      }
    }
  }
`

function commit({ environment, input }) {
  const variables = {
    input: {
      clientMutationId: uuid(),
      ...input
    }
  }

  return commitMutation(environment, {
    mutation,
    variables
  })
}

export default {
  commit
}
{% endhighlight %}

In my app this change is [33-minutes-app@bf4a89](https://github.com/33-minutes/33-minutes-app/commit/bf4a89d2a53d2404a7a341bd8660f7873e8a2029).
