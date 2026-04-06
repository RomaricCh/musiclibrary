import json
import logging

from aws_lambda_powertools.utilities.typing import LambdaContext

from src.core.resources_mgr import ResourcesMgr
from src.domain.song import Song
from src.domain.song_dao import SongDao

logger = logging.getLogger()
print("create dynamodb resources")
resources_mgr = ResourcesMgr()


def create_song(event: dict, _context: LambdaContext) -> dict:
    print(event)

    body = json.loads(event["body"])

    song = Song(author=body["author"], title=body["title"], genre=body["genre"], date=body["date"])

    dao = SongDao(
        dynamodb_resource=resources_mgr.dynamodb_resource,
        dynamodb_client=resources_mgr.dynamodb_client,
        table_name=resources_mgr.table_name(),
    )

    dao.create(song)

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": song.to_json(),
    }


def find_song(event: dict, _context: LambdaContext) -> dict:
    print(event)

    dao = SongDao(
        dynamodb_resource=resources_mgr.dynamodb_resource,
        dynamodb_client=resources_mgr.dynamodb_client,
        table_name=resources_mgr.table_name(),
    )

    entity = dao.find_song_by_author_and_title(
        author=event["queryStringParameters"]["author"],
        title=event["queryStringParameters"]["title"],
    )

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


def delete_song(event: dict, _context: LambdaContext) -> dict:
    print(event)

    dao = SongDao(
        dynamodb_resource=resources_mgr.dynamodb_resource,
        dynamodb_client=resources_mgr.dynamodb_client,
        table_name=resources_mgr.table_name(),
    )

    dao.delete(event["pathParameters"]["uuid"])

    return {"statusCode": 204, "headers": {"Content-Type": "application/json"}, "body": ""}
