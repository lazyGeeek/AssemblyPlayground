import os
import secrets
import socket
import string
import subprocess
import sys
import time
import threading

proc: subprocess.Popen[str] | None = None

HOST = "127.0.0.1"
PORT = 1337

TRANSLATE_LIST = {
    ord("\\"): "\\",
    ord("\n"): "\\n",
    ord("\r"): "\\r",
    ord("\t"): "\\t",
    ord("\v"): "\\v",
}

def random_number(min_value: int, max_value: int) -> int:
    if min_value > max_value:
        temp = min_value
        min_value = max_value
        max_value = temp

    return secrets.randbelow(max_value - min_value + 1) + min_value

def random_string(length: int) -> str:
    if length < 0:
        length = 8

    characters = string.ascii_letters + string.digits
    return "".join(secrets.choice(characters) for _ in range(length))

def start_server():
    print("\033[36m=== Starting application ===\033[0m\n")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    app = script_dir + "/../bin/server"

    global proc
    proc = subprocess.Popen(
        [app],
        start_new_session=True,  # detaches from terminal/session
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    time.sleep(0.2) # Wait untill process start

def stop_server():
    global proc
    if proc is None:
        return

    print ("\033[36m=== Stoping Web Server ===\033[0m\n")

    # proc.terminate()
    proc.wait()

def send_get(file:str) -> str:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))

        get_message = f"GET /{file} HTTP/1.0\r\n\r\n"

        print(f"Sending message: \"{get_message}\"".translate(TRANSLATE_LIST))

        s.sendall(get_message.encode("utf-8"))
        reply = s.recv(1024)
        message = reply.decode()

        valid_response = "HTTP/1.0 200 OK\r\n\r\n"

        if valid_response not in message:
            print("\033[31mRecieve incorrect messasge")
            print(f"\"{message}\"".translate(TRANSLATE_LIST))
            print("\033[0m")
            return ""

        print(f"Received from Server: \"{message}\"".translate(TRANSLATE_LIST))
        print("")
        return message.replace(valid_response, "")

def send_post(file: str, content: str) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST,PORT))

        post_message = f"POST /{file} HTTP/1.0\r\n\r\n{content}"

        print(f"Sending message: \"{post_message}\"".translate(TRANSLATE_LIST))

        s.sendall(post_message.encode("utf-8"))
        reply = s.recv(1024)
        message = reply.decode()

        valid_response = "HTTP/1.0 200 OK\r\n\r\n"

        if valid_response not in message:
            print("\033[31mRecieve incorrect messasge")
            print(f"\"{message}\"".translate(TRANSLATE_LIST))
            print("\033[0m")
            return False

        print(f"Revieved from Server: \"{message}\"".translate(TRANSLATE_LIST))
        print("")
        return True

def send_stop():
    print("\033[36m=== Sending STOP request ===\033[0m\n")
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST,PORT))
        s.sendall("STOP".encode("utf-8"))

def is_failed():
    global proc
    if proc == None or proc.poll() == None:
        return

    stdout, stderr = proc.communicate()
    code = proc.returncode # Exit status (e.g., 0 success, less then zero failure)

    if code < 0:
        print("\033[31m=== Failed ===")
        print(f"Return code: {code}")

        if stderr:
            print(f"Error message: {stderr}\033[0m")
        else:
            print("\033[0m")

def test_get():
    file_name = random_string(random_number(5, 10))
    file_content = random_string(random_number(15, 25))

    script_dir = os.path.dirname(os.path.abspath(__file__))
    test_file = f"{script_dir}/../{file_name}"

    with open(test_file, "w", encoding="utf-8") as file:
        file.write(file_content)
        file.close()

    try:
        print("\n\033[36m=== Sending GET request ===\033[0m\n")
        response = send_get(file_name)

        if response == "" or response != file_content:
            print("\033[31mContent not match")
            print(f"{response} != {file_content}".translate(TRANSLATE_LIST))
            print("=== FAILED ===\033[0m\n")
        else:
            print("\033[32mContent match")
            print(f"{response} == {file_content}".translate(TRANSLATE_LIST))
            print("=== PASS ===\033[0m\n")

        is_failed()

    except Exception as error:
        print(f"\033[31mSend Get Error: {error}\033[0m")
    finally:
        if os.path.exists(test_file):
            os.remove(test_file)

def test_post():
    file_name = random_string(random_number(5, 10))
    file_content = random_string(random_number(15, 25))

    script_dir = os.path.dirname(os.path.abspath(__file__))
    test_file = f"{script_dir}/../{file_name}"

    try:
        print("\033[36m=== Sending POST request ===\033[0m\n")

        response = send_post(file_name, file_content)
        content = ""

        with open(test_file, "r", encoding="utf-8") as file:
            content = file.read()
            file.close()

        if response is False or file_content != content:
            print("\033[31mContent not match")
            print(f"{file_content} != {content}".translate(TRANSLATE_LIST))
            print("=== FAILED ===\033[0m\n")
        else:
            print("\033[32mContent match")
            print(f"{file_content} == {content}".translate(TRANSLATE_LIST))
            print("=== PASS ===\033[0m\n")

        is_failed()

    except Exception as error:
        print(f"\033[31mSend Get Error: {error}\033[0m")
    finally:
        if os.path.exists(test_file):
            os.remove(test_file)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        for arg in sys.argv:
            if arg == "-s":
                start_server()

    test_get()
    test_post()
    time.sleep(0.2) # Wait until server stop

    # stop_server()

