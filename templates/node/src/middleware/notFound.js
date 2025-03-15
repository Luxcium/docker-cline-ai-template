import { ApiError } from './errorHandler.js';

export const notFound = (req, res, next) => {
  next(
    new ApiError(
      404,
      `Not Found - ${req.originalUrl}`
    )
  );
};
