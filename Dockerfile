# 1. Use a base image
FROM python:3.10-slim

# 2. Set the working directory
WORKDIR /app

# 3. Copy the requirements file and install dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copy the project files into the container
COPY . /app

# 5. Expose the FastAPI default port
EXPOSE 8000

# 6. Define the command to run the application (updated)
CMD ["uvicorn", "BackEnd.app.main:app", "--host", "0.0.0.0", "--port", "8000"]