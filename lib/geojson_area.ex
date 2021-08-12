defmodule GeoJSON.Area do
  @moduledoc """
  Module to compute the area of
  [GeoJSON geometries](https://en.wikipedia.org/wiki/GeoJSON#Geometries).

  Ported to Elixir from
  [mapbox/geojson-area](https://github.com/mapbox/geojson-area) (javascript).

  Reference:
  Robert. G. Chamberlain and William H. Duquette, ["Some Algorithms for
  Polygons on a Sphere"](https://trs.jpl.nasa.gov/handle/2014/41271),
  JPL Publication 07-03, Jet Propulsion
  Laboratory, Pasadena, CA, June 2007.
  """

  @wgs84_radius 6_378_137
  @area_multiplier @wgs84_radius * @wgs84_radius / 2
  @empty_types ["Point", "MultiPoint", "LineString", "MultiLineString"]

  @typedoc """
  A point of the GeoJSON format `[longitude, latitude]`
  """
  @type point :: list(number())

  @typedoc """
  A "linear ring" of the GeoJSON format, i.e. a list of `[longitude, latitude]` points
  """
  @type ring :: list(point())

  @typedoc """
  A "Polygon" of the GeoJSON format, i.e. a list of linear rings.

  The first ring is the exterior one, the other ones are interior ones (holes).
  """
  @type polygon :: list(ring())

  @typedoc """
  A "MultiPolygon" of the GeoJSON format, i.e. a list of polygons.
  """
  @type multi_polygon :: list(polygon())

  @typedoc """
  A [GeoJSON geometry](https://en.wikipedia.org/wiki/GeoJSON#Geometries) map.

  It contains:
  - a `type` field (string) indicating the shape of the geometry
  - either a `coordinates` or `geometries` field, with a polymorphic value depending of the `type` field

  Keys can be both string or atoms.

  Possible types are:
  - `type: "Point", coordinates: [lon, lat]`
  - `type: "LineString", coordinates: [[lon, lat]]`
  - `type: "Polygon", coordinates: [[[lon, lat]]]`
  - `type: "MultiPoint", coordinates: [[lon, lat]]`
  - `type: "MultiLineString", coordinates: [[[lon, lat]]]`
  - `type: "MultiPolygon", coordinates: [[[[lon, lat]]]]`
  - `type: "GeometryCollection", geometries: [geometry]`

  This spec cannot be enforced through typespecs / dialyzer,
  because of the polymorphic type on a non-atom binary value of `type`.
  """
  @type geometry :: map()

  @doc """
  Returns in square meters the area of a GeoJSON `geometry` object.

  Supports both string and atom keys.
  Returns `0.0` for points and lines types.

  ## Examples

      iex> geometry_area(%{
      ...>   type: "Polygon",
      ...>   coordinates: [
      ...>     [
      ...>       [139.7755122184753, 35.721064511354726],
      ...>       [139.76765871047974, 35.71514121326722],
      ...>       [139.76913928985596, 35.70895612333854],
      ...>       [139.77330207824707, 35.71014091012367],
      ...>       [139.7796106338501, 35.71869524495784],
      ...>       [139.7755122184753, 35.721064511354726]
      ...>     ]
      ...>   ]
      ...> })
      755640.4952324519

      iex> geometry_area(%{
      ...>   "type" => "Point",
      ...>   "coordinates" => [139.7755122184753, 35.721064511354726]
      ...> })
      0.0

  """
  @spec geometry_area(geometry()) :: float()
  def geometry_area(geometry)

  def geometry_area(%{type: "GeometryCollection", geometries: geometries}) do
    sum_geometry_areas(geometries, 0.0)
  end

  def geometry_area(%{"type" => "GeometryCollection", "geometries" => geometries}) do
    sum_geometry_areas(geometries, 0.0)
  end

  def geometry_area(%{type: type, coordinates: coords}) when is_list(coords) do
    do_geometry_area(type, coords)
  end

  def geometry_area(%{"type" => type, "coordinates" => coords}) when is_list(coords) do
    do_geometry_area(type, coords)
  end

  defp do_geometry_area("MultiPolygon", coords), do: multi_polygon_area(coords)
  defp do_geometry_area("Polygon", coords), do: polygon_area(coords)
  defp do_geometry_area(empty_type, _coords) when empty_type in @empty_types, do: 0.0

  defp sum_geometry_areas([], acc), do: acc

  defp sum_geometry_areas([head | tail], acc) do
    new_acc = acc + geometry_area(head)
    sum_geometry_areas(tail, new_acc)
  end

  @doc """
  Returns in square meters the area of a GeoJSON `"MultiPolygon"` shape.
  Simply sums the areas of the sub polygons.

  ## Examples

      iex> multi_polygon_area([
      ...>   [
      ...>     [
      ...>       [139.77551, 35.72106],
      ...>       [139.76766, 35.71514],
      ...>       [139.76914, 35.70896],
      ...>       [139.7733, 35.71014],
      ...>       [139.77961, 35.7187],
      ...>       [139.77551, 35.72106]
      ...>     ]
      ...>   ],
      ...>   [
      ...>     [
      ...>       [139.74747, 35.69474],
      ...>       [139.74326, 35.68121],
      ...>       [139.75897, 35.6748],
      ...>       [139.76369, 35.68825],
      ...>       [139.74747, 35.69474]
      ...>     ]
      ...>   ]
      ...> ])
      3212633.6018961975

  """
  @spec multi_polygon_area(multi_polygon()) :: float()
  def multi_polygon_area(polygons) do
    do_multi_polygon_area(polygons, 0.0)
  end

  defp do_multi_polygon_area([] = _polygons, acc), do: acc

  defp do_multi_polygon_area([polygon | polygons], acc) do
    acc = acc + polygon_area(polygon)
    do_multi_polygon_area(polygons, acc)
  end

  @doc """
  Returns in square meters the area of a GeoJSON `"Polygon"` shape.

  ## Examples

      iex> polygon_area([
      ...>   [
      ...>     [139.77551, 35.72106],
      ...>     [139.76766, 35.71514],
      ...>     [139.76914, 35.70896],
      ...>     [139.7733, 35.71014],
      ...>     [139.77961, 35.7187],
      ...>     [139.77551, 35.72106]
      ...>   ]
      ...> ])
      755022.0928111264

  The areas of holes (everything but the first ring) are being subtracted
  from the exterior (first) ring:

      iex> polygon_area([
      ...>   [
      ...>     [139.77551, 35.72106],
      ...>     [139.76766, 35.71514],
      ...>     [139.76914, 35.70896],
      ...>     [139.7733, 35.71014],
      ...>     [139.77961, 35.7187],
      ...>     [139.77551, 35.72106]
      ...>   ],
      ...>   [
      ...>     [139.7709, 35.7142],
      ...>     [139.77219, 35.71256],
      ...>     [139.77262, 35.71016],
      ...>     [139.76948, 35.70946],
      ...>     [139.76884, 35.71385],
      ...>     [139.7709, 35.7142]
      ...>   ],
      ...>   [
      ...>     [139.77508, 35.71716],
      ...>     [139.77476, 35.71671],
      ...>     [139.77499, 35.71659],
      ...>     [139.77531, 35.71706],
      ...>     [139.77508, 35.71716]
      ...>   ]
      ...> ])
      625074.0429380704

  """
  @spec polygon_area(polygon()) :: float()
  def polygon_area([head | tail]) do
    acc = abs_ring_area(head)
    do_polygon_area(tail, acc)
  end

  defp do_polygon_area([], acc), do: acc

  defp do_polygon_area([head | tail], acc) do
    do_polygon_area(tail, acc - abs_ring_area(head))
  end

  defp abs_ring_area(coords) do
    coords |> ring_area() |> abs()
  end

  @doc """
  Calculate the approximate area of the polygon projected onto the earth.

  Note that this area will be positive if ring is oriented
  clockwise, otherwise it will be negative.

  The reference implementation can be found
  [here](https://github.com/mapbox/geojson-area/blob/ab9d362cacd895bf0eb3b7ea45c4213c3248a7be/index.js#L55).

  ## Examples

      iex> ring_area([
      ...>   [139.7643756866455, 35.65645937572578],
      ...>   [139.78179931640625, 35.633720988098574],
      ...>   [139.75862503051758, 35.623256366178964],
      ...>   [139.7643756866455, 35.65645937572578]
      ...> ])
      3571505.575552885

      iex> ring_area([
      ...>   [139.7643756866455, 35.65645937572578],
      ...>   [139.75862503051758, 35.623256366178964],
      ...>   [139.78179931640625, 35.633720988098574],
      ...>   [139.7643756866455, 35.65645937572578]
      ...> ])
      -3571505.575553023

  """
  @spec ring_area(ring()) :: float()
  def ring_area(coords)

  def ring_area([_, _, _ | _] = coords) do
    do_ring_area(coords, coords, 0.0) * @area_multiplier
  end

  def ring_area(coords) when is_list(coords) do
    0.0
  end

  defp do_ring_area([x, y, z | rest], coords, acc) do
    new_acc = acc + area(x, y, z)
    do_ring_area([y, z | rest], coords, new_acc)
  end

  defp do_ring_area([x, y], [first | _] = coords, acc) do
    new_acc = acc + area(x, y, first)
    do_ring_area([y], coords, new_acc)
  end

  defp do_ring_area([x], [first, second | _], acc) do
    acc + area(x, first, second)
  end

  defp area([x1, _x2], [_y1, y2], [z1, _z2]) do
    (rad(z1) - rad(x1)) * :math.sin(rad(y2))
  end

  defp rad(x) do
    :math.pi() * x / 180
  end
end
