package round.io.wkt;

import haxe.io.Bytes;

import buddy.BuddySuite;
import utest.Assert;
import winnepego.Parser;

import round.io.wkt.WKTParser;

using buddy.Should;
using round.io.wkt.ShouldLexResult;


class WKTParserSpec extends BuddySuite {

  public function new() {

    describe('Lexographic primatives', {
      var l   = WKTParser.leftParen;
      var r   = WKTParser.rightParen;
      var sep = WKTParser.sep;

      it('should match a left paren', {
        parse(l, '(').should.parse('(');
      });

      it('should match a right paren', {
        parse(r, ')').should.parse(')');
      });

      it('should parse a sep comma', {
        parse(sep, ',').should.parse(',');
      });

      it('should parse sep comma a with trailing whitespace', {
        parse(sep, ',  ').should.parse(',');
      });

    });

    describe('POINT parser', {
      var point       = WKTParser.point;
      var points      = WKTParser.points;
      var text        = WKTParser.pointText;
      var taggedText  = WKTParser.pointTaggedText;

      it('should parse two floating point numbers', {
        var res = parse(point, '1.2 3.4');
        res.should.parse(new WKTPoint(1.2, 3.4));
      });

      it('should join zero repeated points', {
        var res = parse(points, '');
        res.should.parse([]);
      });


      it('should join one repeated point', {
        var res = parse(points, '9.8 7.6');
        res.should.parse([new WKTPoint(9.8, 7.6)]);
      });

      it('should join many repeated points', {
        var res = parse(points, '9.8 7.6, 1.0 2.0, 3.0 4.0');
        res.should.parse([
          new WKTPoint(9.8, 7.6),
          new WKTPoint(1.0, 2.0),
          new WKTPoint(3.0, 4.0),
        ]);
      });

      it('should parse two integer point numbers as floats', {
        var res = parse(point, '1 2');
        res.should.parse(new WKTPoint(1.0, 2.0));
      });

      it('should parse a paren point', {
        var res = parse(text, '(1.2 3.4)');
        res.should.parse(new WKTPoint(1.2, 3.4));
      });

      it('should parse a tagged point ', {
        var res = parse(taggedText, 'POINT (1.2 3.4)');
        res.should.parse(new WKTPoint(1.2, 3.4));
      });

    });

    describe('LINESTRING parser', {
      var text        = WKTParser.linestringText;
      var taggedText  = WKTParser.linestringTaggedText;
      var linestrings = WKTParser.linestrings;


      it('should parse an empty LINESTRING text', {
        var res = parse(text, '()');
        res.should.parse(new WKTLinestring([]));
      });

      it('should parse a sequence of points', {
        var res = parse(text, '(1.1 2.1, 1.2 2.2)');
        res.should.parse(new WKTLinestring([
          new WKTPoint(1.1, 2.1),
          new WKTPoint(1.2, 2.2),
        ]));
      });

      it('should parse an empty LINESTRING tagged text', {
        var res = parse(taggedText, 'LINESTRING ()');
        res.should.parse(new WKTLinestring([]));
      });

      it('should parse an empty set of LINESTRINGs', {
        var res = parse(linestrings, '');
        res.should.parse([]);
      });

      it('should parse a set of LINESTRINGs', {
        var res = parse(linestrings, '(1 2, 3 4), (5 6)');
        res.should.parse([
          new WKTLinestring([new WKTPoint(1.0, 2.0), new WKTPoint(3.0, 4.0)]),
          new WKTLinestring([new WKTPoint(5.0, 6.0)]),
        ]);
      });

    });

    describe('POLYGON parser', {
      var text = WKTParser.polygonText;

      describe('with a shell', {
        var poly = '((1 2))';

        it('should parse the shell', {
          var res = parse(text, poly);
          res.should.parse(new WKTPolygon(
            new WKTLinestring([new WKTPoint(1.0, 2.0)]),
            []
          ));
        });

        it('should have no holes', {
          switch(parse(text, poly)) {
            case Fail(_, _, msg): throw msg;
            case Pass(_, _, poly):
              poly.holes.length.should.be(0);
          }
        });

      });

      describe('with no ring', {
        var poly = '()';

        it('should not parse', {
          parse(text, poly).should.notParse();
        });

      });

      describe('with holes', {
        var poly = '((1 2), (3 4), (5 6))';

        it('should have its shell', {
          switch(parse(text, poly)) {
            case Fail(_, _, msg):  throw msg;
            case Pass(_, _, poly):
              Assert.same(poly.ring,
                new WKTLinestring([new WKTPoint(1.0, 2.0)]));
          }
        });

        it('should have holes', {
          switch(parse(text, poly)) {
            case Fail(_, _, msg):  throw msg;
            case Pass(_, _, poly): poly.holes.length.should.be(2);
          }
        });

      });

    });

    describe('geometryTaggedText parser', {
      var geom = WKTParser.geometryTaggedText;

      it('should parse a POINT', {
        var res = parse(geom, 'POINT (6.66 -78)');
        res.should.parse(new WKTPoint(6.66, -78.0));
      });

      it('should parse a LINESTRING', {
        var res = parse(geom, 'LINESTRING (6.66 -78, 1 2)');
        res.should.parse(new WKTLinestring([
          new WKTPoint(6.66, -78.0),
          new WKTPoint(1.0, 2.0),
        ]));
      });

      it('should parse a POLYGON', {
        var res = parse(geom, 'POLYGON ((1 2), (3 4))');
        res.should.parse(new WKTPolygon(
          new WKTLinestring([new WKTPoint(1.0, 2.0)]),
          [new WKTLinestring([new WKTPoint(3.0, 4.0)])]
        ));
      });

    });
  }

  private function parse<A>(f: Bytes -> Int -> LexResult<A>, s: String): LexResult<A> {
    return f(Bytes.ofString(s), 0);
  }
}
