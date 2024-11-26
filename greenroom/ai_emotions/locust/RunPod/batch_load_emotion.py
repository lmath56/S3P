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
            "Authorization": "Bearer YOUR_API_KEY"
        }
        payload = {
            "input": {
                "limit": 1,
                "texts": self.texts,
                "baseline": 0.4
            }
        }
        self.client.post("/v2/67w2bikl2su578/runsync", json=payload, headers=headers)

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 5)
    host = "https://api.runpod.ai"
