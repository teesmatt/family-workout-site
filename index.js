const express = require('express')
const app = express()
const port = 3001

// Prometheus
const client = require('prom-client');
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics();

const counter = new client.Counter({
  name: 'name_count',
  help: 'counts the names',
  labelNames: ['name'],
});

app.get('/metrics', async (req, res) => {
  res.setHeader('Content-Type', client.register.contentType);
  res.send(await client.register.metrics());
});

app.use(express.static('public'));

app.listen(port, () => {
  console.log(`Living room gym listening on port ${port}`);
})
