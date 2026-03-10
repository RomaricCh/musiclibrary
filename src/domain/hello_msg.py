import json
import uuid
from typing import Any


class HelloMsg:
    def __init__(self, **kwargs: Any) -> None:
        self.language = kwargs["language"]
        self.value = kwargs["value"]
        self.uuid = str(uuid.uuid4()) if "uuid" not in kwargs else kwargs["uuid"]

    def to_dict(self) -> dict:
        return self.__dict__

    def to_json(self) -> str:
        return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=4)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, HelloMsg):
            return NotImplemented

        return self.language == other.language and self.value == other.value
