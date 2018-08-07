---
layout: post
title: "Wiring Up a React Native Client to a Rails GraphQL Server"
date: "2018-08-01"
tags: [react native, 33 minutes]
---
In the [previous post](/2018/07/31/react-native-clock-timer.html) I added a React Native ticking timer. I now have enough client-side parts and it's time to wire up the client app to a server. This cookbook should be helpful to anyone doing it for the first time.

## Rails Server

### Boilerplate

Make a Rails API server with MongoDB.

1. Create a server with `rails new server --skip-active-record -T --api`, [33-minutes-server@74fd5a](https://github.com/33-minutes/33-minutes-server/commit/74fd5a207e9ab5c1369c4ca9b65f95ea0aa0a094).
2. Generate a MongoDB config with `rails g mongoid:config`, [33-minutes-server@3e1c6f](https://github.com/33-minutes/33-minutes-server/commit/3e1c6fc22e16acd1931acca26bb0877b93c37c2b).
3. Add RuboCop, my workflow typically consists of `rubocop -a ; rubocop --auto-gen-config`, [33-minutes-server@fc034c](https://github.com/33-minutes/33-minutes-server/commit/fc034c93796c67121fd9180f360ba077790940ad).
4. Add RSpec, [33-minutes-server@3af9b9](https://github.com/33-minutes/33-minutes-server/commit/3af9b987c4d2154d861cffa3a39fdc15820b48b6).
5. Enable Travis-CI, [33-minutes-server@8050ab](https://github.com/33-minutes/33-minutes-server/commit/8050ab4dad2a714bdcd31b3222d8f5fefde80e94).

### GraphQL Controller

Follow [my tutorial on exposing a GraphQL API](https://code.dblock.org/2017/10/23/building-and-consuming-a-graphql-api-in-ruby-on-rails.html) and use warden to keep authenticated user context. Since Warden requires cookies, re-add the `ActionDispatch::Cookies` middleware to `config/application.rb`.

{% highlight ruby %}
config.middleware.use ActionDispatch::Cookies
config.middleware.use ActionDispatch::Session::CookieStore, key: '_namespace_key'
{% endhighlight %}


A GraphQL mutation creates a user.

{% highlight ruby %}
Mutations::CreateUserMutation = GraphQL::Relay::Mutation.define do
  name 'createUser'
  input_field :email, !types.String
  input_field :password, !types.String
  input_field :name, !types.String
  return_field :user, Types::UserType
  resolve ->(_object, inputs, ctx) {
    user = User.create!(
      email: inputs[:email],
      name: inputs[:name],
      password: inputs[:password]
    )
    ctx[:warden].set_user(user)
  { user: user }
}
end
{% endhighlight %}


Similar GraphQL mutations login and logout users.

When serializing users with Warden, don't serialize the whole object or you'll get a `ActionDispatch::Cookies::CookieOverflow` exception.

{% highlight ruby %}
Rails.application.config.middleware.insert_after Rack::ETag, Warden::Manager do |manager|
  manager.failure_app = GraphqlController
  Warden::Manager.serialize_into_session do |user|
    user.id
  end
  Warden::Manager.serialize_from_session do |id|
    User.find(id)
  end
end
{% endhighlight %}

You can see the entire code in [33-minutes-server@52a249](https://github.com/33-minutes/33-minutes-server/commit/52a24924b5b0bfae41fa33ef8141099cbf66c351) and [33-minutes-server@0c3c4d](https://github.com/33-minutes/33-minutes-server/commit/0c3c4dea50b1d0eff4af27b9f540d129f78dbcaa).

### Schema IDL

Run `rake graphql:schema:idl` to generate a `schema.graphql` file and copy it to the client app's `schema` folder. This will have to be done every time the Rails API GraphQL schema changes.

## React Native Client

### Signed In vs. Signed Out

I used a switch navigator to toggle between the signed-in and signed-out states in [33-minutes-app@9f252c](https://github.com/33-minutes/33-minutes-app/commit/9f252cba4a92a89d006b14cf3fb7630e19b62636). Each state is its own stack navigator.

{% highlight js %}
const SignedOut = createStackNavigator({
  SignIn: {
    screen: SignIn
  },
  SignUp: {
    screen: SignUp
  }
});

const SignedIn = createStackNavigator({
  Main: {
    screen: Tabs
  },
  Settings: {
    screen: Settings
  }
});

export const createRootNavigator = (signedIn = false) => {
  return createSwitchNavigator(
    {
      SignedIn: {
        screen: SignedIn
      },
      SignedOut: {
        screen: SignedOut
      }
    },
    {
      initialRouteName: signedIn ? 'SignedIn' : 'SignedOut'
    }
  )
}
{% endhighlight %}

The entire app is that navigator.

{% highlight js %}
export default class App extends Component {
  render() {
    const Layout = createRootNavigator();
    return (
      <Layout />
    );
  }
}
{% endhighlight %}

To toggle between the states, navigate to either `SignedIn` or `SignedOut` (see the mutations below).

### Relay Boilerplate

The [Relay Quick Start Guide](https://facebook.github.io/relay/docs/en/quick-start-guide.html) is pretty good. We throw in `react-relay` with `yarn add react-relay` and `relay-compiler` with `yarn add -dev relay-compiler`. Add a `relay` script into `package.json`.

{% highlight json %}
"scripts": {
  "relay": "relay-compiler --src ./ --schema ./schema/schema.graphql --extensions=js --extensions=jsx"
}
{% endhighlight %}

Run `yarn relay`. Generally you will be running `yarn relay --watch`, which generates JavaScript code under a `__generated__` folders every time something changes. You will also have to restart this process when schema changes. This is not integrated with the rest of the compiler toolchain because <strike>that would be too easy</strike>.

### Environment

Copy-paste a relay environment into `app/Environment.js`. Note my hard-coded `http://localhost:3000/graphql` for the Rails server. I will make this dynamic in the future.

{% highlight js %}
import { Environment, Network, RecordSource, Store } from 'relay-runtime';

function fetchQuery(operation, variables) {
  return fetch('http://localhost:3000/graphql', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      query: operation.text,
      variables,
    }),
  }).then(response => {
    return response.json();
  });
}

const environment = new Environment({
  network: Network.create(fetchQuery),
  store: new Store(new RecordSource()),
});

export default environment;
{% endhighlight %}

### Create User Mutation

Copy-paste a relay-style mutation into `app/mutations/CreateUserMutation.js`.

{% highlight js %}
import { graphql } from 'react-relay'
import commitMutation from 'relay-commit-mutation-promise'

const mutation = graphql`
  mutation CreateUserMutation($input: createUserInput!) {
    createUser(input: $input) {
      user {
        id
      }
    }
  }
`

function commit({ environment, input }) {
  const variables = { input }
  return commitMutation(environment, {
    mutation,
    variables
  })
}

export default {
  commit
}
{% endhighlight %}

### Create a User

Invoke the mutation, switch to a signed-in navigator upon success, or set an error message otherwise.

{% highlight js %}
CreateUserMutation.commit({
  environment,
  input: {
    name: this.state.name,
    email: this.state.email,
    password: this.state.password
  }
}).then(response => {
  this.props.navigation.navigate('SignedIn')
}).catch(error => {
  this.setState({ message: error.message });
});
{% endhighlight %}

Login is very similar. For now we're using cookies to store a session and don't remember anything on the client, which means that reloading the app logs the user out.

## Code

See [33-minutes-app@e3e6b9](https://github.com/33-minutes/33-minutes-app/commit/e3e6b9e672ce552be95b7221b1c05818018e8ae9) for complete code.
