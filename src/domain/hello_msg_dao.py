import logging

from mypy_boto3_dynamodb.client import DynamoDBClient
from mypy_boto3_dynamodb.service_resource import DynamoDBServiceResource

from src.domain.hello_msg import HelloMsg

logger = logging.getLogger()


class HelloMsgDao:
    def __init__(
        self,
        dynamodb_resource: DynamoDBServiceResource,
        dynamodb_client: DynamoDBClient,
        table_name: str,
    ) -> None:
        self.dynamodb_resource = dynamodb_resource
        self.dynamodb_client = dynamodb_client
        self.table = self.dynamodb_resource.Table(table_name)

    def create(self, entity: HelloMsg) -> None:
        logger.info("[entity] create")
        self.table.put_item(Item=entity.to_dict())

    def delete(self, uuid: str) -> None:
        logger.info("[entity] delete")

        self.table.delete_item(Key={"uuid": uuid})

        return

    def find_by_uuid(self, uuid: str) -> HelloMsg | None:
        logger.info("[entity] entity")
        result = self.table.get_item(Key={"uuid": uuid})

        print(result)

        if "Item" in result:
            return HelloMsg(**result["Item"])
        return None
