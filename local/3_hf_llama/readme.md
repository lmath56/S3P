# Third Attempt Local

This folder contains some files that ChatGPT / Gemini / Copilot and I created. 
What I want to achieve is a build a docker image that is able to build and be ready to accept prompts straight away.

Uses:
- Huggingface
- [Phi-3.5-nini-instruct](https://huggingface.co/microsoft/Phi-3.5-mini-instruct)


# Build the Docker image
```docker build -t hf-gpu .```

Replace ```hf-gpu``` with whatever you want to call the image.

# Run the Docker container
```docker run -p 5000:5000 --gpus all hf-gpu```


# Make a request to the running container
```curl -X POST http://localhost:5000/chat -H "Content-Type: application/json" -d '{"prompt": "How hot is the sun."}'```