# Second Attempt Local

This folder contains some files that ChatGPT generated. 
What I want to achieve is a build a docker image that is able to build and be ready to accept prompts straight away.

Uses:
- Huggingface

Build: docker build -t hf-gpu .
Replace hf-gpu with whatever you want to call the image.

Run: docker run -p 5000:5000 --gpus all hf-gpu

Request: curl -X POST http://localhost:5000/chat -H "Content-Type: application/json" -d '{"prompt": "How hot is the sun."}'

