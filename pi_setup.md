```bash
# Get the latest updates
sudo apt update && sudo apt upgrade

# Install xvfb for a virtual x11 display
sudo apt install xvfb

# Install git
sudo apt install git
```

# Copy the ssh keys from 1password

```bash
nano .ssh/id_rsa
nano .ssh/id_rsa.pub
chmod 400 ~/.ssh/id_rsa
```

# Clone the repo

```bash
git clone git@github.com:drummel/ofosho_ledcontroller.git
```

# Download processing from https://processing.org/download

```bash
# This might work too
sudo apt-get install processing


wget https://github.com/processing/processing4/releases/download/processing-1293-4.3/processing-4.3-linux-arm64.tgz
tar xvfz processing-*
```

# Append my wadnering wifi configuration

```bash
sudo cat ./setup/append_to_wpa_supplicant.conf >> /etc/wpa_supplicant/wpa_supplicant.conf
```

# Install the service

````bash
sudo cp ./setup/ofosho_sign.service /etc/systemd/system/ofosho_sign.service
sudo systemctl daemon-reload
sudo systemctl enable ofosho_sign.service
sudo systemctl start ofosho_sign.service

# Get the status of the service
```bash
sudo systemctl status altar-of-oba.service
````

## Restart the raspberry pi

```bash
sudo reboot
```

## Get the raspberry pi's make and model

```bash
cat /proc/device-tree/model
```
