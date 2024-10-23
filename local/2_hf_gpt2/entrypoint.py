import logging
from transformers import AutoTokenizer, AutoModelForCausalLM
from flask import Flask, request, jsonify
import signal

print("Starting the Flask application...")

model_name = "gpt2"

print("Loading the tokenizer...")
# Load the tokenizer
tokenizer = AutoTokenizer.from_pretrained(model_name)
print("Tokenizer loaded successfully.")

def handler(signum, frame):
    raise Exception("Model loading timed out")

# Set the timeout handler
signal.signal(signal.SIGALRM, handler)
signal.alarm(300)  # Set timeout to 300 seconds (5 minutes)

try:
    print("Loading the model...")
    # Load the model
    model = AutoModelForCausalLM.from_pretrained(model_name)
    print("Model loaded successfully.")
    signal.alarm(0)  # Disable the alarm
except Exception as e:
    print(f"Error loading the model: {e}")
    exit(1)

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
    inputs = tokenizer(user_input, return_tensors="pt")
    logging.debug("Tokenized input: %s", inputs)

    # Generate response from the model
    output = model.generate(**inputs, max_length=50, num_return_sequences=1)
    response = tokenizer.decode(output[0], skip_special_tokens=True)
    logging.info("Generated response: %s", response)

    return jsonify({"response": response})

if __name__ == "__main__":
    print("Running the Flask application...")
    app.run(debug=False, host="0.0.0.0")