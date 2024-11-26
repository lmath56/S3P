from locust import HttpUser, TaskSet, task, between

class UserBehavior(TaskSet):
    @task
    def send_request(self):
        headers = {
            "Content-Type": "application/json",
            "Authorization": "Bearer API_KEY"
        }
        payload = {
            "input": {
                "text": "Hello World"
            }
        }

        # Send a POST request to the endpoint, BE SURE TO REPLACE THE URL WITH THE CORRECT ENDPOINT
        response = self.client.post("/v2/67w2bikl2su578/runsync", json=payload, headers=headers) 
        
        # Save the response to a file
        with open("responses.txt", "a") as file:
            file.write(response.text + "\n")

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 5)
    host = "https://api.runpod.ai"
