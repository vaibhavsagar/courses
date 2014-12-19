from os import path
import subprocess
THIS_FOLDER = path.dirname(path.abspath(__file__))


def create_session_on_server(host, email):
    return subprocess.check_output(
        [
            r'C:/Users/Vaibhav/Documents/python/envs/py27/Scripts/fab',
            'create_session_on_server:email={}'.format(email),
            '--host={}'.format(host),
            '--hide=everything,status',
        ],
        cwd=THIS_FOLDER,
    ).decode().strip()


def reset_database(host):
    subprocess.check_call(
        [
            r'C:/Users/Vaibhav/Documents/python/envs/py27/Scripts/fab',
            'reset_database',
            '--host={}'.format(host),
        ],
        cwd=THIS_FOLDER,
    )
