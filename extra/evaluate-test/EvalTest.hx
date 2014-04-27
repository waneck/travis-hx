/**
	Simple program that evaluates stdin to figure out if a test ended correctly.
	This program can be overriden by defining the EVAL_TEST_CMD environment variable
**/
class EvalTest
{
	static function main()
	{
		var explicitFailed = false,
				explicitOk = false;
		try
		{
			var stdin = Sys.stdin();
			while(true)
			{
				var line = stdin.readLine();
				Sys.println(line);
				line =line.toLowerCase();
				if (line.indexOf("success: ") >= 0)
				{
					Sys.exit( line.indexOf('success: true') >= 0 ? 0 : 1);
				} else if (line.indexOf("some tests failures") >= 0) {
					explicitFailed = true;
				} else if (line.indexOf("all tests ok") >= 0) {
					explicitOk = true;
				} else if (line.indexOf('too many errors') >= 0) {
					Sys.exit(1);
				}
			}
		}
		catch(e:haxe.io.Eof)
		{
		}

		if (explicitFailed)
			Sys.exit(1);
		if (explicitOk)
			Sys.exit(0);
		Sys.println("REPORT: Cannot determine if test ended correctly");
		Sys.exit(1);
	}

}
