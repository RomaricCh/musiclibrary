import json
import uuid
from typing import Any


class Song:
    def __init__(self, **kwargs: Any) -> None:
        self.author = kwargs["author"]
        self.title = kwargs["title"]
        self.genre = kwargs["genre"]
        self.date = kwargs["date"]
        self.uuid = str(uuid.uuid4()) if "uuid" not in kwargs else kwargs["uuid"]

    def to_dict(self) -> dict:
        return self.__dict__

    def to_json(self) -> str:
        return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=4)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Song):
            return NotImplemented

        return (
            self.author == other.author
            and self.title == other.title
            and self.genre == other.genre
            and self.date == other.date
        )
