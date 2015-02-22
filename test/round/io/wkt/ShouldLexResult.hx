package round.io.wkt;

import haxe.PosInfos;

import utest.Assert;
import buddy.Should;
import winnepego.Parser;


class ShouldLexResult<T> extends Should<LexResult<T>> {

  static public function should<T>(value: LexResult<T>, assert: SpecAssertion) {
    return new ShouldLexResult<T>(value, assert);
  }

  public function new(value: LexResult<T>, assert: SpecAssertion, inverse=false) {
    super(value, assert, inverse);
  }

  // TODO: Inverse values!
  // public var not(get, never): ShouldLexResult<T>;
  // private function get_not() {
  //   return new ShouldLexResult<T>(value, assert, !inverse);
  // }

  public function parse(exp: T, ?p: PosInfos) {
    switch(value) {
      case Pass(_, _, result):
        Assert.same(result, exp, true, null, p);
      case Fail(buf, pos, error):
        var msg = [
          '',
          error,
          buf.toString(),
          [for(i in 0...pos-1) ' '].join('') + '^',
          '',
        ];
        assert(false, msg.join('\n'), stackPos(p));
    }
  }

  public function notParse(?p: PosInfos) {
    switch(value) {
      case Pass(_, _, result):
        Assert.fail('should not have parsed, got ${result}', p);
      case _:
        assert(true, '', stackPos(p));
    }
  }
}
