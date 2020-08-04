from flask import jsonify, render_template
from flask import Flask, request
import random


def main():
    app.run(debug=True, port=8000)

app = Flask(__name__)

@app.route('/')
def hello_world():
    return render_template('index.html')


@app.route('/floorplan/')
@app.route('/floorplan/<string:name>/')
def floorplans(name=None):
    d = gen(name=name)
    return jsonify(d)

import pathlib


def gen(name=None):
    count = 10

    if name is not None:
        path = pathlib.Path(f'./plans/{name}.json')
        if path.exists():
            return file_content(path)
        else:
            print('Path does not exist:', path)
    d = {
        'items': [random.randint(-1,1) for x in range(count*count)],
        'count': count
    }

    return d

@app.route('/dirty/post/', methods=['POST'])
def dirty_post():
    """Receive unsanatized content through POST, expecting three params.
    This is not good and should not be used in any open environment.
    """
    if request.method == 'POST':
        d = json.loads(request.data)
        print(d)
    name = d['name']
    path = pathlib.Path(f'./plans/{name}.json')
    with path.open('w') as stream:
        json.dump(d, stream, indent=4)

    return jsonify({'success': True})



import json
def file_content(path):
    with path.open() as stream:
        return json.load(stream)

if __name__ == '__main__':
    main()
