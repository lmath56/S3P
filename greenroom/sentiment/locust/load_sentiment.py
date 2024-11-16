from locust import HttpUser, TaskSet, task, between
import random
import nltk
from nltk.corpus import words

# Download the words corpus if not already downloaded
nltk.download('words')

class UserBehavior(TaskSet):
    @task
    def post_request(self):
        # Generate a random 100-word text using real words
        word_list = words.words()
        story = ' '.join(random.choices(word_list, k=100))
        print(story)
        
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