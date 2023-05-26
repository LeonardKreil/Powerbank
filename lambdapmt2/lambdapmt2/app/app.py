from requests_pkcs12 import get
import json


def get_thing_shadow():
    url = "https://a38zt4xcb90xlj-ats.iot.eu-central-1.amazonaws.com:8443/things/pmt2esp32/shadow"

    return response_to_json(get(url, pkcs12_filename='aws_credentials.p12',
                                pkcs12_password='UFUcflHhREVsa87ZSJNp'))


def response_to_json(response):
    return json.loads(response.text.replace("'", "\""))


def lambda_handler(event, context):
    statusCode = 200
    response = {}

    try:
        response = get_thing_shadow()
        if not response:
            statusCode = 401
    except Exception as e:
        print(e)
        statusCode = 400

    responseObject = {}
    responseObject['statusCode'] = statusCode
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = json.dumps(response, default=str)

    return responseObject
