from src.core.resources_mgr import ResourcesMgr
from src.domain.song import Song
from src.domain.song_dao import SongDao

resources_mgr = ResourcesMgr()


def song_dao_test() -> SongDao:
    return SongDao(
        dynamodb_resource=resources_mgr.dynamodb_resource,
        dynamodb_client=resources_mgr.dynamodb_client,
        table_name=resources_mgr.table_name(),
    )


class TestSongDao:
    def test_find_song_by_uuid_should_return_song_when_it_exists(self) -> None:
        # given
        song_dao = song_dao_test()
        song = Song(author="pipoauthor", title="pipotitle", genre="pipogenre", date="pipodate")
        song_dao.create(song)

        # when
        asong = song_dao.find_by_uuid(uuid=song.uuid)

        # then
        assert asong is not None
        song_dao.delete(uuid=song.uuid)

    def test_find_song_by_uuid_should_return_none_when_not_it_exists(
        self,
    ) -> None:
        # given

        # when
        asong = song_dao_test().find_by_uuid(uuid="pipouuid")

        # then
        assert asong is None

    def test_find_song_by_author_and_title_should_return_song_when_it_exists(self) -> None:
        # given
        song_dao = song_dao_test()
        song = Song(author="Linkin Park", title="The emptiness machine", genre="Rock", date="2024")
        song_dao.create(song)

        # when
        asong = song_dao.find_song_by_author_and_title(author="Linkin Park", title="The emptiness machine")

        # then
        assert asong is not None
        song_dao.delete(uuid=song.uuid)

    def test_find_song_by_author_and_title_should_return_none_when_not_it_exists(self) -> None:
        # given
        # when
        asong = song_dao_test().find_song_by_author_and_title(author="auteur fake", title="titre fake")

        # then
        assert asong is None

    def test_find_songs_by_author_and_date_should_return_songs_when_it_exists(self) -> None:
        # given
        song_dao = song_dao_test()
        song = Song(author="Linkin Park", title="The emptiness machine", genre="Rock", date="2024")
        song2 = Song(author="Linkin Park", title="Heavy is the crown", genre="Rock", date="2024")
        song3 = Song(author="Linkin Park", title="In the end", genre="Rock", date="2000")
        song_dao.create(song)
        song_dao.create(song2)
        song_dao.create(song3)

        # when
        asong = song_dao.find_songs_by_author_and_date(author="Linkin Park", date="2024")

        # then
        assert len(asong) == 2
        song_dao.delete(uuid=song.uuid)
        song_dao.delete(uuid=song2.uuid)
        song_dao.delete(uuid=song3.uuid)

    def test_find_songs_by_author_and_date_should_return_empty_when_not_it_exists(self) -> None:
        # given
        song_dao = song_dao_test()
        song = Song(author="Linkin Park", title="The emptiness machine", genre="Rock", date="2024")
        song2 = Song(author="Linkin Park", title="Heavy is the crown", genre="Rock", date="2024")
        song3 = Song(author="Linkin Park", title="In the end", genre="Rock", date="2000")
        song_dao.create(song)
        song_dao.create(song2)
        song_dao.create(song3)

        # when
        asong = song_dao.find_songs_by_author_and_date(author="fake author", date="2010")

        # then
        assert len(asong) == 0
        song_dao.delete(uuid=song.uuid)
        song_dao.delete(uuid=song2.uuid)
        song_dao.delete(uuid=song3.uuid)
