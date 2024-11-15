# Locust Load Testing

This project uses Locust to perform load testing on an endpoint that processes emotion analysis.

## Installation

1.  Clone the repository:
    ```sh
    git clone <repository-url>
    cd greenroom\locust
    ```
2.  Create a virtual environment (optional but recommended):
    ```sh
    python -m venv venv
    venv\Scripts\activate.ps1
    ```
3.  Install Locust

    ```pip install locust```


## Usage
1. Run Locust:

    ```locust -f emotion.py --host=http://127.0.0.1:5005```

2. Open the Locust web interface: 
Open a web browser and go to http://localhost:8089

3. Configure the test:

- Number of total users to simulate
- Spawn rate (users per second)
- Host (should already be set to http://127.0.0.1:5005)

4. Start the test:
Click the "Start swarming" button to begin the load test.

## What It Does

- The script sends POST requests to the /get-emotion-batch endpoint with a JSON payload.
- The payload contains a list of texts for emotion analysis.
- The responses from the server are saved to a file named responses.txt.

## Example Payload
    
```json
{
    "texts": ["I really love coding!"],
    "baseline": null,
    "limit": null
}
```

## Output
    
The responses from the server are appended to responses.txt in the same directory as the script.