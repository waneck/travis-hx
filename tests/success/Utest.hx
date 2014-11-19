import utest.Runner;
import utest.ui.Report;
import utest.TestResult;

// compile with -D travis -lib utest
class Utest
{
	static function main()
	{
#if cpp
	#if HXCPP_M64
		trace('is 64-bit');
	#else
		trace('is 32-bit');
	#end
#elseif java
		trace('arch model: ' + java.lang.System.getProperty("sun.arch.data.model"));
#elseif cs
		trace('pointer size: ' + cs.system.IntPtr.Size);
#end

		var runner = new Runner();

		runner.addCase(new UtestSuccessCase());
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

class UtestSuccessCase
{
	public function new()
	{
	}

	public function test_works()
	{
		utest.Assert.isTrue(true, 'This shouldn\'t fail. Really!');
	}
}
