"""Test module for the FastAPI application."""

from fastapi.testclient import TestClient

try:
    from ..src.main import app  # type: ignore
except (ImportError, ValueError):
    from src.main import app  # For running tests directly

client = TestClient(app)

def test_read_root():
    """Test the root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello, world!"}

def test_create_item():
    """Test item creation."""
    item = {"id": 1, "name": "Test Item", "description": "Test Description"}
    response = client.post("/items", json=item)
    assert response.status_code == 200
    assert response.json() == item

def test_read_item():
    """Test reading an item."""
    # First create an item
    item = {"id": 2, "name": "Test Item 2", "description": "Test Description 2"}
    client.post("/items", json=item)
    
    # Then read it
    response = client.get("/items/2")
    assert response.status_code == 200
    assert response.json() == item

def test_update_item():
    """Test updating an item."""
    # First create an item
    item = {"id": 3, "name": "Test Item 3", "description": "Test Description 3"}
    client.post("/items", json=item)
    
    # Then update it
    updated_item = {"id": 3, "name": "Updated Item", "description": "Updated Description"}
    response = client.put(f"/items/3", json=updated_item)
    assert response.status_code == 200
    assert response.json() == updated_item

def test_delete_item():
    """Test deleting an item."""
    # First create an item
    item = {"id": 4, "name": "Test Item 4", "description": "Test Description 4"}
    client.post("/items", json=item)
    
    # Then delete it
    response = client.delete("/items/4")
    assert response.status_code == 200
    assert response.json() == {"message": "Item 4 deleted"}
    
    # Verify it's gone
    response = client.get("/items/4")
    assert response.status_code == 404
