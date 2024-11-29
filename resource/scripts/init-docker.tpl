#cloud-config

runcmd:
  - apt-get update -y
  - echo "Hello World. The time is now $(date -R)!" | tee /root/output.txt
  # Install required packages
  - apt-get install -y apt-transport-https ca-certificates curl software-properties-common lsb-release git net-tools ufw nmap
  # - apt install iptables-persistent
  # Install and configure chrony for NTP synchronization
  - apt-get install -y chrony && timedatectl set-timezone Asia/Seoul && systemctl enable chrony && systemctl start chrony && chronyc tracking
  # install docker
  - mkdir -p /etc/apt/keyrings
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io
  # Install Docker Compose
  - sudo curl -L "https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  - sudo chmod +x /usr/local/bin/docker-compose
  # Start and enable Docker service
  - sudo systemctl start docker
  - sudo systemctl enable docker
  # Git login
  - docker login ghcr.io -u having-dlrow -p ${docker_secret_key}