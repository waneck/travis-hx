import js.Node.*;
using Reflect;

class RunSauceLabs {
	static function main():Void {
		var success = true;
		var webdriver:Dynamic = require("wd");
		var browser:Dynamic = webdriver.remote(
			"localhost",
			4445,
			Sys.getEnv("SAUCE_USERNAME"),
			Sys.getEnv("SAUCE_ACCESS_KEY")
		);

		var tags = [];
		if (Sys.getEnv("TRAVIS") != null)
			tags.push("TravisCI");

		//https://saucelabs.com/platforms
		var browsersFile = Sys.getEnv("SAUCE_BROWSERS");
		if (browsersFile == null)
			browsersFile = ".sauce-browsers.json";
		if (!fs.existsSync(browsersFile) && Sys.getEnv("TRAVIS_BUILD_DIR") != null)
		{
			var file = Sys.getEnv("TRAVIS_BUILD_DIR") + "/" + browsersFile;
			if (fs.existsSync(file))
				browsersFile = file;
		}

		if (!fs.existsSync(browsersFile))
		{
			console.log('File $browsersFile cannot be found. No platforms to test. Exiting...');
			Sys.exit(1);
		}
		var browsers = haxe.Json.parse( fs.readFileSync(browsersFile) );

		function testBrowsers(browsers:Array<Dynamic>) {
			if (browsers.length == 0) {
				Sys.exit(success ? 0 : 1);
			} else {
				function testBrowser(caps:Dynamic, retries = 3):Void {
					function handleError(err:String, ?pos:haxe.PosInfos):Bool {
						if (err != null) {
							console.log('${pos.fileName}:${pos.lineNumber}: $err');
							if (retries > 0)
								testBrowser(caps, retries - 1);
							else
								throw err;
							return false;
						}
						return true;
					}

					console.log('========================================================');
					console.log('${caps.browserName} ${caps.version} on ${caps.platform}:');
					browser.init(caps, function(err) {
						if (!handleError(err)) return;
						browser.get("http://localhost:2000/unit-js.html", function(err) {
							if (!handleError(err)) return;
							browser.text("body", function(err, re) {
								if (!handleError(err)) return;
								console.log(re);

								//check if test is successful or not
								var test = false;
								var prog = if (Sys.getEnv("EVAL_TEST_CMD") != null)
								{
									Sys.getEnv("EVAL_TEST_CMD").split(" ");
								} else {
									['neko', path.resolve(untyped __dirname, '../evaluate-test/evaluate-test.n')];
								};
								console.log("getting response from ", prog.join(" "));

								var child = child_process.exec(prog[0], prog.slice(1), function(code,stdout,stderr) {
									test = code.code == 0;
									console.log("passed: " + test);
									success = success && test;

									//let saucelabs knows the result
									browser.sauceJobUpdate({ passed: test }, function(err) {
										if (!handleError(err)) return;
										browser.quit(function(err) {
											if (!handleError(err)) return;
											testBrowsers(browsers);
										});
									});
								});
								child.stdin.write(re);
								child.stdin.end();
							});
						});
					});
				}

				var caps = browsers.shift();
				caps.setField("name", Sys.getEnv("TRAVIS") != null ? Sys.getEnv("TRAVIS_REPO_SLUG") : "haxe");
				caps.setField("tags", tags);
				if (Sys.getEnv("TRAVIS") != null) {
					caps.setField("tunnel-identifier", Sys.getEnv("TRAVIS_JOB_NUMBER"));
					caps.setField("build", Sys.getEnv("TRAVIS_BUILD_NUMBER"));
				}
				testBrowser(caps);
			}
		}
		testBrowsers(browsers);
	}
}
