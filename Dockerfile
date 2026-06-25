# rollingcatsoftware.com — static site served by nginx behind Traefik.
# Migrated off Hostinger (plan cancelled 2026-06) onto the Hetzner box.
FROM nginx:1.27-alpine

# Replace the default server block with our site config.
RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/rollingcat.conf

# Copy the site, then drop repo/dev files that must not be web-served.
COPY . /usr/share/nginx/html
RUN cd /usr/share/nginx/html && rm -rf \
    Dockerfile nginx.conf docker-compose.prod.yml .dockerignore \
    deploy.sh CLAUDE.md README.md ROADMAP.md TODO.md LICENSE \
    docs .github .gitignore .htaccess

EXPOSE 80
