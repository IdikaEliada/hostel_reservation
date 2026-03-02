import { Request, Response, NextFunction } from 'express';

interface ErrorResponse {
    success: false;
    error: {
        message: string;
        code?: string;
        details?: any;
    };
}

export const errorHandler = (
    err: any,
    _req: Request,
    res: Response,
    _next: NextFunction
): void => {
    console.error('❌ Error:', err);

    // Default error response
    const statusCode = err.statusCode || 500;
    const response: ErrorResponse = {
        success: false,
        error: {
            message: err.message || 'Internal server error',
            code: err.code,
            details: process.env.NODE_ENV === 'development' ? err.stack : undefined
        }
    };

    res.status(statusCode).json(response);
};

export const notFoundHandler = (_req: Request, res: Response): void => {
    res.status(404).json({
        success: false,
        error: {
            message: `Route ${_req.method} ${_req.path} not found`,
            code: 'NOT_FOUND'
        }
    });
};
