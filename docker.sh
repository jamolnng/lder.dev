docker stop lder
docker rm lder
JEKYLL_ENV=production bundle exec jekyll b
docker build -t lder .
docker run -v $PWD/_site:/usr/share/nginx/html --name lder -dp 3000:80 lder