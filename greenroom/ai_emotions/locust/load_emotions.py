from locust import HttpUser, TaskSet, task, between

class UserBehavior(TaskSet):
    @task
    def post_request(self):
        response = self.client.post("/get-emotion-batch", json={
            "texts": ["I really love coding!"],
            "baseline": None,
            "limit": None
        })
        with open("responses.txt", "a") as file:
            file.write(response.text + "\n")  # Write the response text to the file

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 5)