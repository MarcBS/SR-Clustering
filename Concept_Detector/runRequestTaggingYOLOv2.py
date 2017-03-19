import os
import subprocess
import ntpath
from glob import glob


# Data parameters
path_images = '%folder_path%'
folders = ['%folder_name%']
formats = ['%format%']

# Result parameters
path_result = '%result_path%'

# Framework directory
os.chdir("/home/marcvaldivia/code/darknet")

## Apply on each image
nFolders = len(folders)
for f in range(nFolders):

    # Create results directory
    result_dir = path_result + '/' + folders[f]
    if not os.path.exists(result_dir):
        os.makedirs(result_dir)

    list_imgs = glob(path_images + '/' + folders[f] + '/*' + formats[f])
    list_imgs = sorted(list_imgs)

    for i in range(len(list_imgs)):

        img_name = ntpath.basename(list_imgs[i])

        if not os.path.isfile(result_dir + '/' + img_name + '.json'):

            # Execute yolo9000
            image_path = path_images + '/' + folders[f] + '/' + img_name
            bashCommand = 'bash runv2.sh ' + image_path
            process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()
            image_tags = output

            tag = image_tags[:-1] if image_tags[:-1] else '{"x": 0, "y": 0, "w": 0, "h": 0, "confidence": 0.9, "tag": "object"}'
            tags = '{"results": [{"tagging_id": None, "image": "asdf", "tags": [' + tag + ']}]}'

            # Store data
            text_file = open(result_dir + '/' + img_name + '.json', "w")
            text_file.write("%s" % tags)
            text_file.close()

    print "Processed folder " + folders[f]

print "Done"