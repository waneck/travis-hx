var page = require('webpage').create();
page.open('http://localhost:2000/unit-js.html', function(status) {
	if (status != "success")
	{
		console.log("status error: " + status);
		phantom.exit(1);
	}
	var ua = page.evaluate(function () {
		return document.getElementById('haxe:trace').innerText;
	});
	console.log(ua);
	phantom.exit(0);
});
