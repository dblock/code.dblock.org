---
layout: post
title: "Implementing Geolocation with a Custom GraphQL Scalar Type in Ruby"
date: "2018-09-04"
tags: [graphql, ruby, 33 minutes, mongoid]
---
How does one return and accept a geolocation type in GraphQL? Something that has a `latitude` and `longitude`?

### Naive Implementation

The naive approach is to create a location type with a latitude and longitude.

{% highlight ruby %}
Types::LocationType = GraphQL::ObjectType.define do
  name 'Location'
  description 'A geo location.'

  field :latitude, !types.Float, 'Lat.'
  field :longitude, !types.Float, 'Lon.'
end
{% endhighlight %}

This can be returned as `field :location, Types::LocationType` in any GraphQL `ObjectType`.

To accept a location in a mutation we create an input type with the same properties.

{% highlight ruby %}
Types::InputLocationType = GraphQL::InputObjectType.define do
  name 'InputLocation'
  description 'A geo location.'

  argument :latitude, !types.Float, 'Lat.'
  argument :longitude, !types.Float, 'Lon.'
end
{% endhighlight %}

A query can ask for a location.

{% highlight json %}
location {
  latitude
  longitude
}
{% endhighlight %}

This needs to be wired to our MongoDB storage. I'm using [mongoid-geospatial](https://github.com/mongoid/mongoid-geospatial) and saving locations as a [Point](https://github.com/mongoid/mongoid-geospatial/blob/master/lib/mongoid/geospatial/fields/point.rb). The latter can accept latitude and logitude but then stores these as `x` and `y`. The location type specifies `property: :x` and `property :y` where appropriate, which is used when converting a `Point` into a `LocationType`, while the mutation converts input to a hash that is fed into `Point.new` automatically.

You can see this code in [33-minutes-server@c1fb00](https://github.com/33-minutes/33-minutes-server/commit/c1fb0098348d1833d9acc00c3c5a4347db1e2ebe), in which I confused `:x` and `:y` coordinates of `Point`. This was fixed in [33-minutes-server@9fc79d](https://github.com/33-minutes/33-minutes-server/commit/9fc79daebd43f9488d68fd5259c86f95954afd97).

### Custom GraphQL Scalar Type

The naive approach requires separate input and output types and the knowledge of a location internals (latitude, longitude). Lets elevate a location to a first class _scalar_ type, similar to how dates and times are implemented and call this _geo coordinates_. I'm using [geo_coord](https://github.com/zverok/geo_coord) that can parse and format geo coordinates according to multiple existing conventions, such as pairs of latitude and longitude or a combination of degrees, minutes and seconds.

{% highlight ruby %}
Types::GeoCoordinates = GraphQL::ScalarType.define do
  name 'GeoCoordinates'
  description 'Geo coordinate, latitude followed by longitude.'

  coerce_input ->(value, _ctx) { Geo::Coord.parse(value) }
  coerce_result ->(value, _ctx) { value.to_s }
end
{% endhighlight %}

We need to implement `Point#to_s` used above and convert a `Geo::Coord` to a `Hash` with latitude and longitude in our mutations to wire this up with mongoid-geospatial.

{% highlight ruby %}
module Mongoid
  module Geospatial
    class Point
      def to_s
        Geo::Coord.new(y, x).to_s
      end
    end
  end
end
{% endhighlight %}

Note that `Point` seems to implement support for latitude and longitude backwards. This is [mongoid-geospatial#61](https://github.com/mongoid/mongoid-geospatial/issues/61).

This is implemented in [33-minutes-server@28f309](https://github.com/33-minutes/33-minutes-server/commit/28f309cedd12d970338bfc98582daa521625b43e).

### Location Formats

The values passed back-and-forth are much more readable now and our API accepts standard notations (eg. `50.004444, 36.231389` or `50° 0′ 16″ N, 36° 13′ 53″ E`) and returns a `location` as a string (eg. `50° 0′ 16″ N, 36° 13′ 53″ E`). This allows for seamless future improvements in the location formats, but burdens the client to parse a complex response.

The first attempt at easing this is to return a location in the simpler `lat,lon` format.

{% highlight ruby %}
Types::GeoCoordinates = GraphQL::ScalarType.define do
  name 'GeoCoordinates'

  coerce_input ->(value, _ctx) { Geo::Coord.parse(value) }
  coerce_result ->(value, _ctx) { [value.y, value.x].map(&:to_s).join(',') }
end
{% endhighlight %}

We can do better and just return an array, as well as allow multiple kinds of location inputs.

{% highlight ruby %}
Types::GeoCoordinates = GraphQL::ScalarType.define do
  name 'GeoCoordinates'

  coerce_input ->(value, _ctx) {
    case value
    when Array
      Geo::Coord.new(value[0], value[1])
    else
      Geo::Coord.parse(value)
    end
  }

  coerce_result ->(value, _ctx) { [value.y, value.x] }
end
{% endhighlight %}

This is implemented in [33-minutes-server@098ff1](https://github.com/33-minutes/33-minutes-server/commit/098ff17148e30898e8efed3645a757750614132b) and [33-minutes-server@cc159b](https://github.com/33-minutes/33-minutes-server/commit/cc159bf87f0157c2f9cb0423ba51017fd2476174).
