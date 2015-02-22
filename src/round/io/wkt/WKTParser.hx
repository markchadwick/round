package round.io.wkt;

import haxe.io.Bytes;

import winnepego.Parser;
import winnepego.Parsers;

interface WKTGeom {
}

class WKTPoint implements WKTGeom {
  public var x(default, null): Float;
  public var y(default, null): Float;

  public function new(x: Float, y: Float) {
    this.x = x;
    this.y = y;
  }
}

class WKTLinestring implements WKTGeom {
  public var points(default, null): Array<WKTPoint>;

  public function new(points: Array<WKTPoint>) {
    this.points = points;
  }
}

class WKTPolygon implements WKTGeom {
  public var ring(default, null): WKTLinestring;
  public var holes(default, null): Array<WKTLinestring>;

  public function new(ring: WKTLinestring, holes: Array<WKTLinestring>) {
    this.ring  = ring;
    this.holes = holes;
  }
}

/**
 * Parses basic WKT geometries. This is based off section 7 of the spec
 * available at:
 *  http://www.opengeospatial.org/standards/sfa
 */
class WKTParser {

  // ---------------------------------------------------------------------------
  // Lexograpic basics
  // ---------------------------------------------------------------------------

  public static var leftParen  = Parser.apply('(', Parsers.noop);
  public static var rightParen = Parser.apply(')', Parsers.noop);

  public static var sep = Parser.apply(
    ',' > ~Parsers.whitespace,
    function(c, _) { return c; });

  // ---------------------------------------------------------------------------
  // Geometric primatives
  // ---------------------------------------------------------------------------

  public static var geometryTaggedText = Parser.apply(
    pointTaggedText |
    linestringTaggedText |
    polygonTaggedText,
    function(g: WKTGeom): WKTGeom { return g; });

  // ---------------------------------------------------------------------------
  // POINT
  // ---------------------------------------------------------------------------

  public static var point = Parser.apply(
    Parsers.float > Parsers.whitespace > Parsers.float,
    function(x, _, y) { return new WKTPoint(x, y); });

  public static var points = Parsers.repSep(point, sep);

  public static var pointText = Parser.apply(
    leftParen > point > rightParen,
    function(_, p, _) { return p; });

  public static var pointTaggedText = Parser.apply(
    'POINT ' > pointText,
    function(_, p) { return p; });

  // ---------------------------------------------------------------------------
  // LINESTRING
  // ---------------------------------------------------------------------------

  public static var linestringText = Parser.apply(
    leftParen > points > rightParen,
    function(_, ps, _) { return new WKTLinestring(ps); });

  // TODO Potentially not used
  public static var linestrings = Parsers.repSep(linestringText, sep);

  public static var linestringTaggedText = Parser.apply(
    'LINESTRING ' > linestringText,
    function(_, ls) { return ls; });

  // ---------------------------------------------------------------------------
  // POLYGON
  // ---------------------------------------------------------------------------

  public static var polygonHole = Parser.apply(
    sep > linestringText,
    function(_, ls) { return ls; });

  public static var polygonText = Parser.apply(
    leftParen > linestringText > ++polygonHole > rightParen,
    function(_, shell, holes, _) {
      return new WKTPolygon(shell, holes);
    });

  public static var polygonTaggedText = Parser.apply(
    'POLYGON ' > polygonText,
    function(_, polygon) { return polygon; });

}
