################################################################################
# 🐍 BASE IMAGE
# ------------------------------------------------------------------------------
# We start from an official, minimal Python image. "python:3.10-slim" is a 
# lightweight Debian-based image that contains just enough to run Python apps.
# Using a slim base image makes the final image smaller, faster to build, and
# reduces attack surface for security.
################################################################################
FROM python:3.10-slim


################################################################################
# ⚙️ ENVIRONMENT CONFIGURATION
# ------------------------------------------------------------------------------
# These environment variables are set to make Python run more efficiently 
# inside Docker:
# - PYTHONDONTWRITEBYTECODE=1 → prevents creation of .pyc files (bytecode cache)
# - PYTHONUNBUFFERED=1 → forces Python to flush stdout/stderr immediately, 
#   so logs appear in real time (useful for Docker logs)
################################################################################
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1


################################################################################
# 📂 SET WORKING DIRECTORY
# ------------------------------------------------------------------------------
# This defines the default directory inside the container where all subsequent 
# commands (COPY, RUN, CMD, etc.) will be executed. 
# Everything will live inside /app for clarity and consistency.
################################################################################
WORKDIR /app


################################################################################
# 📦 INSTALL SYSTEM DEPENDENCIES (OPTIONAL)
# ------------------------------------------------------------------------------
# Uncomment if your Python packages require system-level libraries (for example,
# if you're installing psycopg2, Pillow, or building from source).
# After installing, we clean up the apt cache to keep the image small.
################################################################################
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     && rm -rf /var/lib/apt/lists/*


################################################################################
# 📜 COPY REQUIREMENTS FILE AND INSTALL DEPENDENCIES
# ------------------------------------------------------------------------------
# We copy only the requirements.txt first — not the full app — and install 
# dependencies here. 
#
# WHY THIS MATTERS:
# -----------------
# Docker builds images in layers. Each command like COPY, RUN, or ADD creates
# a new cached layer. Docker will reuse a cached layer if nothing in that step
# or any previous steps has changed.
#
# This means:
#  - If you change only your application code (e.g., app.py), this layer stays 
#    the same, and Docker reuses it.
#  - That means "pip install" doesn’t re-run every time you rebuild.
#  - This saves *a lot* of time because dependency installation is often slow.
#
# Only when requirements.txt changes does this layer get invalidated and
# re-run — which makes sense, because that’s when dependencies actually change.
################################################################################
COPY requirements.txt .

# Install dependencies without caching package files to reduce image size.
RUN pip install --no-cache-dir -r requirements.txt


################################################################################
# 📁 COPY APPLICATION CODE
# ------------------------------------------------------------------------------
# After installing dependencies, we now copy the rest of your source code into
# the image. This includes your app files, configurations, templates, etc.
#
# This step will cause Docker to rebuild only this layer if code changes.
# Because dependency installation happened earlier, that cached layer is reused.
################################################################################
COPY . .


################################################################################
# 🌍 EXPOSE PORT (OPTIONAL)
# ------------------------------------------------------------------------------
# If your Python app runs on a known port (e.g., Flask defaults to 5000, 
# Django to 8000, FastAPI to 8000), you can declare it here.
# Jenkins or other orchestrators can use this for container networking.
################################################################################
# EXPOSE 5000


################################################################################
# 🚀 DEFAULT COMMAND
# ------------------------------------------------------------------------------
# This tells Docker what command to run when a container starts from this image.
# Here we run app.py using Python. If you use frameworks like Flask, Django,
# or FastAPI, adjust this to your server startup command (example below).
#
# Example for Flask:
#   CMD ["python", "app.py"]
#
# Example for Gunicorn (production):
#   CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:5000"]
################################################################################
CMD ["python", "app.py"]
