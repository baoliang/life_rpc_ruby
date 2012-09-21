var zmq = require('zmq');
var msg = require("msgpack");
var Wind =  require("wind");

var requester = zmq.socket('req');

requester.connect("tcp://localhost:7000");

 requester.onAsync = Wind.Async.Binding.fromStandard(requester.on);
  requester.send(msg.pack(["hi", []]));

var copyDirAsync = eval(Wind.compile("async", function () {
	 var t =    $await(requester.onAsync("message"));
	 return t;
 }));
	 

	console.log(copyDirAsync());
	
	
	
 
