ls images | xargs -I {} sh -c "if [ ! -f renders/{}.png ]; then montage images/{}/*.png -tile 3x3 -geometry +0+0 -background none renders/{}.png; fi"
for f in renders/*.png; do
  filename=$(basename $f .JPG)
  convert $f -fill white -pointsize 30 -gravity NorthWest -draw "text 10,10 '$(node date.js $filename)'" -pointsize 20 -draw "text 10,50 'CIRA GeoColor, NASA GOES-16 Satellite'" overlay/$filename
done
