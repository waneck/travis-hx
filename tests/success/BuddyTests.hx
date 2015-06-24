import buddy.reporting.TravisHxReporter;
import buddy.*;
using buddy.Should;

// Temporary fix https://github.com/HaxeFoundation/haxe/issues/4286
#if java
class BuddyTests {
	static public function main() {
		var reporter = new TravisHxReporter();
		var runner = new SuitesRunner([new SuccessTest()], reporter);
		runner.run().then(function(_) { Sys.exit(runner.statusCode()); });
	}
}
#else
// compile with `haxe -lib buddy -main Buddy`
class BuddyTests implements buddy.Buddy<[SuccessTest]> {}
#end

class SuccessTest extends buddy.BuddySuite
{
	public function new()
	{
		describe('Sure Success!', {
			var something = "?";
			it('should fail to test failure check', {
				something.should.be('?');
			});
		});
	}
}
