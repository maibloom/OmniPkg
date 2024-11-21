import requests
import os
import subprocess

# GitHub API endpoint for your releases
SCRIPT_PATH = '/usr/local/bin/omnipkg/omnipkg.py'  # Path where the script is installed
REPO_OWNER = 'devtracer'  # Your GitHub username
REPO_NAME = 'OmniPkg'  # Your repository name

def get_current_version():
    """Get the current version of the installed omnipkg script"""
    try:
        with open(SCRIPT_PATH, 'r') as file:
            # Look for a version tag in the script (you can update this part as needed)
            for line in file:
                if line.startswith("__version__"):
                    return line.strip().split('=')[-1].strip(' "')
    except FileNotFoundError:
        print("Error: omnipkg script not found.")
        return None
    return None

def get_latest_release():
    """Fetch the latest release info from GitHub"""
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/releases/latest"
    response = requests.get(url)
    
    if response.status_code == 200:
        release_data = response.json()
        return release_data['tag_name'], release_data['zipball_url']
    else:
        print("Error checking for updates on GitHub.")
        return None, None

def update_script():
    """Check and update the script if a new version is available"""
    # Get the current installed version of omnipkg
    current_version = get_current_version()
    tag, download_url = get_latest_release()

    if not tag:
        print("Failed to check for updates.")
        return
    
    print(f"Current version: {current_version}")
    print(f"Latest version: {tag}")
    
    # If current version is the same as the latest, notify the user
    if current_version == tag:
        print("Your omnipkg script is already up-to-date.")
        return
    
    print(f"New version {tag} available. Updating...")
    
    # Download the latest version
    response = requests.get(download_url, stream=True)
    with open(f'{SCRIPT_PATH}.new', 'wb') as file:
        for chunk in response.iter_content(chunk_size=8192):
            file.write(chunk)
    
    # Replace the old script with the new one
    os.replace(f'{SCRIPT_PATH}.new', SCRIPT_PATH)
    print(f"Updated to version {tag}")

def omniupdate():
    # Check if an update is available and perform it if necessary
    update_script()
    
    # Continue with the normal functionality of omnipkg
    print("omnipkg is running.")

if __name__ == "__main__":
    main()
