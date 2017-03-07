# -- coding: utf-8 --
VENDOR_PATH = 'vendor'
LIBS_PATH = 'lib'
# Appends the directory containing our libraries to the sys path.
import sys, os
dir_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(dir_path, VENDOR_PATH))
sys.path.append(os.path.join(dir_path, LIBS_PATH))

# Manually load OS libraries
# ref: https://serverlesscode.com/post/deploy-scikitlearn-on-lamba/
import ctypes
for d, dirs, files in os.walk(LIBS_PATH):
    for f in files:
        if ".so" in f:
            ctypes.cdll.LoadLibrary(os.path.join(d, f))
