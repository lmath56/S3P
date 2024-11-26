from locust import HttpUser, TaskSet, task, between
import json

class UserBehavior(TaskSet):
    def on_start(self):
        with open('comments.json', 'r', encoding='utf-8') as file:
            self.comments = json.load(file)
        self.texts = [comment["content"] for comment in self.comments]

    @task
    def send_batch_request(self):
        headers = {
            "Content-Type": "application/json",
            "Authorization": "Bearer API_KEY"
        }
        payload = {
            "input": {
                "limit": 1,
                "texts": self.texts,
                "baseline": 0.4
            }
        }
        response = self.client.post("/v2/usu1imk8bfbasw/runsync", json=payload, headers=headers)

        # Save response to responses.txt
        with open('responses.txt', 'a', encoding='utf-8') as file:
            file.write(response.text + '\n')

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 5)
    host = "https://api.runpod.ai"
