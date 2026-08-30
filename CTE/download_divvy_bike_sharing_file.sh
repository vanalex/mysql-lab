mkdir -p data

curl -L \
  https://divvy-tripdata.s3.amazonaws.com/202607-divvy-tripdata.zip \
  -o data/divvy.zip

unzip data/divvy.zip -d data/