# Locust Load Testing

This project uses Locust to perform load testing on an endpoint that processes emotion analysis.

## Installation

1.  Clone the repository:
    ```sh
    git clone <repository-url>
    cd greenroom\sentiment\locust
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

    ```locust -f load_sentiment.py```

2. Open the Locust web interface: 
Open a web browser and go to http://localhost:8089

3. Configure the test:

- Number of total users to simulate
- Spawn rate (users per second)
- Set the host i.e. `http://34.147.77.17:8080`. Note that the load_sentiment.py file is already targeting /get-sentiment

4. Start the test:
Click the "Start swarming" button to begin the load test.

## What It Does

- The script sends POST requests to the /get-sentiment endpoint with a JSON payload.
- The payload contains a list of texts for emotion analysis.
- The responses from the server are saved to a file named responses.txt.

## Example Payload
    
```json
{
    "text": ["I really love coding!"],
}
```

## Output
    
The responses from the server are appended to responses.txt in the same directory as the script.