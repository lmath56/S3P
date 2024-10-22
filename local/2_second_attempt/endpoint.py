from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
from flask import Flask, request, jsonify

# Replace "your-model-name" with the actual model name
model_name = "allenai/llama-3.2-base"

# Load the tokenizer and model
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSeq2SeqLM.from_pretrained(model_name)  


app = Flask(__name__)

@app.route("/chat",  
 methods=["POST"])
def chat():
  # Get user prompt from request
  user_input = request.json.get("prompt")

  if not user_input:
    return jsonify({"error": "Missing prompt in request body"}), 400

  # Tokenize the input
  inputs = tokenizer(user_input, return_tensors="pt")

  # Generate response from the model
  output = model.generate(**inputs)
  response = tokenizer.batch_decode(output, skip_special_tokens=True)[0]

  return jsonify({"response": response})

if __name__ == "__main__":
  app.run(debug=True, host="0.0.0.0")  # Change host if needed