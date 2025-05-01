from flask import Flask, request
import subprocess
import os

app = Flask(__name__)

@app.route('/ping')
def ping():
    return 'pong', 200

@app.route('/start-capture', methods=['POST'])
def start_capture():
    mode = request.args.get('mode', 'single')  #default to single if not provided

    if mode not in ['single', 'continuous']:
        return 'Invalid mode. Use ?mode=single or ?mode=continuous', 400

    print(f"Starting capture pipeline in {mode.upper()} mode...")

    try:
        subprocess.Popen([
            "python3",
            "/home/hover-squad/senior_design/start_pipeline.py",
            "--mode", mode
        ])
        return f'Capture pipeline started in {mode} mode', 200
    
    except Exception as e:
        print("Failed to start capture:", e)
        return f'Failed to start capture: {e}', 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
