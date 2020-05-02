.PHONY: all
all: cp TALB TCON

# copy files
.PHONY: cp
cp:
	cp "/home/aaronf/Music/Data Skeptic/plastic-bag-bans.mp3" .
	cp "/home/aaronf/Music/Data Skeptic/self-driving-cars-and-pedestrians.mp3" .
	cp "/home/aaronf/Music/Freakonomics Radio/How_Do_You_Reopen_a_Country.mp3" .
	cp "/home/aaronf/Music/Planet Money/20200429_pmoney_pmpod995-6a6d5285-33f5-4d0c-bbe4-d44c6321a8b9.mp3_30770077bf5c03a5b5571ec84ad3099c_22363916.mp3" .
	cp "/home/aaronf/Music/Pod Save America/DGT3248521238.mp3" .
	cp "/home/aaronf/Music/Reply All/GLT3665260655.mp3" .
	cp "/home/aaronf/Music/Santa Cruz Local/Ep 73 Dr. Catherine Sondquist Forest answers COVID FAQs.mp3" .
	cp "/home/aaronf/Music/Santa Cruz Local/Ep2_Draft 3.mp3" .
	cp "/home/aaronf/Music/Software Engineering Daily/2020_04_20_ZoomVulnerability.mp3" .

# set album (TALB)
.PHONY: TALB
TALB:
	id3v2 --TALB "Data Skeptic" "plastic-bag-bans.mp3"
	id3v2 --TALB "Data Skeptic" "self-driving-cars-and-pedestrians.mp3"
	id3v2 --TALB "Freakonomics Radio" "How_Do_You_Reopen_a_Country.mp3"
	id3v2 --TALB "Planet Money" "20200429_pmoney_pmpod995-6a6d5285-33f5-4d0c-bbe4-d44c6321a8b9.mp3_30770077bf5c03a5b5571ec84ad3099c_22363916.mp3"
	id3v2 --TALB "Pod Save America" "DGT3248521238.mp3"
	id3v2 --TALB "Reply All" "GLT3665260655.mp3"
	id3v2 --TALB "Santa Cruz Local" "Ep 73 Dr. Catherine Sondquist Forest answers COVID FAQs.mp3"
	id3v2 --TALB "Santa Cruz Local" "Ep2_Draft 3.mp3"
	id3v2 --TALB "Software Engineering Daily" "2020_04_20_ZoomVulnerability.mp3"

# set content type (TCON)
.PHONY: TCON
TCON:
	id3v2 --TCON Podcast "plastic-bag-bans.mp3"
	id3v2 --TCON Podcast "self-driving-cars-and-pedestrians.mp3"
	id3v2 --TCON Podcast "How_Do_You_Reopen_a_Country.mp3"
	id3v2 --TCON Podcast "20200429_pmoney_pmpod995-6a6d5285-33f5-4d0c-bbe4-d44c6321a8b9.mp3_30770077bf5c03a5b5571ec84ad3099c_22363916.mp3"
	id3v2 --TCON Podcast "DGT3248521238.mp3"
	id3v2 --TCON Podcast "GLT3665260655.mp3"
	id3v2 --TCON Podcast "Ep 73 Dr. Catherine Sondquist Forest answers COVID FAQs.mp3"
	id3v2 --TCON Podcast "Ep2_Draft 3.mp3"
	id3v2 --TCON Podcast "2020_04_20_ZoomVulnerability.mp3"

# set title (TIT2) - not auto-run, to be manually modified
.PHONY: TIT2
TIT2:
	false
	id3v2 --TIT2 "title" "plastic-bag-bans.mp3"
	id3v2 --TIT2 "title" "self-driving-cars-and-pedestrians.mp3"
	id3v2 --TIT2 "title" "How_Do_You_Reopen_a_Country.mp3"
	id3v2 --TIT2 "title" "20200429_pmoney_pmpod995-6a6d5285-33f5-4d0c-bbe4-d44c6321a8b9.mp3_30770077bf5c03a5b5571ec84ad3099c_22363916.mp3"
	id3v2 --TIT2 "title" "DGT3248521238.mp3"
	id3v2 --TIT2 "title" "GLT3665260655.mp3"
	id3v2 --TIT2 "title" "Ep 73 Dr. Catherine Sondquist Forest answers COVID FAQs.mp3"
	id3v2 --TIT2 "title" "Ep2_Draft 3.mp3"
	id3v2 --TIT2 "title" "2020_04_20_ZoomVulnerability.mp3"

# clean
.PHONY: clean
clean:
	rm -f "plastic-bag-bans.mp3"
	rm -f "self-driving-cars-and-pedestrians.mp3"
	rm -f "How_Do_You_Reopen_a_Country.mp3"
	rm -f "20200429_pmoney_pmpod995-6a6d5285-33f5-4d0c-bbe4-d44c6321a8b9.mp3_30770077bf5c03a5b5571ec84ad3099c_22363916.mp3"
	rm -f "DGT3248521238.mp3"
	rm -f "GLT3665260655.mp3"
	rm -f "Ep 73 Dr. Catherine Sondquist Forest answers COVID FAQs.mp3"
	rm -f "Ep2_Draft 3.mp3"
	rm -f "2020_04_20_ZoomVulnerability.mp3"

