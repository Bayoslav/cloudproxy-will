#!/bin/bash
sudo apt-get -y update
sudo apt-get install -y ca-certificates tinyproxy
sudo sed -i 's/Port 8888/Port 8899/g' /etc/tinyproxy/tinyproxy.conf
sudo sed -i 's/Allow 127.0.0.1/#Allow 127.0.0.1/g' /etc/tinyproxy/tinyproxy.conf
sudo sed -i 's/Allow ::1/#Allow ::1/g' /etc/tinyproxy/tinyproxy.conf
sudo sed -i 's/#BasicAuth user pass.*/BasicAuth username password/g' /etc/tinyproxy/tinyproxy.conf
sudo sed -i 's/#DisableViaHeader Yes/DisableViaHeader Yes/g' /etc/tinyproxy/tinyproxy.conf
sudo systemctl restart tinyproxy
sudo ufw default deny incoming
sudo ufw allow 22/tcp
sudo ufw allow 8899/tcp
sudo ufw --force enable
eval "$(ssh-agent -s)"
ssh-add /home/ubuntu/.ssh/id_ed25519
ssh -o StrictHostKeyChecking=no root@ip
ssh -T git@github.com
git config --global --add safe.directory /home/ubuntu/Willhaben_v2
source /home/ubuntu/venv/bin/activate
cd /home/ubuntu/Willhaben_v2/
git pull origin celery
pip install -r requirements.txt
python3 -m celery -A celery_handle_url worker --loglevel=INFO -n $(hostname -i) -Q $(hostname -i) --concurrency=1 --prefetch-multiplier=1
