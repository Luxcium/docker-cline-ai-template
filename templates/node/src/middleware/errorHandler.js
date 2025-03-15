import { logger } from '../utils/logger.js';

export const errorHandler = (err, req, res, next) => {
  // Log the error
  logger.error(err.stack);

  // Default error values
  const status = err.status || 500;
  const message = err.message || 'Internal Server Error';

  // Additional error details in development
  const errorDetails = process.env.NODE_ENV === 'development' 
    ? { stack: err.stack, ...err } 
    : {};

  // Send error response
  res.status(status).json({
    success: false,
    error: {
      message,
      ...errorDetails,
    },
  });
};

// Custom error class for API errors
export class ApiError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
    Error.captureStackTrace(this, this.constructor);
  }
}

// Async route handler wrapper to catch errors
export const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};
