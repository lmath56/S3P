from locust import HttpUser, TaskSet, task, between

class UserBehavior(TaskSet):
    @task
    def post_request(self):
        # Read the content from text.txt
        with open('text.txt', 'r', encoding='utf-8') as file:
            story = file.read()
        
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