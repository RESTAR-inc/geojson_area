# GeoJSON.Area

[![Hex Version](https://img.shields.io/hexpm/v/geojson_area.svg)](https://hex.pm/packages/geojson_area)
[![docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/geojson_area/)
[![CI](https://github.com/RESTAR-inc/geojson_area/workflows/CI/badge.svg)](https://github.com/RESTAR-inc/geojson_area/actions?query=workflow%3ACI)

Compute the area of
[GeoJSON geometries](https://en.wikipedia.org/wiki/GeoJSON#Geometries).

Ported to Elixir from
[mapbox/geojson-area](https://github.com/mapbox/geojson-area) (javascript).

## Installation

The package can be installed by adding `geojson_area` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:geojson_area, "~> 0.1.0"}
  ]
end
```

## Examples

`geometry_area/1` supports any GeoJSON geometry:

```elixir
755640.4952324519 = GeoJSON.Area.geometry_area(%{
  type: "Polygon",
  coordinates: [
    [
      [139.7755122184753, 35.721064511354726],
      [139.76765871047974, 35.71514121326722],
      [139.76913928985596, 35.70895612333854],
      [139.77330207824707, 35.71014091012367],
      [139.7796106338501, 35.71869524495784],
      [139.7755122184753, 35.721064511354726]
    ]
  ]
})
```

Specialized functions such as `ring_area/1`, `polygon_area/1` or
`multi_polygon_area/1` can work directly on coordinates:

```elixir
3571505.5755534363 = GeoJSON.Area.ring_area([
  [139.7643756866455, 35.65645937572578],
  [139.78179931640625, 35.633720988098574],
  [139.75862503051758, 35.623256366178964],
  [139.7643756866455, 35.65645937572578]
])
```
