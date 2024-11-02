import logging
import os
import torch
import torch_xla
import torch_xla.core.xla_model as xm
from flask import Flask, request, jsonify
from transformers import AutoModelForCausalLM, AutoTokenizer

print("Configuring TPU...")
# Initialize TPU system
try:
    device = xm.xla_device()
    print("TPU initialized successfully")
except Exception as e:
    print(f"Error initializing TPU: {e}")
    raise

print("Loading the model...")
# Load the model from the local directory
model_path = "/app/models"
model = None
tokenizer = None
try:
    model = AutoModelForCausalLM.from_pretrained(model_path).to(device)
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    print("Model loaded successfully.")
except Exception as e:
    print(f"Error loading model: {e}")

print("Configuring the logger...")
# Configure the logger
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s %(levelname)s %(message)s',
    filename='app.log'
)

# Define the generation function
def generate_text(model, tokenizer, input_text):
    inputs = tokenizer(input_text, return_tensors='pt').to(device)
    with torch.no_grad():
        outputs = model.generate(**inputs)
    return tokenizer.decode(outputs[0], skip_special_tokens=True)

# Flask app
app = Flask(__name__)

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    input_text = data.get('input_text', '')
    output_text = generate_text(model, tokenizer, input_text)
    return jsonify({'output_text': output_text})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)