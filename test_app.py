import pytest
from app import app, model  # import Flask app and model

def test_home_page():
    # Create a test client
    client = app.test_client()
    response = client.get("/")

    # Check the response status code
    assert response.status_code == 200
    # Optional: if your home page returns something specific, you can check it
    # assert b"hello world" in response.data  # modify based on your index.html

def test_model_loaded():
    # Check if the model is loaded
    assert model is not None, "Model is not loaded."
    # Check if model has predict method
    assert hasattr(model, 'predict'), "Loaded object does not have a 'predict' method."
