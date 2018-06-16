# sights
open a doll for friends under the wall to see outside world.

# what it do
## search any youtube vedio
- keyword filter(do not accept any keyword that is harmful like porn, sex)
- display the searched content in friendly UI
## download it to server for temp usage (will be deleted by LRU policy when disk is full)
## make a stream api to display the vedio in H5 supported browsers

# structure
## api gateway
## dashboard
## database
  video table(keyword, video_name, youtube_url, stored_path, size, downloaded_times, last_downloaded_time, deleted, deleted_time)
  
## logs
- access.log
 - time, ip, keyworld, video name, watched 
- error.log
 - time, error

