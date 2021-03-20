Installation
-------------

Make sure your system has:
- python
- pip

Create the venv and activate it:
```
python3 -m venv venv
. venv/bin/activate
```

Install the requirements:
```
pip install -r requirements/dev.txt
```

# Run the webserver

For example:

```
venv/bin/python manage.py runserver 0.0.0.0:4424
```

# Running the tests

To run the unit tests use `tox` or run:
```
./manage.py test
```
