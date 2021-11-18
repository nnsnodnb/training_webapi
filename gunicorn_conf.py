import multiprocessing

bind = "unix://tmp/gunicorn.sock"
worker = multiprocessing.cpu_count() * 2 + 1
reload = True
