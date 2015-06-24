import buddy.*;
using buddy.Should;

// compile with `haxe -lib buddy -main Buddy`
class BuddyTests implements buddy.Buddy<[FailureTest]> {}

class FailureTest extends buddy.BuddySuite
{
	public function new()
	{
		describe('Sure fail!', {
			var something = "?";
			it('should fail to test failure check', {
				something.should.be('not ?');
			});
		});
	}
}
