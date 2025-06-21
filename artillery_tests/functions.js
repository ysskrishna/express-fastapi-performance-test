module.exports = {
  randomNumber: function(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  },
  seedTestData: async function(context, events) {
    try {
      const target = context.vars.target;
      const seedCount = parseInt(context.vars.seedCount || 50);
      console.log(`Seeding test data to ${target} with ${seedCount} items`);

      for (let i = 0; i < seedCount; i++) {
        try {
          const response = await fetch(`${target}/items/`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              name: `Seeded Item ${i}`,
              description: `Seeded item ${i} for testing`
            })
          });
          
          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
          }
          
          const data = await response.json();
          context.vars[`item_${i}_id`] = data.item_id;
          await new Promise(resolve => setTimeout(resolve, 100));
        } catch (error) {
          console.error(`Failed to create item ${i}:`, error.message);
        }
      }
    } catch (error) {
      console.error('Data seeding failed:', error);
    }
  }
}; 