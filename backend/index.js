require('dotenv').config();
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.json({status: 'ok', message: 'Studeck API is running' });
});

const port = process.env.PORT || 4000;
app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});