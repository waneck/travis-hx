var page = require('webpage').create();
page.open('http://localhost:2000/unit-js.html', function(status) {
	if (status != "success") {
		console.log("status error: " + status);
		return phantom.exit(1);
	}

	var delay = 1000,
			retries = 100; // 100 seconds

	function getContent() {
		return page.evaluate(function () {
			return document.getElementById('haxe:trace').textContent.trim();
		});
	}

	function poll() {
		var content = getContent();
		if(content) {
			console.log(content);
			return phantom.exit(0);
		}

		if(--retries === 0) {
			// no content
			console.log("status error: phantom timeout");
			return phantom.exit(1);
		}

		setTimeout(poll, delay);
	}

	poll();
});
