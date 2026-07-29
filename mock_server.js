const http = require('http');
http.createServer((req, res) => {
  if (req.url === '/status') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      "device_id": "ecm50-mock",
      "device_name": "Эмулятор парной",
      "hostname": "ecm50-mock.local",
      "http_port": 8080,
      "discovery_port": 4210,
      "temperature": 32.7,
      "humidity": 32.5,
      "brightness": 40,
      "r": 255,
      "g": 255,
      "b": 255,
      "sensor_online": true,
      "wifi_connected": true,
      "ip": "10.0.2.2"
    }));
  } else {
    res.writeHead(404);
    res.end();
  }
}).listen(8080, () => {
  console.log('Mock server running on port 8080');
});
