# Second Attempt Local

This folder contains some files that ChatGPT / Gemini / Copilot and I created.
What I want to achieve is a build a docker image that is able to build and be ready to accept prompts straight away.

Uses:
- Huggingface
- GPT2 Model - no license or auth required.

Build: docker build -t hf-gpu .
Replace hf-gpu with whatever you want to call the image.

Run: docker run -p 5000:5000 --gpus all hf-gpu

Request: curl -X POST http://localhost:5000/chat -H "Content-Type: application/json" -d '{"prompt": "How hot is the sun."}'

This works but the model does not seem to be very good.
Now I hace an idea of how this works I am going to move to the next attempt with a new model.

This also does not seem to use the GPU which is what I was trying to do - so I will investigate that. 