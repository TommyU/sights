# sights
open a doll for friends under the wall to see outside world.

# what it do
## search any youtube video
- keyword filter(do not accept any keyword that is harmful like porn, sex)
- display the searched content in friendly UI
## download it to server for temp usage (will be deleted by LRU policy when disk is full)
## make a stream api to display the vedio in H5 supported browsers

# structure
## api gateway
- search by keyword ( will get it from local cache first if not then get it from google and cache it for 7 days)
	- keyword filtering
	- keyword statics (into db)

- download video 
	- will trigger a cronjob to download the video by youtube-dl in the background
	- duplicated requests is allowed
- watch the video
	- will trigger video downloading if not downloaded
	- will get video stream from server (with rate limit)

## website
- will display something in main page
	- a search button
	- a video list
	- a watch button on each video(with status bar)

## dashboard
- will show disk usage
	- if not enough disk, will trigger the GC to delete some video by LRU rule
- will show downloaded video list
- will show pv/uv

## database
  video table(keyword, video_name, youtube_url, stored_path, size, downloaded_times, last_downloaded_time, deleted, deleted_time)
## redis cache
  quick_search{keyword:youtube_url} 7days timeout
    
## logs
- access.log
 - time, ip, keyworld, video name, watched 
- error.log
 - time, error

