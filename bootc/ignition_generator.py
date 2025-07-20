"""
Python script to generate ignition files.
You can set env variables to already have stuff pre configured.
You must have an SSH key generated before starting and it must be 
called id_ed25519.
"""

# TODO: Generate an SSH key if one doesn't exist 
# TODO: Make setting password optional
# TODO: Better output scheme

from passlib.hash import sha512_crypt
from maskpass import askpass
import subprocess
import json
import os

def get_env_with_input_default(envvar: str) -> str:
    value = None
    if envvar not in os.environ:
        value = input(f'Enter a {envvar.lower()}: ')
    else:
        value = os.getenv(envvar)
    
    return value

ignition = {
    'ignition': {
        'version': '3.4.0'
    },
    'storage': {
        'files': []
    },
    'passwd': {
        'users': []
    }
}

print('Ignition Generator')

# get needed information
HOSTNAME = get_env_with_input_default('HOSTNAME')    
USERNAME = get_env_with_input_default('USERNAME')

PASSWORD = None
if 'PASSWORD' not in os.environ:
   PASSWORD = askpass('Enter a password: ')
   verify = None
   while verify != PASSWORD:
       verify = askpass('Verify your password: ') 

# hash password
hashed_password = sha512_crypt.hash(PASSWORD)

# get ssh key, must be generated before hand
home_dir = os.path.expanduser('~')
file_path = os.path.join(home_dir, '.ssh', 'id_ed25519.pub')
ssh_pub_key = None

with open(file_path, 'r') as f:
    ssh_pub_key = f.readline()
    ssh_pub_key = ssh_pub_key.replace('\n', '')

# insert/dump to ignition
ignition['storage']['files'].append({
    'path': '/etc/hostname',
    'mode': 420,
    'overwrite': True,
    'contents': { 'source': f'data:,{HOSTNAME}\n' }
})

ignition['passwd']["users"].append({
    'name': USERNAME,
    'passwordHash': hashed_password,
    'sshAuthorizedKeys': [ ssh_pub_key ]
})

with open(f'{HOSTNAME}.ign', 'w') as f:
    json.dump(ignition, f, indent=2)
