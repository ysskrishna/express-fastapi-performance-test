const express = require('express');
const { body, param, query, validationResult } = require('express-validator');
const router = express.Router();
const itemModel = require('../models/itemModel');

// Create
router.post(
  '/',
  body('name').isString(),
  body('description').isString(),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { name, description } = req.body;
    const item = await itemModel.createItem(name, description);
    res.json(item);
  }
);

// Read One
router.get('/:item_id', async (req, res) => {
  const item = await itemModel.getItemById(req.params.item_id);
  if (!item) return res.status(404).json({ detail: 'Item not found' });
  res.json(item);
});

// Read Many
router.get('/', async (req, res) => {
  const skip = parseInt(req.query.skip) || 0;
  const limit = parseInt(req.query.limit) || 100;
  const items = await itemModel.getItems(skip, limit);
  res.json(items);
});

// Update
router.put(
  '/:item_id',
  body('name').isString(),
  body('description').isString(),
  async (req, res) => {
    const item = await itemModel.getItemById(req.params.item_id);
    if (!item) return res.status(404).json({ detail: 'Item not found' });

    const { name, description } = req.body;
    const updatedItem = await itemModel.updateItem(req.params.item_id, name, description);
    res.json(updatedItem);
  }
);

// Delete
router.delete('/:item_id', async (req, res) => {
  const item = await itemModel.getItemById(req.params.item_id);
  if (!item) return res.status(404).json({ detail: 'Item not found' });

  await itemModel.deleteItem(req.params.item_id);
  res.json({ message: 'Item deleted successfully' });
});

module.exports = router;
