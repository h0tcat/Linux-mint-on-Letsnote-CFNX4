# -*- coding:utf-8 -*-

###########
# Import Package
###########
# 
import re, subprocess

# 3rd party
import requests

# 
url = 'https://github.com/shiftkey/desktop/releases'

# pattern
pattern = '<a href="[\w/]+release-\d\.\d\.\d-linux\d/(GitHubDesktop-linux-\d\.\d\.\d-linux\d.deb)"'

# 
response = requests.get(url=url)

# 
matches = re.search(pattern, response.text)

#
newestVersion = matches.group(1)

#
cmd = "dpkg -l | grep github-desktop"
result = subprocess.call(cmd)

print(result)