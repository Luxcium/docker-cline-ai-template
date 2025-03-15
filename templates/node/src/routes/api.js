import express from 'express';
import { ApiError, asyncHandler } from '../middleware/errorHandler.js';
import { logger } from '../utils/logger.js';

export const router = express.Router();

// Example endpoint
router.get(
  '/',
  asyncHandler(async (req, res) => {
    logger.info('API root endpoint accessed');
    res.json({
      message: 'Welcome to {{projectName}} API',
      version: '1.0.0',
      endpoints: [
        {
          path: '/api',
          method: 'GET',
          description: 'API information'
        },
        {
          path: '/api/example',
          method: 'GET',
          description: 'Example endpoint'
        }
      ]
    });
  })
);

// Example protected endpoint
router.get(
  '/example',
  asyncHandler(async (req, res) => {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      throw new ApiError(401, 'Authorization header is required');
    }

    // Example response
    res.json({
      success: true,
      data: {
        message: 'This is an example protected endpoint',
        timestamp: new Date().toISOString()
      }
    });
  })
);

// Example error endpoint
router.get(
  '/error',
  asyncHandler(async (req, res) => {
    throw new ApiError(400, 'This is an example error');
  })
);

// Add more routes here...

export default router;
