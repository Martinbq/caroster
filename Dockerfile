# Use Node.js 18 Alpine
FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    postgresql-client \
    netcat-openbsd

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Install and build backend
WORKDIR /app/backend
RUN npm ci --only=production --no-optional
RUN npm run build

# Install and build frontend
WORKDIR /app/frontend  
RUN npm ci --only=production --no-optional
RUN npm run build

# Back to app root
WORKDIR /app

# Create startup script
RUN echo '#!/bin/bash\n\
set -e\n\
echo "=== Starting Caroster ==="\n\
\n\
# Wait for database\n\
echo "Waiting for PostgreSQL..."\n\
while ! nc -z ${DATABASE_HOST:-postgres} ${DATABASE_PORT:-5432}; do\n\
  echo "PostgreSQL not ready, waiting..."\n\
  sleep 2\n\
done\n\
echo "PostgreSQL is ready!"\n\
\n\
# Start backend\n\
echo "Starting Strapi backend..."\n\
cd /app/backend\n\
npm start &\n\
BACKEND_PID=$!\n\
echo "Backend started with PID: $BACKEND_PID"\n\
\n\
# Wait for backend\n\
echo "Waiting for backend to be ready..."\n\
sleep 45\n\
\n\
# Test backend health\n\
echo "Testing backend health..."\n\
for i in {1..10}; do\n\
  if curl -f http://localhost:1337/admin > /dev/null 2>&1; then\n\
    echo "Backend is healthy!"\n\
    break\n\
  fi\n\
  echo "Backend not ready yet, attempt $i/10"\n\
  sleep 5\n\
done\n\
\n\
# Start frontend\n\
echo "Starting Next.js frontend..."\n\
cd /app/frontend\n\
npm start &\n\
FRONTEND_PID=$!\n\
echo "Frontend started with PID: $FRONTEND_PID"\n\
\n\
# Keep both running\n\
echo "Both services started. Keeping alive..."\n\
wait $BACKEND_PID $FRONTEND_PID\n\
' > /app/start.sh

# Make script executable
RUN chmod +x /app/start.sh

# Expose port 3000 (frontend will proxy to backend)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
  CMD curl -f http://localhost:3000 || exit 1

# Start application
CMD ["/app/start.sh"]
