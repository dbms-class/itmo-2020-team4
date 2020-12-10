# encoding: UTF-8

## Веб сервер
import cherrypy

from connect import parse_cmd_line
from connect import create_connection
from static import index


@cherrypy.expose
class App(object):
    def __init__(self, args):
        self.args = args

    @cherrypy.expose
    def start(self):
        return "Hello web app"

    @cherrypy.expose
    def index(self):
        return index()

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def register_delegation(self, country_name, director_name, director_phone):
        with create_connection(self.args) as db:
            cur = db.cursor()
            cur.execute(f"INSERT INTO delegation(name, director_name, director_phone) "
                        f"VALUES ('{country_name}', '{director_name}', '+{director_phone.strip()}')")


    @cherrypy.expose
    @cherrypy.tools.json_out()
    def register_volunteer(self, name, phone_number):
        with create_connection(self.args) as db:
            cur = db.cursor()
            cur.execute(f"INSERT INTO volunteer(name, phone_number) "
                        f"VALUES ('{name}', '+{phone_number.strip()}')")

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def register(self, sportsman, country, volunteer_id):
        if not sportsman or not country or not volunteer_id:
            # error
            pass
        with create_connection(self.args) as db:
            cur = db.cursor()
            # cur.execute("select * from information_schema.tables")
            print("sportsman.isdigit()")
            print(sportsman.isdigit())
            if sportsman.isdigit():
                # TODO should we create a new country here?
                cur.execute(f"UPDATE sportsman SET delegation_id = '{country}', "
                            f"volunteer_id = {volunteer_id} "
                            f"WHERE card_number = {sportsman};")
            else:
                cur.execute(f"INSERT INTO Sportsman (name, volunteer_id, delegation_id) "
                            f"VALUES ('{sportsman}', {volunteer_id}, '{country}');")


cherrypy.config.update({
    'server.socket_host': '0.0.0.0',
    'server.socket_port': 8080,
})
cherrypy.quickstart(App(parse_cmd_line()))
