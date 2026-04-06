import logging

from boto3.dynamodb.conditions import Key
from mypy_boto3_dynamodb.client import DynamoDBClient
from mypy_boto3_dynamodb.service_resource import DynamoDBServiceResource

from src.domain.song import Song

logger = logging.getLogger()


class SongDao:
    def __init__(
        self,
        dynamodb_resource: DynamoDBServiceResource,
        dynamodb_client: DynamoDBClient,
        table_name: str,
    ) -> None:
        self.dynamodb_resource = dynamodb_resource
        self.dynamodb_client = dynamodb_client
        self.table = self.dynamodb_resource.Table(table_name)

    def create(self, entity: Song) -> None:
        logger.info("[entity] create")
        self.table.put_item(Item=entity.to_dict())

    def delete(self, uuid: str) -> None:
        logger.info("[entity] delete")

        song = self.find_by_uuid(uuid=uuid)

        if song is not None:
            self.table.delete_item(Key={"author": song.author, "title": song.title})

        return

    def find_by_uuid(self, uuid: str) -> Song | None:
        logger.info("[entity] entity")
        result = self.table.query(
            IndexName="indexByUuid", KeyConditionExpression=Key("uuid").eq(uuid)
        )

        if len(result["Items"]) == 1:
            return Song(**result["Items"][0])
        return None

    def find_song_by_author_and_title(self, author: str, title: str) -> Song | None:
        result = self.table.get_item(Key={"author": author, "title": title})

        if "Item" in result:
            return Song(**result["Item"])
        return None

    def find_songs_by_author_and_date(self, author: str, date: str) -> list[Song]:
        result_query = self.table.query(
            IndexName="indexByAuthorAndDate",
            KeyConditionExpression=Key("author").eq(author) & Key("date").eq(date),
        )

        return [Song(**song) for song in result_query["Items"]]
