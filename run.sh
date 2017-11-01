#! /bin/sh

# check expected directory structure
[ -d images ]  || mkdir images
[ -d output ]  || mkdir output
[ -d overlay ] || mkdir overlay
[ -d renders ] || mkdir renders

echo "...downloading latest tiles..."
node index.js # downloads latest

echo "...deleting half-written files..."
find . -name "*.png" -size -1k -delete # if last ran exited w/ half written files

echo "...montaging tiles..."
ls images | xargs -I {} sh -c "if [ ! -f renders/{}.png ]; then montage images/{}/*.png -tile 3x3 -geometry +0+0 -background none renders/{}.png; fi"

echo "...adding date overlay to montaged frames..."
for f in renders/*.png; do
  filename=$(basename $f .JPG)
  if [ ! -f overlay/$filename ]; then
    convert $f -fill white -pointsize 30 -gravity NorthWest -draw "text 10,10 '$(node date.js $filename)'" -pointsize 20 -draw "text 10,50 'CIRA GeoColor, NASA GOES-16 Satellite'" overlay/$filename
  fi;
done

echo "...cleaning movietmp/..."
rm -rf movietmp
mkdir movietmp

echo "...rendering movie of most-recent 96 frames (last 24 hours)..."
ls overlay | tail -n -96 | xargs -I {} cp overlay/{} movietmp # only build last 96 (last 24 hours worth)
# yuv420p colorspace param needed to support "dumb" mediaplayers like quicktime
# ffmpeg -y -r 10 -pattern_type glob -i 'movietmp/*.png' -vf scale=1920:-1 -vcodec libx264 -pix_fmt yuv420p -crf 25 output/24hrs.mp4
ffmpeg -y -r 10 -pattern_type glob -i 'movietmp/*.png' -vf scale=2034:-1 -vcodec libx264 -pix_fmt yuv420p -crf 25 output/24hrs.mp4
cp index.html output/

echo "...done!"
# open output/index.html
