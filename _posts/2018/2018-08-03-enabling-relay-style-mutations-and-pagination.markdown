---
layout: post
title: "Enabling Relay-Style Mutations and Pagination"
date: "2018-08-03"
tags: [react native, 33 minutes, relay]
---
In the [previous post](/2018/08/01/wiring-up-a-react-native-client-to-a-rails-graphql-server.html) I wired up a React Native client to a Rails API GraphQL server. In this post I'll enable adding, removing and retrieving paginated data.

### Data Models

The root of all my GraphQL queries are now a `user` and a user has a number of `meetings`. A user can sign-up, then meetings can be created or destroyed via mutations. See [33-minutes-server@838200](https://github.com/33-minutes/33-minutes-server/commit/8382006996c82eb267f25854739487f2e26bedc3) for implementation details.

### Relay-Style Mutations

Relay has a [specified](https://relay.dev/docs/guided-tour/updating-data/graphql-mutations/) add/remove behavior via `RANGE_ADD` and `NODE_DELETE`.

#### RANGE_ADD

To enable this on the server, return the range connection and edge from the mutation.

{% highlight ruby %}
Mutations::CreateMeetingMutation = GraphQL::Relay::Mutation.define do
  name 'createMeeting'

  input_field :title, types.String
  input_field :started, !Types::DateTimeType
  input_field :finished, !Types::DateTimeType

  return_field :meeting, Types::MeetingType
  return_field :meetingsConnection, Types::MeetingType.connection_type
  return_field :meetingEdge, Types::MeetingType.edge_type

  resolve ->(_object, inputs, ctx) {
    user = ctx[:current_user]

    meeting = user.meetings.create!(
      title: inputs[:title],
      started_at: inputs[:started],
      finished_at: inputs[:finished]
    )

    range_add = GraphQL::Relay::RangeAdd.new(
      parent: user,
      collection: user.meetings,
      item: meeting,
      context: ctx
    )

    {
      meeting: meeting,
      meetingsConnection: range_add.connection,
      meetingEdge: range_add.edge
    }
  }
end
{% endhighlight %}

The client-side mutation needs a parent ID (a user ID), has to request the edge, and include `RANGE_ADD` in its configs.

{% highlight js %}
import { graphql } from 'react-relay'
import commitMutation from 'relay-commit-mutation-promise'

const mutation = graphql`
  mutation CreateMeetingMutation($input: createMeetingInput!) {
    createMeeting(input: $input) {
      meeting {
        id
        title
        started
        finished
      },
      meetingEdge {
        node {
          id
        }
      }
    }
  }
`

function commit(userId, { environment, input }) {
  const variables = { input }

  return commitMutation(environment, {
    mutation,
    variables,
    configs: [{
      type: 'RANGE_ADD',
      parentID: userId,
      connectionInfo: [{
        key: 'Meetings_meetings',
        rangeBehavior: 'append',
      }],
      edgeName: 'meetingEdge'
    }]
  })
}

export default {
  commit
}
{% endhighlight %}

You can see the complete server-side code in [33-minutes-server@2a70b7](https://github.com/33-minutes/33-minutes-server/commit/2a70b7ec7e7b2197d2b48156880ddaf3120d5ac3) and client-side code in [33-minutes-app@f253e4](https://github.com/33-minutes/33-minutes-app/commit/f253e488b754f77df9ff050b7bd56ef7ed92a3b3).

#### NODE_DELETE

The server has to return `deletedId`.

{% highlight ruby %}
Mutations::DeleteMeetingMutation = GraphQL::Relay::Mutation.define do
  name 'deleteMeeting'

  input_field :id, !types.ID

  return_field :deletedId, !types.ID

  resolve ->(_object, inputs, ctx) {
    user = ctx[:current_user]
    meeting = user.meetings.find(inputs[:id])
    meeting.destroy!
    {
      deletedId: meeting.id
    }
  }
end
{% endhighlight %}

The client-side mutation needs the parent ID (a user ID) and to include a `NODE_DELETE` in its configs.

{% highlight js %}
import { graphql } from 'react-relay'
import commitMutation from 'relay-commit-mutation-promise'

const mutation = graphql`
  mutation DeleteMeetingMutation($input: deleteMeetingInput!) {
    deleteMeeting(input: $input) {
      deletedId
    }
  }
`

function commit(userId, { environment, input }) {
  const variables = { input }
  return commitMutation(environment, {
    mutation,
    variables,
    configs: [{
      type: 'NODE_DELETE',
      parentID: userId,
      deletedIDFieldName: 'deletedId',
      connectionName: 'Meetings_meetings'
    }]
  })
}

export default {
  commit
}
{% endhighlight %}

Note that `NODE_DELETE` empties a node in the local store, but doesn't remove it. Therefore a `if (node)` is needed in the list renderer. This is [relay#2155](https://github.com/facebook/relay/issues/2155).

{% highlight js %}
let meetings = this.props.user.meetings.edges.map(({node}) => {
  if (node) {
    return <Meeting key={node.__id} meeting={node} deleteMethod={ () => this.removeMeetingById(node.__id) } />
  }
})
{% endhighlight %}

You can see the complete server-side code in [33-minutes-server@11c324](https://github.com/33-minutes/33-minutes-server/commit/11c324a5be457edcfc3b09a94d3f326633b22c16) and client-side code in [33-minutes-app@f253e4](https://github.com/33-minutes/33-minutes-app/commit/f253e488b754f77df9ff050b7bd56ef7ed92a3b3).

### Relay-Style Connections

Relay’s support for pagination relies on the GraphQL server exposing connections in a [standardized way](https://facebook.github.io/relay/graphql/connections.htm). To expose user's meetings as a GraphQL field you would write `field :meetings, -> { !types[Types::MeetingType] }`. To enable this to be Relay-style, use `connection`.

{% highlight ruby %}
Types::UserType = GraphQL::ObjectType.define do
   name 'User'
   field :id, types.ID, 'User ID.'
   field :name, types.String, 'User name.'

   connection :meetings, Types::MeetingType.connection_type
end
{% endhighlight %}

This returns meetings with `edge` and `node` elements along with `pageInfo` and much more.

See [33-minutes-server@f0bd7d](https://github.com/33-minutes/33-minutes-server/commit/f0bd7df9dd0f4311344557dce4e673e28c84f1d1) for a complete implementation. You will also need [rmosolgo/graphql-ruby#1754](https://github.com/rmosolgo/graphql-ruby/pull/1754) to make this work with Mongoid.

To enable this on the client requires a lot of boilerplate, including a pagination container and a call to Relay to load more data as [documented](https://relay.dev/docs/v10.1.3/pagination-container/). I suggest just copy-pasting and adapting working code from [33-minutes-app@4fd9bd](https://github.com/33-minutes/33-minutes-app/commit/4fd9bda8580ee2bad52a0c831b54a51957840bcb).
