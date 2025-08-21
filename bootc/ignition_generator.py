"""
Python Script to create an ignition with butane.
Outputs the Butune YAML & Ignition JSON.
You must have Podman installed for this script to run/
You must have an SSH key generated before hand.
"""

# TODO: Generate an SSH key if one doesn't exist
# TODO: Make setting password optional
# TODO: Better output scheme
# TODO: Configurable systemd units by reading from a file

from maskpass import askpass
from passlib.hash import sha512_crypt
import yaml
import os


def create_butane_file(filename: str) -> None:
    butane = {
        "variant": "fcos",
        "version": "1.6.0",
        "passwd": {"users": []},
        "storage": {"files": []},
        "systemd": {
            "units": [
                {
                    "name": "bootc-switch.service",
                    "enabled": True,
                    "contents": (
                        "[Unit]\n"
                        "Description=Switch to bootc image to disk, then reboot\n"
                        "Wants=network-online.target\n"
                        "After=network-online.target\n"
                        "ConditionPathExists=!/etc/bootc-switched.stamp\n\n"
                        "[Service]\n"
                        "Type=oneshot\n"
                        "Environment=IMGREF=ghcr.io/cjcocokrisp/homelab-fedora-bootc:latest\n"
                        "ExecStartPre=/usr/bin/bootc switch ${IMGREF}\n"
                        "ExecStart=/usr/bin/touch /etc/bootc-switched.stamp\n"
                        "ExecStartPost=/usr/bin/systemctl --no-block reboot\n\n"
                        "[Install]\n"
                        "WantedBy=multi-user.target"
                    ),
                },
            ]
        },
    }

    hostname = input("Enter a hostname for the device: ")
    username = input("Enter a username for the device: ")
    password = askpass("Enter a password: ")
    verify = None
    while verify != password:
        verify = askpass("Verify entered password: ")
    hashed_pswd = sha512_crypt.hash(password)

    home_dir = os.path.expanduser("~")
    ssh_dir = os.path.join(home_dir, ".ssh")
    print(f"The following prompt will ask about SSH keys.\nThe script will be looking in the directory {ssh_dir}")
    ssh_file = (input("Enter the name for the SSH key to copy (Do not include .pub): ") + ".pub")

    ssh_file_path = os.path.join(ssh_dir, ssh_file)
    ssh_pub_key = None
    with open(ssh_file_path, "r") as f:
        ssh_pub_key = f.readline()
        ssh_pub_key = ssh_pub_key.replace("\n", "")

    butane["passwd"]["users"].append({
        "name": username,
        "password_hash": hashed_pswd,
        "ssh_authorized_keys": [ ssh_pub_key ],
        "groups": [ "wheel" ]
    })

    butane["storage"]["files"].append({
        "path": "/etc/hostname",
        "mode": 0o644,
        "contents": {
            "inline": hostname
        }
    })

    with open(filename + ".bu", "w") as f:
        yaml.dump(butane, f, sort_keys=False)
    print(f"Butane file output at {os.getcwd()}/{filename}.bu")

print("Ignition Generator")
filename = input("Enter a filename to use: ")
create_butane_file(filename)

command = f"podman run -i --rm quay.io/coreos/butane:release --strict < {filename}.bu > {filename}.ign"
exit_code = os.system(command)

if exit_code == 0:
    print(f"Ignition ouput at {os.getcwd()}/{filename}.ign")
else: 
    print("Failed to create ignition")