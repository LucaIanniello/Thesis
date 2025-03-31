import os

def rename_videos(directory, extension='mp4', start_number=148):
    """Renames all video files in a directory with an increasing number."""
    files = sorted([f for f in os.listdir(directory) if f.endswith(f'.webm')])
    
    for idx, filename in enumerate(files, start=start_number):
        new_name = f"{idx:04d}.{extension}"
        old_path = os.path.join(directory, filename)
        new_path = os.path.join(directory, new_name)
        os.rename(old_path, new_path)
        print(f"Renamed: {filename} -> {new_name}")

# Usage
directory = "/home/lucaianniello/Thesis/HOLD/drawer_dataset/pretending_open/eval/"  # Change this to your folder path
rename_videos(directory)