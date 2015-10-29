import os
from glob import glob
import ntpath
from requests.auth import HTTPBasicAuth
from RequestTagging import requestTagging as req


def main():
	# Data parameters
	path_images = '%folder_path%'
	
	folders = ['%folder_name%']
	formats = ['%format%']

	# Imagga server parameters
	endpoint = '%endpoint%'
	api_key = '%api_key%'
	api_secret = '%api_secret%'

	# Result parameters
	path_result = '%result_path%'

	auth = HTTPBasicAuth(api_key, api_secret)
	
	## Apply on each image
	nFolders = len(folders)
	for f in range(nFolders):
	    
	    # Create results directory
	    result_dir = path_result + '/' + folders[f]
	    if not os.path.exists(result_dir):
	        os.makedirs(result_dir)
	    
	    list_imgs = glob(path_images + '/' + folders[f] + '/*' + formats[f])
	    nList = len(list_imgs)
	    ini = 0
		
	    for i in range(ini,nList):
			img_name = ntpath.basename(list_imgs[i])
				
			# Upload Image and get JSON tagging result
			tags = req(list_imgs[i], auth, endpoint)
				
			# Post-process JSON data
			tags = postProcessJSON(tags)
				
			# Store data
			text_file = open(result_dir + '/' + img_name + '.json', "w")
			text_file.write("%s" % tags)
			text_file.close()
			
			# Show progress
			if((i+1)%50 == 0 or (i+1) == nList):
			    print "Processed " + str(i)  +  "/" +  str(nList) + " images."

	    
	    print "Processed folder " + folders[f]

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
