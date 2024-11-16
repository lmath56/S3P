from locust import HttpUser, TaskSet, task, between
import random
import string

class UserBehavior(TaskSet):
    @task
    def post_request(self):
        # Generate a random 100-word text
        words = [''.join(random.choices(string.ascii_lowercase, k=random.randint(3, 10))) for _ in range(100)]
        story = ' '.join(words)
        
        # Send the POST request with the story content
        response = self.client.post("/get-sentiment", json={
            "text": [story],
        })
        
        # Write the response text to the file
        with open("responses.txt", "a", encoding='utf-8') as file:
            file.write(response.text + "\n")

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 5)