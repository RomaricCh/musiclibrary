import logging
import os
from collections.abc import Callable
from typing import Any

import boto3

logger = logging.getLogger()


def singleton[T](class_: type[T]) -> Callable[..., T]:
    instances: dict[type[T], T] = {}

    def getinstance(*args: Any, **kwargs: Any) -> T:
        if class_ not in instances:
            instances[class_] = class_(*args, **kwargs)
        return instances[class_]

    return getinstance


class MissingEnvironmentVariableError(Exception):
    """Raised when a required environment variable is not set."""

    def __init__(self, var_name: str) -> None:
        super().__init__(f"{var_name} env not set")


@singleton
class ResourcesMgr:
    def __init__(self) -> None:
        self.dynamodb_resource = boto3.resource("dynamodb")
        self.dynamodb_client = boto3.client("dynamodb")

    @staticmethod
    def table_name() -> str:

        if "TABLE_NAME" in os.environ:
            return os.environ["TABLE_NAME"]

        raise MissingEnvironmentVariableError("TABLE_NAME")
