import logging
import torch
from flask import Flask, request, jsonify
from transformers import AutoModelForCausalLM, AutoTokenizer

print("Loading the model...")
# Load the model from the local directory
model_path = "./models/Phi-3.5-mini-instruct"
model = AutoModelForCausalLM.from_pretrained(model_path)
tokenizer = AutoTokenizer.from_pretrained(model_path)
print("Model loaded successfully.")

# Check if GPU is available and move the model to GPU
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)
print(f"Using device: {device}")

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
    # Get user prompt from request
    user_input = request.json.get("prompt")

    if not user_input:
        logging.error("Missing prompt in request body")
        return jsonify({"error": "Missing prompt in request body"}), 400

    # Tokenize the input
    inputs = tokenizer(user_input, return_tensors="pt").to(device)
    logging.debug("Tokenized input: %s", inputs)

    # Generate response from the model
    output = model.generate(
        **inputs,
        max_length=500,
        num_return_sequences=1
    )
    response = tokenizer.decode(output[0], skip_special_tokens=True)
    logging.info("Generated response: %s", response)

    return jsonify({"response": response})

if __name__ == "__main__":
    print("Running the Flask application...")
    app.run(debug=False, host="0.0.0.0")