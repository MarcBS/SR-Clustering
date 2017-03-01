import os
import ntpath

def main():

	# Data parameters
	path_images = '%folder_path%'
	folders = ['%folder_name%']
	formats = ['%format%']

	# Result parameters
	path_result = '%result_path%'

    ## Apply on each image
	nFolders = len(folders)
	for f in range(nFolders):

	    # Create results directory
	    result_dir = path_result + '/' + folders[f]
	    if not os.path.exists(result_dir):
	        os.makedirs(result_dir)

        list_imgs = glob(path_images + '/' + folders[f] + '/*' + formats[f])

        # TODO: Obtain  data from bash

        for i in range(len(list_imgs)):

            img_name = ntpath.basename(list_imgs[i])

    		if not os.path.isfile(result_dir + '/' + img_name + '.json'):

    			# Store data
    			text_file = open(result_dir + '/' + img_name + '.json', "w")
    			text_file.write("%s" % tags)
    			text_file.close()

	    print "Processed folder " + folders[f]

	print "Done"
