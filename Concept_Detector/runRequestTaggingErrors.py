import os
from glob import glob
import ntpath
from requests.auth import HTTPBasicAuth
from RequestTagging import requestTagging as req


def main():
	# Data parameters
	path_images = '%folder_path%'
	
	errors_file = '%errors_file%'

	# Imagga server parameters
	endpoint = '%endpoint%'
	api_key = '%api_key%'
	api_secret = '%api_secret%'

	# Result parameters
	path_result = '%result_path%'

	auth = HTTPBasicAuth(api_key, api_secret)
	
	with open(errors_file) as f:
		content = f.readlines()
		nLines = len(content)
		for i in range(nLines):
			split = content[i].find(' ')
			folder = content[i][0:split]
			image = content[i][split+1:len(content[i])-1]
			
			result_dir = path_result + '/' + folder
			
			img_path = glob(path_images + '/' + folder + '/' + image)
			
			# Upload Image and get JSON tagging result
			tags = req(img_path[0], auth, endpoint)
			
			# Post-process JSON data
			tags = postProcessJSON(tags)
			
			# Store data
			text_file = open(result_dir + '/' + image + '.json', "w")
			text_file.write("%s" % tags)
			text_file.close()
	
	print "Done"

def byteify(input):
    if isinstance(input, dict):
        return {byteify(key):byteify(value) for key,value in input.iteritems()}
    elif isinstance(input, list):
        return [byteify(element) for element in input]
    elif isinstance(input, unicode):
        return input.encode('utf-8')
    else:
        return input
    
def findOccurences(s, ch):
    return [i for i, letter in enumerate(s) if letter == ch]

def postProcessJSON(tags):
    tags2 = byteify(tags)
    t = str(tags2)
    t2 = list(t)
    pos = findOccurences(t, "'")
    for i in range(len(pos)):
        t2[pos[i]] = '"'
    tags2 = "".join(t2)
    return tags2

main()
