# Greenroom_Sentiment Start-up Process

The project is made in a python shell that runs on python 3.11. To enable this set python 3.11 as your standard python interpreter (in VS Code open the command palette (Shift, Command, P) and look for "Python: Select Interpreter"). Afterwards you can run  
`pipenv shell`  
In the newly generated terminal shell run  
`pipenv install`  
This will install all the dependencies listed in the Pipfile. For installing new packages be sure to use pipenv install 'package name' instead of pip install 'package name'.

In case you're running a M1 mac or something that uses an ARM64 architecture, some modules may not work. To get around this start your pipenv shell as follows  
`arch -x86_64 /usr/local/bin/pipenv shell`

To run the flask app use the following command  
`python app/app.py`

Your Flask application should now be running and listening on `http://127.0.0.1:5000`.

&nbsp;

## Send a Request Using `curl`

You can use the `curl` command to send a POST request to the `/get-sentiment` endpoint of your Flask application. Here is the command:

```powershell
curl -X POST -H "Content-Type: application/json" -d '{"text": "I really love coding!"}' http://127.0.0.1:5000/get-sentiment
```

### Expected Response

If everything is set up correctly, you should receive a JSON response with the sentiment analysis results. For example:

```json
{  
  "compound": 0.6989,  
  "neg": 0.0,  
  "neu": 0.385,  
  "pos": 0.615  
}
```

This response contains the sentiment scores for the given text.

## Explanation of the `curl` Command

- `-X POST`: Specifies that the request method is POST.
- `-H "Content-Type: application/json"`: Sets the `Content-Type` header to `application/json`, indicating that the request body contains JSON data.
- `-d '{"text": "I really love coding!"}'`: Specifies the data to be sent in the request body. In this case, it is a JSON object with a `text` field.
- `http://127.0.0.1:5000/get-sentiment`: The URL of the endpoint to which the request is being sent.