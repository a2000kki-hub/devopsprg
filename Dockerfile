# Stage 1: Production server environment
FROM nginx:1.25-alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy static source code into nginx server directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 for traffic
EXPOSE 80

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
