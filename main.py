from pytube import YouTube
from threading import Thread

class YTDownloader(Thread):
    def __init__(self, link: str):
        super().__init__(self)
        self.link = link

    def run(self):
        YouTube(link).streams.filter(only_audio=True).first().download()
