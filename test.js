var zmq = require('zmq')
  , sock = zmq.socket('push');

  sock.bindSync('tcp://localhost:7893');
  console.log('Producer bound to port 3000');

  setInterval(function(){
      console.log('sending work');
        sock.send('hi');
  }, 500);

