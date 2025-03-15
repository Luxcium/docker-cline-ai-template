#!/usr/bin/env python3
"""
Command-line interface for the image processor package.

This CLI provides access to the image metadata extraction and processing features.
"""

import argparse
import sys
import os
import json
from typing import Dict, Any

from image_processor.api.processor import (
    get_metadata_for_file,
    get_metadata_for_directory,
    export_metadata_to_json,
    get_image_gallery,
    get_image_with_metadata,
    encode_image_to_base64
)


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Process and extract metadata from images."
    )
    
    # Create subparsers for different commands
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Extract metadata for a single file
    file_parser = subparsers.add_parser("file", help="Process a single image file")
    file_parser.add_argument("file_path", help="Path to the image file")
    file_parser.add_argument("--include-image", action="store_true", 
                          help="Include base64-encoded image data")
    file_parser.add_argument("--output", "-o", help="Output file path (JSON)")
    
    # Extract metadata for a directory of images
    dir_parser = subparsers.add_parser("directory", help="Process a directory of images")
    dir_parser.add_argument("directory_path", help="Path to the directory containing images")
    dir_parser.add_argument("--output", "-o", help="Output file path (JSON)")
    
    # Create a gallery with metadata (and optionally image data)
    gallery_parser = subparsers.add_parser("gallery", help="Create a gallery of images with metadata")
    gallery_parser.add_argument("directory_path", help="Path to the directory containing images")
    gallery_parser.add_argument("--include-images", action="store_true", 
                             help="Include base64-encoded image data")
    gallery_parser.add_argument("--output", "-o", help="Output file path (JSON)")
    
    # Export base64-encoded image
    base64_parser = subparsers.add_parser("base64", help="Export an image as base64")
    base64_parser.add_argument("file_path", help="Path to the image file")
    base64_parser.add_argument("--output", "-o", help="Output file path")
    
    return parser.parse_args()


def handle_file_command(args):
    """Handle the 'file' command."""
    if not os.path.exists(args.file_path):
        print(f"Error: File '{args.file_path}' does not exist.")
        return 1
        
    if args.include_image:
        result = get_image_with_metadata(args.file_path)
    else:
        result = get_metadata_for_file(args.file_path)
        
    if args.output:
        with open(args.output, 'w') as f:
            json.dump(result, f, indent=2)
        print(f"Metadata saved to '{args.output}'")
    else:
        print(json.dumps(result, indent=2))
        
    return 0


def handle_directory_command(args):
    """Handle the 'directory' command."""
    if not os.path.exists(args.directory_path) or not os.path.isdir(args.directory_path):
        print(f"Error: Directory '{args.directory_path}' does not exist.")
        return 1
        
    success = False
    
    if args.output:
        success = export_metadata_to_json(args.directory_path, args.output)
        if success:
            print(f"Metadata saved to '{args.output}'")
        else:
            print(f"Error: Failed to save metadata to '{args.output}'")
    else:
        results = get_metadata_for_directory(args.directory_path)
        print(json.dumps(results, indent=2))
        success = True
        
    return 0 if success else 1


def handle_gallery_command(args):
    """Handle the 'gallery' command."""
    if not os.path.exists(args.directory_path) or not os.path.isdir(args.directory_path):
        print(f"Error: Directory '{args.directory_path}' does not exist.")
        return 1
        
    gallery = get_image_gallery(args.directory_path, args.include_images)
    
    if args.output:
        with open(args.output, 'w') as f:
            json.dump(gallery, f, indent=2)
        print(f"Gallery saved to '{args.output}'")
    else:
        print(json.dumps(gallery, indent=2))
        
    return 0


def handle_base64_command(args):
    """Handle the 'base64' command."""
    if not os.path.exists(args.file_path):
        print(f"Error: File '{args.file_path}' does not exist.")
        return 1
        
    base64_data = encode_image_to_base64(args.file_path)
    
    if base64_data:
        if args.output:
            with open(args.output, 'w') as f:
                f.write(base64_data)
            print(f"Base64 data saved to '{args.output}'")
        else:
            print(base64_data)
            
        return 0
    else:
        print(f"Error: Failed to encode '{args.file_path}' to base64.")
        return 1


def main():
    """Main entry point for the CLI."""
    args = parse_arguments()
    
    if args.command == "file":
        return handle_file_command(args)
    elif args.command == "directory":
        return handle_directory_command(args)
    elif args.command == "gallery":
        return handle_gallery_command(args)
    elif args.command == "base64":
        return handle_base64_command(args)
    else:
        print("Error: No command specified. Use -h for help.")
        return 1


if __name__ == "__main__":
    sys.exit(main())