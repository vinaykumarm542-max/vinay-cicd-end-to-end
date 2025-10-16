# Use a specific Python 3.11 image to avoid compatibility issues
FROM python:3.11-slim

# Set environment variables for a smoother experience
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory inside the container
WORKDIR /app

# Install Django before copying your application code
RUN pip install django==3.2

# Copy the rest of your project code into the image
COPY . .

# Run database migrations
RUN python manage.py migrate

# Expose port and run server
EXPOSE 8000
CMD ["python","manage.py","runserver","0.0.0.0:8000"]
