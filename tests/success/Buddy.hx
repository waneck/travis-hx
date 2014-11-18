import buddy.*;
using buddy.Should;

// compile with `haxe -lib buddy -main Buddy`
class Buddy extends buddy.BuddySuite implements buddy.Buddy
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
