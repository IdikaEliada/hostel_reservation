import dotenv from "dotenv";
dotenv.config();
import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import notificationRoutes from './routes/notification.routes';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';

// Load environment variables
dotenv.config();

// Import Firebase config to initialize
import './config/firebase';

const app: Application = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors()); // Enable CORS for all routes
app.use(express.json()); // Parse JSON request bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Health check endpoint
app.get('/health', (_req: Request, res: Response) => {
    res.status(200).json({
        success: true,
        message: 'SOE305 Notification Backend is running',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
});

// API Routes
app.use('/api/notifications', notificationRoutes);

// 404 handler - must be after all other routes
app.use(notFoundHandler);

// Error handler - must be last
app.use(errorHandler);

// Start server
app.listen(PORT, () => {
    console.log('═══════════════════════════════════════════════════════');
    console.log('🚀 SOE305 Notification Backend Server');
    console.log('═══════════════════════════════════════════════════════');
    console.log(`📡 Server is running on port ${PORT}`);
    console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`🔗 Health check: http://localhost:${PORT}/health`);
    console.log(`📮 API endpoint: http://localhost:${PORT}/api/notifications`);
    console.log('═══════════════════════════════════════════════════════');
});

export default app;
