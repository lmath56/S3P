# First Attempt Local

This folder contains some files that ChatGPT generated. 
What I want to achieve is a build a docker image that is able to build and be ready to accept prompts straight away.

Uses:
- Ollama
- Llama3.2 3B model which was downloaded from Ollama

To run: docker run -p 11434:11434 --gpus all ollama-gpu serve

## Progression

This did not get completed as I had decided to try Huggingface instead of Ollama, see 2_second_attempt.
This was due to there being more documentation on Huggingface available.