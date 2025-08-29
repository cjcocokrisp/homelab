# 01 - OS Installation

This directory explains how to onboard a new node into the cluster. This is assuming the node wants to run Kubernetes. This document will cover flashing the OS onto the device.

## Prerequisites

For this you must have the homelab repo cloned and Python installed on your machine to run the ignition generator. You also must have a USB to flash the Core OS installer onto.

SSH keys must also be created already, the script will allow you to type in the filename for it to select one so make sure you have that noted.

## Step 1: Generate Ignition

For easier set up, I have created a script that can generate ignition files. These files are configuration that is applied on first boot. The script is located at `bootc/ignition_genrator.py` and requires you to have Python installed on your system. The script will ask for an SSH key to add to make it easier to connect so it is recommended to generate an SSH key on your machine that you will use to connect to it. 

A password is also supplied for the time being but eventually I plan to make it so the script can autogenerate an SSH key.

To run the script you will need to install the Python dependencies as well. This can be done by creating a virtual environment or just installing with pip. The commands below assume you are at the root of the homelab repo.

```bash
# How to generate an Config file
# Set up venv
python3 -m venv .venv

# Enter venv
source ./.venv/bin/activate

# Install dependencies
pip install -r bootc/requirements.txt

# Generate Ignition
python3 bootc/config_generator.py
```

The script will also generate the butane yaml file as well so if you would like to edit or use that. 

## Step 2: Flash a USB with Live ISO

The next step is to flash the Core OS Installer ISO onto a USB. The ISO can be found on the [Fedora website](https://fedoraproject.org/coreos/download?stream=stable). Download it and flash it onto the USB. 

After flashing the ISO, boot into the Core OS ISO that you flashed. You should see a command line.

## Step 3: Start Serving Ignition

To be able to access the ignition file you generated you need to serve it on the machine that it was generated on. This is easy with a Python command. Navigate to the directory in which the ignition file lives and then run the below command:

```bash
python -m http.server
```

The above command will serve the directory it was ran in. Take note of your computers IP address on your local network for the next step. 

## Step 4: Install Ignition

Ensure that the node you are onboarding is connect to your lan through a wired connect or set up wireless. Run the following command to install Core OS with the ignition. 

```bash
sudo coreos-installer install /dev/sda \
     --ignwition-url http://<DEVICE-HOSTING-IGNITION-IP>:8000/<WHAT-YOU-CALLED-THE-FILE>.ign --insecure-ignition
```

This will install Core OS, once it's complete reboot the machien and go into the Core OS installation.

## Step 5: Bootc

Once rebooting the machine allow it to run for some time. There is systemd service that will bootc switch into Fedora with all of the packages needed for the homelab. Once that is complete the machine will automatically reboot and you will be able to proceed.

## Conclusion

With this completed you can move on to setting up the Talos Linux VMs to continue onboarding.

## Improvements to Make

Below are some improvements I want to make to this page and process in general. 

#### Actual Process 

[ ] - More rebust ignition generator script that can read .ssh directory and generate keys

[ ] - Steps to bake ignition into the ISO

#### Docs Page

[ ] - Screenshots 

[ ] - Installations for tools used here