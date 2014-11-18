import utest.Runner;
import utest.ui.Report;
import utest.TestResult;

// compile with -D travis -lib utest
class Utest
{
	static function main()
	{
		var runner = new Runner();

		runner.addCase(new UtestFailCase());
		Report.create(runner);

		var r:TestResult = null;
		runner.onProgress.add(function(o) if (o.done == o.totals) r = o.result);
		runner.run();

#if sys
		if (r.allOk())
			Sys.exit(0);
		else
			Sys.exit(1);
#end
	}
}

class UtestFailCase
{
	public function new()
	{
	}

	public function test_fails()
	{
		utest.Assert.isTrue(false, 'It\'s okay - this should fail. No worries!');
	}
}
