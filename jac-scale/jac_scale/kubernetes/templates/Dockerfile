# Use Python 3.12 slim image as base
FROM jaseci:base

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Set the default command to serve the jac application
CMD ["jac", "serve", "app.jac"]