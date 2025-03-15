"""
File operations utility module with pure functions.
"""

import os
import json
from typing import List, Dict, Any, Callable, Optional


def list_files_in_directory(directory_path: str) -> List[str]:
    """
    List all files in a directory.
    
    Args:
        directory_path: Path to the directory
        
    Returns:
        List of file paths
    """
    if not os.path.exists(directory_path) or not os.path.isdir(directory_path):
        return []
        
    return [
        os.path.join(directory_path, f) 
        for f in os.listdir(directory_path) 
        if os.path.isfile(os.path.join(directory_path, f))
    ]


def filter_files_by_extension(file_paths: List[str], extensions: List[str]) -> List[str]:
    """
    Filter files by their extension.
    
    Args:
        file_paths: List of file paths
        extensions: List of extensions to filter by (without dot)
        
    Returns:
        Filtered list of file paths
    """
    # Normalize extensions by ensuring they start with a dot and are lowercase
    normalized_extensions = [
        f".{ext.lower()}" if not ext.startswith('.') else ext.lower() 
        for ext in extensions
    ]
    
    return [
        path for path in file_paths 
        if os.path.splitext(path.lower())[1] in normalized_extensions
    ]


def save_json(data: Any, output_path: str) -> bool:
    """
    Save data as JSON to a file.
    
    Args:
        data: Data to save
        output_path: Path where to save the JSON file
        
    Returns:
        True if successful, False otherwise
    """
    try:
        with open(output_path, 'w') as f:
            json.dump(data, f, indent=2)
        return True
    except Exception:
        return False


def load_json(input_path: str) -> Optional[Any]:
    """
    Load JSON data from a file.
    
    Args:
        input_path: Path to the JSON file
        
    Returns:
        Loaded data or None if error
    """
    try:
        with open(input_path, 'r') as f:
            return json.load(f)
    except Exception:
        return None


def process_files_with_function(file_paths: List[str], process_fn: Callable[[str], Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Process multiple files with a provided function.
    
    Args:
        file_paths: List of file paths to process
        process_fn: Function to apply to each file
        
    Returns:
        List of processing results
    """
    return [process_fn(file_path) for file_path in file_paths]


def get_image_files_in_directory(directory_path: str) -> List[str]:
    """
    Get all image files in a directory. A composition of other functions.
    
    Args:
        directory_path: Path to the directory
        
    Returns:
        List of image file paths
    """
    # Common image extensions
    image_extensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'webp']
    
    # List and filter files
    all_files = list_files_in_directory(directory_path)
    image_files = filter_files_by_extension(all_files, image_extensions)
    
    return image_files