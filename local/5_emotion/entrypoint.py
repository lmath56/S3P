import logging
from flask import Flask, request, jsonify
from transformers import pipeline
import torch

# Check if GPU is available and set the device accordingly
device = 0 if torch.cuda.is_available() else -1
print(f"Using device: {'cuda' if device == 0 else 'cpu'}")

# Load the classifier pipeline
model_path = "/app/models"
classifier = pipeline("text-classification", model=model_path, return_all_scores=True, device=device)
print("Model loaded successfully.")

print("Configuring the logger...")
# Configure the logger
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s %(levelname)s %(message)s',
    filename='app.log'
)

app = Flask(__name__)

@app.route("/chat", methods=["POST"])
def chat():
    print("Received a request...")
    try:
        # Get user prompt from request
        user_input = request.json.get("prompt")

        if not user_input:
            logging.error("Missing prompt in request body")
            return jsonify({"error": "Missing prompt in request body"}), 400

        # Generate response from the model
        logging.debug("Generating response...")
        results = classifier(user_input)
        logging.debug("Results: %s", results)

        # Extract the highest scoring label
        response = max(results[0], key=lambda x: x['score'])['label']
        logging.info("Generated response: %s", response)

        return jsonify({"response": response})

    except Exception as e:
        logging.error("Error during processing: %s", str(e))
        return jsonify({"error": "Internal server error"}), 500

if __name__ == "__main__":
    print("Running the Flask application...")
    app.run(debug=False, host="0.0.0.0")