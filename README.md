# Dockerfile for Valhalla

This Dockerfile provides an easy way to build and deploy Mapzen's Valhalla,
without configuring a full Chef install.

This image does not have any map data included.

Run `fetch-repos.sh` to pull down each Valhalla component into its own
subdirectory. You can run this again any time to pull master and any
submodules.

To build and run the Docker image:

```sh
docker build -t valhalla .  # needs >2GB memory
```

Example with Liechtenstein osm.pbf file as this comes with the tyr repo. Get other map extracts from http://download.geofabrik.de/north-america.html. Preprocess OSM data:

```sh
# docker run -it -v ${DATA_OSM}:/valhalla/maps -v $PWD/data_valhalla:/data/valhalla valhalla pbfadminbuilder -c conf/valhalla.json maps/liechtenstein-latest.osm.pbf
docker run -it -v ${DATA_OSM}:/valhalla/maps -v $PWD/data_valhalla:/data/valhalla valhalla pbfgraphbuilder -c conf/valhalla.json maps/liechtenstein-latest.osm.pbf
```

Run:

```sh
docker run -d -p 8002:8002 --name valhalla -v ${DATA_OSM}:/valhalla/maps -v $PWD/data_valhalla:/data/valhalla valhalla:latest tools/tyr_simple_service conf/valhalla.json

# test
curl localhost:8002  # might have to replace 'localhost' with ip of virtual machine
# which returns "Try any of: '/locate' '/route' '/one_to_many' '/many_to_one' '/many_to_many'"

# test route in Liechtenstein
curl 'http://192.168.99.100:8002/route?json=\{"locations":\[\{"lat":47.14530,"lon":9.51976\},\{"lat":47.17051,"lon":9.51703\}\],"costing":"auto"\}'

# test route California
curl 'http://192.168.99.100:8002/route?json=\{"locations":\[\{"lat":37.78052,"lon":-122.40820\},\{"lat":37.72188,"lon":-122.38933\}\],"costing":"auto"\}'

# test route New York
curl 'http://192.168.99.100:8002/route?json=\{"locations":\[\{"lat":40.7532,"lon":-73.9765\},\{"lat":40.70361,"lon":-74.01614\}\],"costing":"auto"\}'

# to debug (with the demonized docker container above running)
docker exec -it valhalla bash
docker logs valhalla
```
