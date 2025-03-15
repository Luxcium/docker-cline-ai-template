"""
Metadata extractor module with pure functions for extracting metadata from images.
"""

from datetime import datetime
import os
from typing import Dict, Any, Optional, Tuple
from PIL import Image
from PIL.ExifTags import TAGS as ExifTags


def extract_file_metadata(file_path: str) -> Dict[str, Any]:
    """
    Extract basic file metadata.
    
    Args:
        file_path: Path to the file
        
    Returns:
        Dictionary with basic file metadata
    """
    try:
        file_stats = os.stat(file_path)
        return {
            "filename": os.path.basename(file_path),
            "path": os.path.abspath(file_path),
            "size_bytes": file_stats.st_size,
            "created_time": datetime.fromtimestamp(file_stats.st_ctime).isoformat(),
            "modified_time": datetime.fromtimestamp(file_stats.st_mtime).isoformat(),
        }
    except Exception as e:
        return {
            "filename": os.path.basename(file_path),
            "path": os.path.abspath(file_path),
            "error": f"File metadata error: {str(e)}"
        }


def extract_image_dimensions(image: Image.Image) -> Dict[str, int]:
    """
    Extract image dimensions from a PIL Image object.
    
    Args:
        image: PIL Image object
        
    Returns:
        Dictionary with width and height
    """
    width, height = image.size
    return {
        "width": width,
        "height": height
    }


def extract_exif_data(image: Image.Image) -> Dict[str, Any]:
    """
    Extract EXIF data from a PIL Image object if available.
    
    Args:
        image: PIL Image object
        
    Returns:
        Dictionary with EXIF data or empty dict if none
    """
    if not hasattr(image, '_getexif') or image._getexif() is None:
        return {}
        
    return {
        ExifTags[k]: v 
        for k, v in image._getexif().items() 
        if k in ExifTags
    }


def extract_filename_components(filename: str) -> Dict[str, str]:
    """
    Extract useful components from an image filename.
    Assumes UUID as last component before extension.
    
    Args:
        filename: Name of the file
        
    Returns:
        Dictionary with extracted components
    """
    result = {}
    
    # Split by extension first
    name_parts = filename.rsplit('.', 1)
    if len(name_parts) > 1:
        result["extension"] = name_parts[1].lower()
    
    # Extract UUID and description from name (without extension)
    name_without_ext = name_parts[0]
    parts = name_without_ext.split('_')
    
    if len(parts) > 1:
        # Assume last part is the UUID
        possible_uuid = parts[-1]
        # UUID pattern validation (basic check)
        if len(possible_uuid) == 36 and possible_uuid.count('-') == 4:
            result["uuid"] = possible_uuid
            # Everything before the UUID is the description
            result["description"] = '_'.join(parts[:-1])
        else:
            # If no UUID pattern found, treat everything as description
            result["description"] = name_without_ext
    else:
        result["description"] = name_without_ext
        
    return result


def open_image(file_path: str) -> Tuple[Optional[Image.Image], Optional[str]]:
    """
    Safely open an image file and return the PIL Image object.
    
    Args:
        file_path: Path to the image file
        
    Returns:
        Tuple of (Image object or None, error message or None)
    """
    try:
        image = Image.open(file_path)
        return image, None
    except Exception as e:
        return None, str(e)


def extract_image_info(image: Image.Image) -> Dict[str, Any]:
    """
    Extract basic image information from a PIL Image object.
    
    Args:
        image: PIL Image object
        
    Returns:
        Dictionary with image information
    """
    return {
        "format": image.format,
        "color_mode": image.mode,
        "dimensions": extract_image_dimensions(image),
    }


def extract_full_metadata(file_path: str) -> Dict[str, Any]:
    """
    Extract all available metadata from an image file.
    This is a composition of the other functions.
    
    Args:
        file_path: Path to the image file
        
    Returns:
        Dictionary with complete metadata
    """
    # Start with basic file metadata
    metadata = extract_file_metadata(file_path)
    
    # Try to open the image
    image, error = open_image(file_path)
    if error:
        metadata["error"] = error
        return metadata
    
    # Extract filename components
    metadata.update(extract_filename_components(os.path.basename(file_path)))
    
    # Extract image info
    image_info = extract_image_info(image)
    metadata.update(image_info)
    
    # Extract EXIF data
    metadata["exif_data"] = extract_exif_data(image)
    
    # Ensure image is closed to free resources
    image.close()
    
    return metadata