#!/bin/bash
rsync -avz --delete \
  -e "ssh -p 65002 -o StrictHostKeyChecking=no" \
  /opt/projects/rollingcat-website/ \
  u349700627@46.202.158.52:~/domains/rollingcatsoftware.com/public_html/ \
  --exclude .git --exclude .github --exclude deploy.sh --exclude ROADMAP.md --exclude TODO.md \
  --exclude docs --exclude CLAUDE.md --exclude README.md --exclude .claude
echo "Deployed rollingcatsoftware.com"
