package round.io.wkt;

import haxe.io.Bytes;

import winnepego.Parser;
import winnepego.Parsers;


enum WKTGeom {
  WKTPoint(x: Float, y: Float);
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
    pointTaggedText,
    function(g) { return g; });

  // ---------------------------------------------------------------------------
  // POINT
  // ---------------------------------------------------------------------------

  public static var point = Parser.apply(
    Parsers.float > Parsers.whitespace > Parsers.float,
    function(x, _, y) { return WKTPoint(x, y); });

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


}
