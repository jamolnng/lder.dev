docker stop lder
docker rm lder
sh ./build.sh
docker build -t lder .
docker run -v $PWD/_site:/usr/share/nginx/html --name lder -dp 80:80 lder