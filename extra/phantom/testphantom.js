var page = require('webpage').create();
page.open('http://localhost:2000/unit-js.html', function(status) {
	if (status != "success") {
		console.log("status error: " + status);
		return phantom.exit(1);
	}

	var delay = 200,
			retries = 100; // 20 seconds

		page.evaluate(function () {
			function getContent() {
				return document.getElementById('haxe:trace').textContent.trim();
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
});
