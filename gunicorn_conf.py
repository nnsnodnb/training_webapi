import multiprocessing

bind = "0.0.0.0:8000"
worker = multiprocessing.cpu_count() * 2 + 1
reload = True
