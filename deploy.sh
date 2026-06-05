#!/bin/bash
rsync -avz --delete \
  -e "ssh -p 65002 -o StrictHostKeyChecking=no" \
  /opt/projects/rollingcat-website/ \
  u349700627@46.202.158.52:~/domains/rollingcatsoftware.com/public_html/ \
  --exclude .git --exclude deploy.sh --exclude ROADMAP.md --exclude TODO.md
echo "Deployed rollingcatsoftware.com"
