#!/usr/bin/env python3
import os
import sys
from datetime import datetime
from PIL import Image
import json

def extract_image_metadata(image_path):
    """
    Extract metadata from an image file.
    
    Args:
        image_path: Path to the image file
        
    Returns:
        Dictionary containing image metadata
    """
    try:
        # Get file information
        file_stats = os.stat(image_path)
        filename = os.path.basename(image_path)
        
        # Open the image to get dimensions
        with Image.open(image_path) as img:
            width, height = img.size
            format = img.format
            mode = img.mode
            
            # Try to get EXIF data if available
            exif_data = {}
            if hasattr(img, '_getexif') and img._getexif() is not None:
                exif_data = {
                    ExifTags.TAGS[k]: v 
                    for k, v in img._getexif().items() 
                    if k in ExifTags.TAGS
                }
        
        # Create metadata dictionary
        metadata = {
            "filename": filename,
            "path": os.path.abspath(image_path),
            "size_bytes": file_stats.st_size,
            "dimensions": {
                "width": width,
                "height": height
            },
            "format": format,
            "color_mode": mode,
            "created_time": datetime.fromtimestamp(file_stats.st_ctime).isoformat(),
            "modified_time": datetime.fromtimestamp(file_stats.st_mtime).isoformat(),
            "exif_data": exif_data
        }
        
        # Parse some information from the filename (assuming filename format matches your demo files)
        parts = filename.split('_')
        if len(parts) > 1:
            # Try to extract UUID at the end
            last_part = parts[-1]
            if '.png' in last_part:
                uuid_part = last_part.split('.')[0]
                metadata["uuid"] = uuid_part
            
            # Get description from filename
            description = '_'.join(parts[:-1])
            metadata["description"] = description
            
        return metadata
        
    except Exception as e:
        return {
            "filename": os.path.basename(image_path),
            "path": os.path.abspath(image_path),
            "error": str(e)
        }

def process_directory(directory_path):
    """
    Process all image files in the given directory.
    
    Args:
        directory_path: Path to the directory containing images
        
    Returns:
        List of metadata dictionaries for each image
    """
    results = []
    
    # Check if the provided path exists and is a directory
    if not os.path.exists(directory_path):
        print(f"Error: Path '{directory_path}' does not exist.")
        return results
    
    if not os.path.isdir(directory_path):
        print(f"Error: Path '{directory_path}' is not a directory.")
        return results
    
    # Get all files in the directory
    files = [f for f in os.listdir(directory_path) 
             if os.path.isfile(os.path.join(directory_path, f))]
    
    # Filter for common image extensions
    image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff'}
    image_files = [f for f in files 
                   if os.path.splitext(f.lower())[1] in image_extensions]
    
    # Process each image file
    for image_file in image_files:
        image_path = os.path.join(directory_path, image_file)
        metadata = extract_image_metadata(image_path)
        results.append(metadata)
    
    return results

def main():
    # Get directory path from command line argument, or use default
    if len(sys.argv) > 1:
        directory_path = sys.argv[1]
    else:
        directory_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'demo')
    
    print(f"Processing images in: {directory_path}")
    
    # Process the directory
    results = process_directory(directory_path)
    
    # Output the results
    print(f"Found {len(results)} images.")
    print(json.dumps(results, indent=2))
    
    # Optionally save to file
    output_file = 'image_metadata.json'
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"Results saved to {output_file}")

if __name__ == "__main__":
    # Import ExifTags only if executing as main script
    try:
        from PIL.ExifTags import TAGS as ExifTags
    except ImportError:
        ExifTags = {}
    
    main()