#!/usr/bin/env python3
"""
Display image metadata one by one with colorful formatting.
Uses the image_processor package to extract metadata and display it in a human-readable format.
"""

import os
import sys
import time
import argparse
from typing import Dict, Any, List

# Import our image processor package
from image_processor.api.processor import (
    get_metadata_for_directory,
    get_metadata_for_file
)

# ANSI color codes
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'


def colorize(text, color):
    """Apply color to text."""
    return f"{color}{text}{Colors.END}"


def format_metadata_for_display(metadata: Dict[str, Any]) -> List[str]:
    """
    Format image metadata for display with colors and structure.
    
    Args:
        metadata: Dictionary of image metadata
        
    Returns:
        List of formatted lines
    """
    lines = []
    
    # Header with filename
    filename = metadata.get("filename", "Unknown file")
    lines.append(colorize(f"{'=' * 80}", Colors.BLUE))
    lines.append(colorize(f"{filename}", Colors.HEADER + Colors.BOLD))
    lines.append(colorize(f"{'=' * 80}", Colors.BLUE))
    
    # Description if available
    if "description" in metadata:
        lines.append(colorize(f"Description: {metadata['description']}", Colors.GREEN))
    
    # Basic image info
    lines.append(colorize("Image Information:", Colors.BOLD + Colors.YELLOW))
    if "dimensions" in metadata:
        width = metadata["dimensions"].get("width", "Unknown")
        height = metadata["dimensions"].get("height", "Unknown")
        lines.append(f"  Dimensions: {width} x {height} pixels")
    
    if "format" in metadata:
        lines.append(f"  Format: {metadata['format']}")
    
    if "color_mode" in metadata:
        lines.append(f"  Color Mode: {metadata['color_mode']}")
    
    if "size_bytes" in metadata:
        # Format size in KB or MB for readability
        size_kb = metadata["size_bytes"] / 1024
        if size_kb > 1024:
            size_mb = size_kb / 1024
            lines.append(f"  Size: {size_mb:.2f} MB ({metadata['size_bytes']:,} bytes)")
        else:
            lines.append(f"  Size: {size_kb:.2f} KB ({metadata['size_bytes']:,} bytes)")
    
    # File information
    lines.append(colorize("\nFile Information:", Colors.BOLD + Colors.YELLOW))
    if "path" in metadata:
        lines.append(f"  Path: {metadata['path']}")
    
    if "created_time" in metadata:
        lines.append(f"  Created: {metadata['created_time']}")
    
    if "modified_time" in metadata:
        lines.append(f"  Modified: {metadata['modified_time']}")
    
    # UUID if available
    if "uuid" in metadata:
        lines.append(colorize(f"\nUUID: {metadata['uuid']}", Colors.CYAN))
    
    # EXIF data if available and not empty
    if "exif_data" in metadata and metadata["exif_data"]:
        lines.append(colorize("\nEXIF Data:", Colors.BOLD + Colors.YELLOW))
        for key, value in metadata["exif_data"].items():
            lines.append(f"  {key}: {value}")
    
    lines.append(colorize(f"\n{'=' * 80}\n", Colors.BLUE))
    
    return lines


def display_metadata(metadata: Dict[str, Any], delay: float = 0):
    """
    Display formatted metadata and wait for optional delay.
    
    Args:
        metadata: Dictionary of image metadata
        delay: Time to wait after displaying (in seconds)
    """
    lines = format_metadata_for_display(metadata)
    for line in lines:
        print(line)
    
    if delay > 0:
        time.sleep(delay)


def display_all_images(directory_path: str, delay: float = 2.0):
    """
    Display metadata for all images in a directory with delay between each.
    
    Args:
        directory_path: Path to directory containing images
        delay: Time to wait between displaying images (in seconds)
    """
    # Extract metadata for all images
    all_metadata = get_metadata_for_directory(directory_path)
    
    # If no images were found
    if not all_metadata:
        print(colorize(f"No images found in {directory_path}", Colors.RED))
        return
    
    # Display count
    print(colorize(f"Found {len(all_metadata)} images in {directory_path}", Colors.GREEN))
    print(colorize("Displaying information for each image...\n", Colors.GREEN))
    
    # Display each one with delay
    for i, metadata in enumerate(all_metadata):
        # Clear screen for better visibility (not on first image)
        if i > 0:
            os.system('cls' if os.name == 'nt' else 'clear')
        
        # Display progress
        print(colorize(f"Image {i+1} of {len(all_metadata)}", Colors.BOLD))
        
        # Display metadata with formatting
        display_metadata(metadata, delay)


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Display image metadata with colorful formatting."
    )
    parser.add_argument("path", help="Path to image directory or single image file")
    parser.add_argument("--delay", "-d", type=float, default=2.0,
                      help="Delay between displaying images (in seconds)")
    parser.add_argument("--no-delay", action="store_true",
                      help="Display all images without delay or clearing screen")
    
    return parser.parse_args()


def main():
    """Main entry point."""
    args = parse_arguments()
    
    # Check if path exists
    if not os.path.exists(args.path):
        print(colorize(f"Error: Path '{args.path}' does not exist.", Colors.RED))
        return 1
    
    # If delay is disabled
    delay = 0 if args.no_delay else args.delay
    
    # Process directory or single file
    if os.path.isdir(args.path):
        display_all_images(args.path, delay)
    else:
        # Single file
        metadata = get_metadata_for_file(args.path)
        if metadata:
            display_metadata(metadata)
        else:
            print(colorize(f"Error: Failed to extract metadata from '{args.path}'", Colors.RED))
            return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main())