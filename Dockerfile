# Stage 1: Build the application
FROM node:18 AS build

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY . .

# Build the application
RUN npm run build

# Stage 2: Serve the application using http-server
FROM node:18-alpine
# Set the working directory
WORKDIR /app
# Copy the built application from the previous stage
COPY --from=build /app/dist ./dist
# Install http-server globally
RUN npm install -g http-server
# Expose port 8080
EXPOSE 8080
# Start the http-server to serve static files
CMD ["http-server", "dist", "-p", "8080"]