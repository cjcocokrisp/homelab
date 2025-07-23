# 01: OS Installation with bootc

The following file explains the first set in onboarding a new node into the homelab. This is assuming that the node wants to run Kubernetes and be a node in the cluster. This document will cover flashing the OS and setting up bootc.

## Prerequisites

You must have Podman Desktop installed on your computer with the bootc extension. The extension can be easily found on the catalog of the extensions page of the site. This entire tutorial will be done with Podman Desktop for the convience it provides.  

Also create an SSH key for your system. As of right now the config generator script only supports ed25519 scheme keys. In the future I plan to make the script better to select SSH keys that are created and on top of that generate them. 

Also clone the repository for this homelab. The url should be https://www.github.com/cjcocokrisp/homelab.git

## Step 1: Build Container Image

The first step of building the ISO for the node is building the container image. Go to the "Image" tab on Podman Desktop then select the build button.

For the Containerfile Path select the directory where you cloned this repo and have it point to the `bootc` directory in it. 

You can set an image name if you would like.

Once all the information has been filled out click the build button and wait for the image to build. 

## Step 2: Generate a Config File

For easier set up, I have created a script that can generate config files. These files are configuration that is applied on first boot when using bootc-image-builder. The script is located at `bootc/config_genrator.py` and requires you to have Python installed on your system. The script will look for an SSH key to add to make it easier to connect so it is recommended to generate an SSH key on your machine that you will use to connect to it. 

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

Once generated the file will appear in whatever directory you ran the script in.

## Step 3: Build the ISO

The next step of the process is to build the ISO for the image. This can be done by clicking ont he bootable containers extension in Podman Desktop on the left side bar. Then select the Disk Image tab and the build button. 

First select the container that you just build and select the Disk image type of "Unattended Anaconda ISO Installer (.iso)." and select your output folder. 

Next select the "Build config file" tab and then select the json that you just generated with the script. 

Once all of that is done press build and it will begin to build the ISO. Do not that this will take a good amount of resources on your computer so it probably will function very slow. 

## Step 4: Flash the ISO

The next step is simple and it is just to flash the ISO onto a flash drive. I have tried using something like ventoy and that did not work so make sure you actually flash it.

## Step 5: Install

The final step is installing the OS onto the actual hardware. This is a really easy step and all you need to do is boot into the usb and it all should be handled for you. 

## Step 6: Set System Hostname & Static IP

As of right now the hostname for the machine is not automatically. You can do this by adding the desired name into the `etc/hostname` file. You can log into your system through SSH or you can plug a keyboard and monitor in and work with it through that.

Another thing to note is that you should set a static IP address on your network for a device you plan to use as a node. 

## Conclusion

And with this your node's host OS is set up. The next steps are unknow and this will be updated when I have the next steps and other information that you need for this. 

## Improvements to Make

Below are some improvements I want to make to this page and process in general. 

#### Actual Process 

[ ] - Actual hostname configuration through bootc

[ ] - More rebust config generator script that can read .ssh directory and generate keys

#### Docs Page

[ ] - Screenshots 

[ ] - Installations for tools used here
