# firebase_upload.py

import json
import firebase_admin
from firebase_admin import credentials, storage, firestore
import os
import time
import argparse

cred = credentials.Certificate("/home/hover-squad/senior_design/agrivoltaics-flutter-firebase-firebase-adminsdk-hjxij-8f18dca8b1.json")
firebase_admin.initialize_app(cred, {
    'storageBucket': 'agrivoltaics-flutter-firebase.firebasestorage.app'
})

db = firestore.client()
bucket = storage.bucket()

print("HERE")
print(bucket.name)


def upload_folder_to_firebase(local_folder, capture_id=None):
    if not os.path.isdir(local_folder):
        raise ValueError(f"{local_folder} is not a valid directory.")

    capture_id = capture_id or os.path.basename(local_folder)
    response_path = f"{local_folder}/response.json"

    doc_ref = db.collection('captures').document(capture_id)

    print(f"📂 Uploading {local_folder} to Firebase...")

    image_urls = {}
    for filename in os.listdir(local_folder):
        if not filename.endswith(".jpg") or not filename.endswith(".png"):
            continue
        local_path = os.path.join(local_folder, filename)
        remote_path = f"captures/{capture_id}/{filename}"

        blob = bucket.blob(remote_path)
        blob.upload_from_filename(local_path)
        blob.make_public()  #or use getDownloadURL + token handling if private
        print(f"✅ Uploaded: {filename} → {blob.public_url}")
        image_urls[filename] = blob.public_url

    #load the Vision API response from JSON
    with open(response_path, "r", encoding="utf-8") as f:
        vision_data = json.load(f)
    
    #validate it contains the expected key
    if "response" not in vision_data:
        raise KeyError(f"Missing 'response' key in {response_path}")
    
    analysis = vision_data["label"]
    label = True if analysis == "1" or analysis == 1 else False

    #Write metadata
    doc_ref.set({
        "timestamp": firestore.SERVER_TIMESTAMP,
        "url": list(image_urls.values()),
        "detected_disease": label,
        "analysis": analysis
    })

    print("Upload complete + Firestore entry created.")

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Upload images and AI analysis")
    parser.add_argument("--folder", type=str, required=True,
                        help="Path to the aligned images folder")

    args = parser.parse_args()

    input_folder = args.folder

    upload_folder_to_firebase(input_folder)
