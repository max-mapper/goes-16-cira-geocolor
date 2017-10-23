rm -rf movietmp
mkdir movietmp
ls overlay | tail -n -96 | xargs -I {} cp overlay/{} movietmp
ffmpeg -y -r 5 -pattern_type glob -i 'movietmp/*.png' -vf scale=2034:-1 -vcodec libx264 -crf 25 24hrs.mp4
