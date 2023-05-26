FROM public.ecr.aws/lambda/python:3.7


COPY aws_credentials.p12 ./
COPY requirements.txt ./
COPY app ./app

RUN python3.7 -m pip install -r requirements.txt -t .

# Command can be overwritten by providing a different command in the template directly.
CMD ["app.app.lambda_handler"]