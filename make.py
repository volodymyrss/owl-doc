#import click
import re
import requests

base_url = "http://localhost:8080/"
published_url = "https://odahub.io/ontology/"

def localize_url(url):
    u = url.group(1)
    if u.startswith("lode/source"):
        return "\"rdf.ttl\""
    else:
        open(u, "wb").write(requests.get(base_url + u).content)
        return "\"" + u + "\""

r = re.sub("\"" + base_url + "(.*?)\"", localize_url, open("odaowl.html").read())

r = re.sub("http://visualdataweb.de/webvowl/#iri=http://localhost:8000/rdf.ttl", 
           f"http://visualdataweb.de/webvowl/#iri={published_url}/rdf.ttl",
           r
           )

open("odaowl-static.html", "w").write(r)
