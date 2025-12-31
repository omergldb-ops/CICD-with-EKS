from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "status": "success",
        "message": "Hello from DevOps EKS Pipeline!",
        "environment": os.getenv("ENV", "production")
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    # Professional apps use 0.0.0.0 to be accessible inside Docker
    app.run(host='0.0.0.0', port=5000)