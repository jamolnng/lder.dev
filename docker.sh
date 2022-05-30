docker stop lder
docker rm lder
JEKYLL_ENV=production bundle exec jekyll b
docker build -t lder .
docker run --name lder -dp 3000:80 lder