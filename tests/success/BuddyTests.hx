import buddy.*;
using buddy.Should;

// compile with `haxe -lib buddy -main Buddy`
class BuddyTests implements buddy.Buddy<[SuccessTest]> {}

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
