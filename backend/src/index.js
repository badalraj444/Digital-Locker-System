import express from 'express';
import cors from 'cors';
import mysql from 'mysql2/promise';
import waitPort from 'wait-port';

process.on('unhandledRejection', (reason, promise) => {
  console.error('💥 Unhandled Rejection at:', promise);
  console.error('🧨 Reason:', reason);
  process.exit(1); // Exit to avoid undefined state
});

const app = express();
const PORT = 3000;

const {
  MYSQL_HOST: HOST,
  MYSQL_USER: USER,
  MYSQL_PASSWORD: PASSWORD,
  MYSQL_DB: DB
} = process.env;

app.use(cors());
app.use(express.json());

await waitPort({ host: HOST, port: 3306, timeout: 10000 });

let db;
try {
  db = await mysql.createConnection({
    host: HOST,
    user: USER,
    password: PASSWORD,
    database: DB
  });

  console.log('✅ Connected to MySQL database');
} catch (error) {
  console.error('❌ Error connecting to MySQL:', error.message);
  process.exit(1); // Exit the app if DB fails to connect
}

app.get('/', (req, res) => {
  res.send('API is running...');
});
app.get('/api/hello', (req, res) => {
  res.json({ message: 'Hello from backend!' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
