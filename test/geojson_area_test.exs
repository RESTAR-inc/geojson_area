defmodule GeoJSON.AreaTest do
  use ExUnit.Case, async: true
  import GeoJSON.Area
  doctest GeoJSON.Area

  @clockwise_ring [
    [139.77551, 35.72106],
    [139.77961, 35.7187],
    [139.7733, 35.71014],
    [139.76914, 35.70896],
    [139.76766, 35.71514],
    [139.77551, 35.72106]
  ]

  @polygon [
    [
      [139.77551, 35.72106],
      [139.76766, 35.71514],
      [139.76914, 35.70896],
      [139.7733, 35.71014],
      [139.77961, 35.7187],
      [139.77551, 35.72106]
    ],
    [
      [139.7709, 35.7142],
      [139.77219, 35.71256],
      [139.77262, 35.71016],
      [139.76948, 35.70946],
      [139.76884, 35.71385],
      [139.7709, 35.7142]
    ],
    [
      [139.77508, 35.71716],
      [139.77476, 35.71671],
      [139.77499, 35.71659],
      [139.77531, 35.71706],
      [139.77508, 35.71716]
    ]
  ]

  @multi_polygon [
    [
      [
        [139.77551, 35.72106],
        [139.76766, 35.71514],
        [139.76914, 35.70896],
        [139.7733, 35.71014],
        [139.77961, 35.7187],
        [139.77551, 35.72106]
      ]
    ],
    [
      [
        [139.74747, 35.69474],
        [139.74326, 35.68121],
        [139.75897, 35.6748],
        [139.76369, 35.68825],
        [139.74747, 35.69474]
      ]
    ]
  ]

  describe "geometry_area/1" do
    test "returns 0.0 for empty geometries" do
      assert 0.0 =
               geometry_area(%{
                 type: "Point",
                 coordinates: [139.764, 35.656]
               })

      assert 0.0 =
               geometry_area(%{
                 type: "LineString",
                 coordinates: [[139.764, 35.656], [139.781, 35.633]]
               })

      assert 0.0 =
               geometry_area(%{
                 type: "MultiPoint",
                 coordinates: [[139.764, 35.656]]
               })

      assert 0.0 =
               geometry_area(%{
                 type: "MultiLineString",
                 coordinates: [[[139.764, 35.656], [139.781, 35.633]]]
               })
    end

    test "supports Polygon geometry" do
      assert 625_074.0429380704 =
               geometry_area(%{
                 type: "Polygon",
                 coordinates: @polygon
               })
    end

    test "supports MultiPolygon geometry" do
      assert 625_074.0429380704 =
               geometry_area(%{
                 type: "MultiPolygon",
                 coordinates: [@polygon]
               })

      assert 3_212_633.6018961975 =
               geometry_area(%{
                 type: "MultiPolygon",
                 coordinates: @multi_polygon
               })
    end

    test "supports GeometryCollection geometry" do
      assert 3_837_707.644834268 =
               geometry_area(%{
                 type: "GeometryCollection",
                 geometries: [
                   %{
                     type: "Polygon",
                     coordinates: @polygon
                   },
                   %{
                     type: "MultiPolygon",
                     coordinates: @multi_polygon
                   }
                 ]
               })

      assert 3_837_707.644834268 =
               geometry_area(%{
                 "type" => "GeometryCollection",
                 "geometries" => [
                   %{
                     "type" => "Polygon",
                     "coordinates" => @polygon
                   },
                   %{
                     "type" => "MultiPolygon",
                     "coordinates" => @multi_polygon
                   }
                 ]
               })
    end
  end

  describe "polygon_area/1" do
    test "returns the area of a Polygon" do
      assert 625_074.0429380704 = polygon_area(@polygon)
    end
  end

  describe "multi_polygon_area/1" do
    test "returns the area of a MultiPolygon" do
      assert 3_212_633.6018961975 = multi_polygon_area(@multi_polygon)
    end
  end

  describe "ring_area/1" do
    test "returns the area of a ring when oriented clockwise" do
      assert 755_022.0928112642 = @clockwise_ring |> ring_area()
    end

    test "returns the negative area of a ring when oriented counter-clockwise" do
      assert -755_022.0928111264 = @clockwise_ring |> Enum.reverse() |> ring_area()
    end

    test "returns 0.0 when length < 2" do
      assert 0.0 = ring_area([])
      assert 0.0 = ring_area([[139.764, 35.656]])
      assert 0.0 = ring_area([[139.764, 35.656], [139.781, 35.633]])
    end
  end
end
