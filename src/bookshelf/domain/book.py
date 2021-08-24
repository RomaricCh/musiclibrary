class Book:
    def __init__(self, **kwargs) -> None:
        self.author = kwargs["author"]
        self.title = kwargs["title"]
        self.genre = kwargs["genre"] if "genre" in kwargs else ""
        self.publication_date = (
            kwargs["publication_date"] if "publication_date" in kwargs else ""
        )

    def to_dict(self):
        return self.__dict__

    def __eq__(self, other) -> bool:
        if not isinstance(other, Book):
            return NotImplemented

        return self.author == other.author and self.title == other.title