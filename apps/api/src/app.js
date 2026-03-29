import express from 'express';
import cors from 'cors';
import patientRoutes from './routes/patientRoutes.js';

const app = express();

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
    res.json({ status: 'API works 🚀' });
});

app.use('/api/patients', patientRoutes);

export default app;