import requests
	
def requestTagging(img_path, auth, endpoint):
	# Open the desired file
	with open(img_path, 'r') as image_file:
	    filename = image_file.name

	    # Upload the multipart-encoded image with a POST
	    # request to the /content endpoint
	    content_response = requests.post(
	        '%s/content' % endpoint,
	        auth=auth,
	        files={filename: image_file})

	    # Example /content response:
	    # {'status': 'success',
	    #  'uploaded': [{'id': '8aa6e7f083c628407895eb55320ac5ad',
	    #                'filename': 'example_image.jpg'}]}
	    uploaded_files = content_response.json()['uploaded']

	    # Get the content id of the uploaded file
	    content_id = uploaded_files[0]['id']

	# Using the content id and the content parameter,
	# make a GET request to the /tagging endpoint to get
	# image tags
	tagging_query = {'content': content_id}
	tagging_response = requests.get(
	    '%s/tagging' % endpoint,
	    auth=auth,
	    params=tagging_query)

	return tagging_response.json()
