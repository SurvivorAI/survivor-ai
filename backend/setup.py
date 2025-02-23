import os
from pathlib import Path
import yaml

def startup():
    yaml_name = "app_config.yml"  # YAML file name
    base_path = str(Path(__file__).parent.absolute())  # Get current directory
    yaml_path = os.path.join(base_path, yaml_name)  # Full path to YAML file

    # Load YAML file
    with open(yaml_path, "r") as file:
        data = yaml.safe_load(file)  # Safely load YAML

    # Modify dataset_base_path if it is None
    if data.get("base_path") is not base_path:
        data["base_path"] = base_path  # Set to the current working directory
        data["database_path"] = os.path.join(base_path,"archive")


    # Save the modified YAML file
    with open(yaml_path, "w") as file:
        yaml.dump(data, file, default_flow_style=False)

    # Print the base path
    print("Updated dataset_base_path to:", base_path)
    return yaml_path