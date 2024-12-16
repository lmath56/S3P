import os
from locust import HttpUser, TaskSet, task, between

class UserBehavior(TaskSet):
    def on_start(self):
        # Set environment variables for testing
        os.environ["LLM_SERVICE_RUNPOD_ADDRESS"] = "https://api.runpod.ai/v2/idnumber"
        os.environ["LLM_SERVICE_RUNPOD_API_KEY"] = "api_key"
        self.base_url = os.getenv("LLM_SERVICE_RUNPOD_ADDRESS")
        self.api_key = os.getenv("LLM_SERVICE_RUNPOD_API_KEY")

    @task
    def get_topic_tag(self):
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }
        payload = {
            "input": {
                "path": "/topic",
                "body": {
                    "message": "Discuss the impact of climate change on polar bears."
                }
            }
        }
        response = self.client.post(f"{self.base_url}/runsync", json=payload, headers=headers)
        with open("responses.txt", "a") as file:
            file.write(response.text + "\n")

    @task
    def get_topic_tag_with_history(self):
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }
        message = {"message": "What are the main causes of global warming?"}
        prev_messages = [
            {"message": "Global warming is a significant issue."},
            {"message": "It has various causes and effects."},
            {"message": "One of the main causes is the increase in greenhouse gases."},
            {"message": "These gases trap heat in the atmosphere."},
            {"message": "This leads to a rise in global temperatures."},
            message
        ]
        payload = {
            "input": {
                "path": "/topic_with_context",
                "body": {
                    "message": message,
                    "prev_messages": prev_messages
                }
            }
        }
        response = self.client.post(f"{self.base_url}/runsync", json=payload, headers=headers)
        with open("responses.txt", "a") as file:
            file.write(response.text + "\n")

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 5)
    host = "https://api.runpod.ai"