import json
import logging

from aws_lambda_powertools.utilities.typing import LambdaContext

from src.core.resources_mgr import ResourcesMgr
from src.domain.hello_msg import HelloMsg
from src.domain.hello_msg_dao import HelloMsgDao

logger = logging.getLogger()
print("create dynamodb resources")
resources_mgr = ResourcesMgr()


def create_hello_msg(event: dict, _context: LambdaContext) -> dict:
    print(event)

    body = json.loads(event["body"])

    book = HelloMsg(language=body["language"], value=body["value"])

    dao = HelloMsgDao(
        dynamodb_resource=resources_mgr.dynamodb_resource,
        dynamodb_client=resources_mgr.dynamodb_client,
        table_name=resources_mgr.table_name(),
    )

    dao.create(book)

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": book.to_json(),
    }


def find_hello_msg(event: dict, _context: LambdaContext) -> dict:
    print(event)

    dao = HelloMsgDao(
        dynamodb_resource=resources_mgr.dynamodb_resource,
        dynamodb_client=resources_mgr.dynamodb_client,
        table_name=resources_mgr.table_name(),
    )

    entity = dao.find_by_uuid(event["pathParameters"]["uuid"])

    if entity is None:
        return {
            "statusCode": 404,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Entity not found"}),
        }

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": entity.to_json(),
    }
