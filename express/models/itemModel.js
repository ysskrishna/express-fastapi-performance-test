const pool = require('../db');

const getItemById = async (item_id) => {
  const result = await pool.query('SELECT * FROM items WHERE item_id = $1', [item_id]);
  return result.rows[0];
};

const getItems = async (skip = 0, limit = 100) => {
  const result = await pool.query('SELECT * FROM items OFFSET $1 LIMIT $2', [skip, limit]);
  return result.rows;
};

const createItem = async (name, description) => {
  const result = await pool.query(
    'INSERT INTO items (name, description) VALUES ($1, $2) RETURNING *',
    [name, description]
  );
  return result.rows[0];
};

const updateItem = async (item_id, name, description) => {
  const result = await pool.query(
    'UPDATE items SET name = $1, description = $2 WHERE item_id = $3 RETURNING *',
    [name, description, item_id]
  );
  return result.rows[0];
};

const deleteItem = async (item_id) => {
  await pool.query('DELETE FROM items WHERE item_id = $1', [item_id]);
};

module.exports = {
  getItemById,
  getItems,
  createItem,
  updateItem,
  deleteItem,
};
