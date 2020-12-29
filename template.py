import cv2
import json

def lambda_handler(event, context):
    # TODO implement
    print("OpenCV installed version:", cv2.__version__)
    return {
        'statusCode': 200,
        'body': json.dumps(str(cv2.__version__))
    }

