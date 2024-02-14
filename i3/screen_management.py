# Equivalent of DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
from dataclasses import dataclass, field
import json
import os
from time import sleep
from typing import Dict, List, Optional
import re


DIR = os.path.dirname(os.path.abspath(__file__))

SCREEN_CONFIG = os.path.join(DIR, 'screen.json')
I3_ENV = os.path.join(DIR, 'i3.env')


@dataclass
class AutoXrandrProfile:
    """Dataclass for autoxrandr profile"""
    name: str
    detected: bool
    current: bool

@dataclass
class AutoXrandrOutputs:
    """Dataclass for autoxrandr output"""
    profiles: List[AutoXrandrProfile]

    @staticmethod
    def create_from_autorandr_output() -> 'AutoXrandrOutputs':
        output = os.popen('autorandr').read()
        profiles = []
        # Split the output into lines and process each line
        for line in output.strip().split('\n'):
            match = re.search(r'^(?P<name>\S+)( \((detected)\))?( \((current)\))?$', line)
            if match:
                name = match.group('name')
                detected = bool(match.group(3))  # 'detected' is in the 3rd group
                current = bool(match.group(5))  # 'current' is in the 5th group
                profiles.append(AutoXrandrProfile(name=name, detected=detected, current=current))
        return AutoXrandrOutputs(profiles)

@dataclass
class Profile:
    """Dataclass for each profile with specific screens"""
    screen1: str
    screen2: Optional[str]
    screen3: Optional[str]

@dataclass
class AutoXrandrConfig:
    """Dataclass for the overall configuration"""
    profiles: Dict[str, Profile] = field(default_factory=dict)

# Function to create an instance from the JSON data
def create_from_json(data: dict) -> AutoXrandrConfig:
    config = AutoXrandrConfig()
    for profile_name, screens in data["profiles"].items():
        profile = Profile(
            screen1=screens.get("screen1"),
            screen2=screens.get("screen2"),
            screen3=screens.get("screen3"),
        )
        config.profiles[profile_name] = profile
    return config
   
def parse_xrandr_output(output : str) ->Dict[str, str]:
    """return a dict with the EDID as key and the port as value"""
    # Regex to match the port blocks
    port_block_regex = re.compile(r'^(\S+) connected', re.MULTILINE)
    
    # Regex to find the EDID within a block
    edid_regex = re.compile(r'EDID:\s+((?:\t\t[0-9a-fA-F]+\n?)+)', re.MULTILINE)

    results : Dict[str, str] = {}

    # Find all port blocks
    ports = port_block_regex.findall(output)

    for port in ports:
        # Find the block for this port
        port_start = output.find(port)
        next_port_start = len(output)
        for other_port in ports:
            pos = output.find(other_port, port_start + 1)
            if 0 < pos < next_port_start:
                next_port_start = pos
        port_block = output[port_start:next_port_start]

        # Search for the EDID within this block
        edid_match = edid_regex.search(port_block)
        if edid_match:
            edid_raw = edid_match.group(1)
            # Clean and format the EDID data
            edid = ''.join(edid_raw.split())
            results[edid] = port

    return results

def modify_env_file(env_file_path: str, changes: Dict[str, str]) -> None:
    # Read the .env file
    with open(env_file_path, 'r') as file:
        lines = file.readlines()

    # Modify the specified lines
    for i, line in enumerate(lines):
        for key, value in changes.items():
            if line.startswith(key + '='):
                lines[i] = f'{key}={value}\n'

    # Write the changes back to the .env file
    with open(env_file_path, 'w') as file:
        file.writelines(lines)

if __name__ == '__main__':
    popen = os.popen('autorandr --change').read()
    profiles = AutoXrandrOutputs.create_from_autorandr_output()
    profile_config = create_from_json(json.load(open(SCREEN_CONFIG)))
    xrandr_output_str = os.popen('xrandr --verbose').read()
    xrandr_output = parse_xrandr_output(xrandr_output_str)

    choosen_profiles = [profile for profile in profiles.profiles if profile.current]
    if len(choosen_profiles) == 0:
        choosen_profiles = [profile for profile in profiles.profiles if profile.detected]
        
    choosen_profile = choosen_profiles[0]
    choosen_profile_name = choosen_profile.name
    choosen_profile_config = profile_config.profiles[choosen_profile_name]

    screen1_port = xrandr_output[choosen_profile_config.screen1]
    if choosen_profile_config.screen2:
        screen2_port = xrandr_output[choosen_profile_config.screen2]
    else:
        screen2_port = screen1_port

    if choosen_profile_config.screen3:
        screen3_port = xrandr_output[choosen_profile_config.screen3]
    else:
        screen3_port = screen2_port

    changes = {
        'SCREEN_1': screen1_port,
        'SCREEN_2': screen2_port,
        'SCREEN_3': screen3_port,
    }
    # Write the environment variables
    modify_env_file(I3_ENV, changes)