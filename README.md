# Geospatial

![Australia Hilbert Curve](australia.png?raw=true "Australia Hilbert Curve Visualisation")

Geospatial provides abstractions for dealing with geographical locations efficiently. It is not a generic point/line/polygon handling library like [RGeo](https://github.com/rgeo/rgeo), but a specially crafted library to deal with querying for points on a map efficiently.

[![Build Status](https://secure.travis-ci.org/ioquatix/geospatial.svg)](http://travis-ci.org/ioquatix/geospatial)
[![Code Climate](https://codeclimate.com/github/ioquatix/geospatial.svg)](https://codeclimate.com/github/ioquatix/geospatial)
[![Coverage Status](https://coveralls.io/repos/ioquatix/geospatial/badge.svg)](https://coveralls.io/r/ioquatix/geospatial)

## Motivation

We had a need to query a database of places efficiently using SQLite. We did some investigation and found that SQLite (at least at the time) couldn't use composite indexes efficiently. Our testing revealed that MySQL also didn't really do well with large amounts of data. We had a table with 5Gb of data, and 15Gb of indexes. Crazy.

After researching geospatial hashing algorithms, I found [this blog post](http://blog.notdot.net/2009/11/Damn-Cool-Algorithms-Spatial-indexing-with-Quadtrees-and-Hilbert-Curves) and decided to implement a geospatial hash using the Hilbert curve. This library exposes a fast indexing and querying mechanism based on Hilbert curves, for points on a map, which can be integrated into a database or other systems as required.

The design of this library is inspired by [Space-Filling Curves in Scala](https://github.com/cne1x/sfseize), which exposes curves as composable mathematical hash functions.

For another solution to this problem, Google uses [S2 Geometry](http://blog.christianperone.com/2015/08/googles-s2-geometry-on-the-sphere-cells-and-hilbert-curve/) which is a more specific implementation designed for geospatial indexes only.

## Installation

Add this line to your application's Gemfile:

	gem 'geospatial'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install geospatial

## Usage

The simplest way to use this library is to use the built in `Map`:

```ruby
map = Geospatial::Map.new
map << Geospatial::Location.new(170.53, -43.89) # Lake Tekapo, New Zealand.
map << Geospatial::Location.new(170.45, -43.94) # Lake Alex, New Zealand.
map << Geospatial::Location.new(151.21, -33.85) # Sydney, Australia.

map.sort! # or assume an ordered database index.

new_zealand = Geospatial::Box.from_bounds(Vector[166.0, -48.0], Vector[180.0, -34.0])

points = subject.query(new_zealand)
expect(points).to include(lake_tekapo, lake_alex)
expect(points).to_not include(sydney)
```

At a lower level you can use the method in the `Geospatial::Hilbert` module to `map`, `unmap` and `traverse` the Hilbert mapping.

### Computing a Hilbert Index

```ruby
#!/usr/bin/env ruby
require 'geospatial/map'
require 'geospatial/dimensions'
require 'geospatial/hilbert/curve'

map = Geospatial::Map.for_earth(30)
coordinate = ARGV.collect(&:to_f)
index = map.hash_for_coordinates(coordinate)
puts index
```

### Geotemporal Indexes

The Hilbert curve is multi-dimensional and therefore can represent multi-dimensional data, e.g. latitude, longitude and time, in a single index. The curve expands uniformly in all dimensions, so you can't control the precision of the dimensions independently.

Mathematically speaking, it's possible to [compose curves together](https://github.com/cne1x/sfseize) to form curves of different precision/properties. However, how these fit together generally is a bit more complex, especially in terms of exploring the curve via traversal.

### Finding the distance between two locations

```ruby
lake_tekapo = Geospatial::Location.new(170.53, -43.89) # Lake Tekapo, New Zealand.
lake_alex = Geospatial::Location.new(170.45, -43.94) # Lake Alex, New Zealand.
distance = lake_alex.distance_from(lake_tekapo)
puts distance # 8479.056408162045 meters
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2016, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
