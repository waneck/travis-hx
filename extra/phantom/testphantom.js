var page = require('webpage').create();
page.open('http://localhost:2000/unit-js.html', function(status) {
	if (status != "success")
	{
		console.log("status error: " + status);
		phantom.exit(1);
	}

	var delay = 200,
			retries = 100; // 20 seconds

	function getContent() {
		return page.evaluate(function () {
			return document.getElementById('haxe:trace').textContent.trim();
		});
	}

	function poll() {
		var content = getContent();
		if(content) {
			console.log(ua);
			phantom.exit(0);
			return;
		}

		if(retries-- === 0) {
			// no content
			phantom.exit(1);
			return;
		}

		setTimeout(poll, delay);
	}

	poll();
});
