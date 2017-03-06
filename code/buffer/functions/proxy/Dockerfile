FROM amazonlinux

RUN curl https://bootstrap.pypa.io/get-pip.py | python
RUN pip install python-lambda-local

WORKDIR /code

ENTRYPOINT ["python-lambda-local"]
