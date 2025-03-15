"""
Main API interface for the image processor package.

This module provides functional interfaces for extracting and processing image metadata
and image data from files or directories. It composes the core functionality into 
higher-level operations that can be easily used by external systems.
"""

from typing import Dict, List, Any, Optional, Tuple, Callable
import os
import base64
from io import BytesIO
from PIL import Image

from ..core.metadata_extractor import extract_full_metadata
from ..utils.file_ops import (
    get_image_files_in_directory,
    process_files_with_function,
    save_json,
    load_json
)


def get_metadata_for_directory(directory_path: str) -> List[Dict[str, Any]]:
    """
    Get metadata for all images in a directory.
    
    Args:
        directory_path: Path to the directory
        
    Returns:
        List of metadata dictionaries
    """
    image_files = get_image_files_in_directory(directory_path)
    return process_files_with_function(image_files, extract_full_metadata)


def get_metadata_for_file(file_path: str) -> Dict[str, Any]:
    """
    Get metadata for a single image file.
    
    Args:
        file_path: Path to the image file
        
    Returns:
        Metadata dictionary
    """
    return extract_full_metadata(file_path)


def encode_image_to_base64(image_path: str) -> Optional[str]:
    """
    Encode an image to base64 for embedding or transmission.
    
    Args:
        image_path: Path to the image file
        
    Returns:
        Base64-encoded image data or None if error
    """
    try:
        with open(image_path, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read()).decode("utf-8")
            return encoded_string
    except Exception:
        return None


def get_image_with_metadata(image_path: str) -> Dict[str, Any]:
    """
    Get both image data (as base64) and metadata for an image.
    
    Args:
        image_path: Path to the image file
        
    Returns:
        Dictionary with metadata and base64 image data
    """
    metadata = extract_full_metadata(image_path)
    base64_image = encode_image_to_base64(image_path)
    
    result = metadata.copy()
    result["image_data"] = base64_image
    
    return result


def get_image_gallery(directory_path: str, include_image_data: bool = False) -> Dict[str, Any]:
    """
    Get metadata and optionally image data for all images in a directory.
    
    Args:
        directory_path: Path to the directory
        include_image_data: Whether to include base64-encoded image data
        
    Returns:
        Dictionary with gallery info and image items
    """
    image_files = get_image_files_in_directory(directory_path)
    
    # Process function depends on whether we want image data included
    if include_image_data:
        process_fn = get_image_with_metadata
    else:
        process_fn = extract_full_metadata
        
    # Process all files
    items = process_files_with_function(image_files, process_fn)
    
    # Create gallery info
    gallery = {
        "gallery_name": os.path.basename(os.path.abspath(directory_path)),
        "image_count": len(items),
        "items": items
    }
    
    return gallery


def process_images_with_transformation(
    directory_path: str,
    transform_fn: Callable[[Image.Image], Image.Image],
    output_directory: Optional[str] = None,
    suffix: str = "_transformed"
) -> List[str]:
    """
    Apply a transformation function to all images in a directory.
    
    Args:
        directory_path: Path to the directory with images
        transform_fn: Function to apply to each image
        output_directory: Directory to save transformed images (default: same as input)
        suffix: Suffix to add to transformed filenames
        
    Returns:
        List of paths to transformed images
    """
    image_files = get_image_files_in_directory(directory_path)
    result_paths = []
    
    # Set output directory
    if not output_directory:
        output_directory = directory_path
    
    # Create output directory if it doesn't exist
    os.makedirs(output_directory, exist_ok=True)
    
    for image_path in image_files:
        try:
            # Open the image
            with Image.open(image_path) as img:
                # Apply transformation
                transformed_img = transform_fn(img)
                
                # Create output filename
                filename = os.path.basename(image_path)
                name, ext = os.path.splitext(filename)
                output_filename = f"{name}{suffix}{ext}"
                output_path = os.path.join(output_directory, output_filename)
                
                # Save transformed image
                transformed_img.save(output_path)
                result_paths.append(output_path)
        except Exception:
            # Skip files with errors
            continue
    
    return result_paths


def export_metadata_to_json(directory_path: str, output_path: str) -> bool:
    """
    Extract metadata from all images in a directory and save to JSON file.
    
    Args:
        directory_path: Path to the directory with images
        output_path: Path where to save the JSON file
        
    Returns:
        True if successful, False otherwise
    """
    metadata_list = get_metadata_for_directory(directory_path)
    return save_json(metadata_list, output_path)


def load_metadata_from_json(json_path: str) -> Optional[List[Dict[str, Any]]]:
    """
    Load previously exported image metadata from JSON.
    
    Args:
        json_path: Path to the JSON file with metadata
        
    Returns:
        List of metadata dictionaries or None if error
    """
    return load_json(json_path)