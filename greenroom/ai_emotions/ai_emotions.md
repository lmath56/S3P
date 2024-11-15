# Greenroom_AI_Emotions Start-up Process

The project is made in a python shell that runs on python 3.11. To enable this set python 3.11 as your standard python interpreter (in VS Code open the command palette (Shift, Command, P) and look for "Python: Select Interpreter"). Afterwards you can run  
`pipenv shell`  
In the newly generated terminal shell run  
`pipenv install`  
This will install all the dependencies listed in the Pipfile. For installing new packages be sure to use pipenv install 'package name' instead of pip install 'package name'.

In case you're running a M1 mac or something that uses an ARM64 architecture, some modules may not work. To get around this start your pipenv shell as follows  
`arch -x86_64 /usr/local/bin/pipenv shell`

To run the flask app use the following command  
`python app/app.py`

Your Flask application should now be running and listening on `http://127.0.0.1:5005`.

&nbsp;

## Send a Request Using `curl`

You can use the `curl` command to send a POST request to the `/get-sentiment` endpoint of your Flask application. Here is the command:

```cmd
curl -X POST -H "Content-Type: application/json" -d '{"texts": ["I really love coding!"], "baseline": null, "limit": null}' http://127.0.0.1:5005/get-emotion-batch
```

### Expected Response

If everything is set up correctly, you should receive a JSON response with the sentiment analysis results. For example:

```json
[
  [
    {
      "label": "joy",
      "score": 0.9820055961608887
    },
    {
      "label": "surprise",
      "score": 0.006963521707803011
    },
    {
      "label": "sadness",
      "score": 0.005056203808635473
    },
    {
      "label": "neutral",
      "score": 0.0030948217026889324
    },
    {
      "label": "anger",
      "score": 0.0018817618256434798
    },
    {
      "label": "disgust",
      "score": 0.0005979111883789301
    },
    {
      "label": "fear",
      "score": 0.000400164833990857
    }
  ]
]
```

&nbsp;

# Examples

```powershell
curl -X POST -H "Content-Type: application/json" -d '{"texts": ["Her face drained of all colour, her lips slackened, and her eyes widened as though trying to drink in all of me for fear that I might have suddenly disappeared. Her hands trembled as her arms encircled me, and she dropped to her knees as she held me close to her body, buried her face in my hair. The top of my head grew wet with her tears as she held on tightly, and whispered a plea, begging me never to go near it again, saying that the thing could go off any day now and no one knew what damage it would do. That was the first time I learned of my own impermanence. That there was a world before me, and one day, would be a world after."], "baseline": null, "limit": null}' http://127.0.0.1:5005/get-emotion-batch
```