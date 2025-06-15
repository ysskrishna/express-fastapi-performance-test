const express = require('express');
const itemsRouter = require('./routes/items');
const app = express();

app.use(express.json());

app.use('/items', itemsRouter);

app.get('/', (req, res) => {
  res.send({ message: 'Welcome to Express.js API' });
});

app.listen(3000, () => {
  console.log('Server running on PORT: 3000');
});
