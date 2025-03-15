"""FastAPI application module providing a basic CRUD API demonstration."""

from typing import Dict, List, Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(
    title="Python Template API",
    description="A demonstration CRUD API for the Python template",
    version="0.1.0"
)


class Item(BaseModel):
    """Data model for items in the API.
    
    Attributes:
        id: Unique identifier for the item
        name: Name of the item
        description: Optional description of the item
    """

    id: int
    name: str
    description: Optional[str] = None


# In-memory storage for demo purposes
items: Dict[int, Item] = {}


@app.get("/")
def read_root() -> Dict[str, str]:
    """Root endpoint returning a welcome message.

    Returns:
        Dict[str, str]: A simple welcome message
    """
    return {"message": "Hello, world!"}


@app.get("/items", response_model=List[Item])
def list_items() -> List[Item]:
    """List all items.

    Returns:
        List[Item]: List of all stored items
    """
    return list(items.values())


@app.get("/items/{item_id}", response_model=Item)
def read_item(item_id: int) -> Item:
    """Get a specific item by ID.

    Args:
        item_id: The ID of the item to retrieve

    Returns:
        Item: The requested item

    Raises:
        HTTPException: If the item is not found
    """
    if item_id not in items:
        raise HTTPException(status_code=404, detail="Item not found")
    return items[item_id]


@app.post("/items", response_model=Item)
def create_item(item: Item) -> Item:
    """Create a new item.

    Args:
        item: The item to create

    Returns:
        Item: The created item

    Raises:
        HTTPException: If an item with the same ID already exists
    """
    if item.id in items:
        raise HTTPException(status_code=400, detail="Item already exists")
    items[item.id] = item
    return item


@app.put("/items/{item_id}", response_model=Item)
def update_item(item_id: int, item: Item) -> Item:
    """Update an existing item.

    Args:
        item_id: The ID of the item to update
        item: The updated item data

    Returns:
        Item: The updated item

    Raises:
        HTTPException: If the item is not found or if IDs don't match
    """
    if item_id != item.id:
        raise HTTPException(status_code=400, detail="ID mismatch")
    if item_id not in items:
        raise HTTPException(status_code=404, detail="Item not found")
    items[item_id] = item
    return item


@app.delete("/items/{item_id}")
def delete_item(item_id: int) -> Dict[str, str]:
    """Delete an item.

    Args:
        item_id: The ID of the item to delete

    Returns:
        Dict[str, str]: Confirmation message

    Raises:
        HTTPException: If the item is not found
    """
    if item_id not in items:
        raise HTTPException(status_code=404, detail="Item not found")
    del items[item_id]
    return {"message": f"Item {item_id} deleted"}
