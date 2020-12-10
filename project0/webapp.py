# encoding: UTF-8

## Веб сервер
import cherrypy

from connect import parse_cmd_line
from connect import create_connection
from static import index
import logging


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
            cur.execute("INSERT INTO delegation(country_name, director_name, director_phone) "
                        "VALUES (%s, %s, %s)", (country_name, director_name, director_phone))


    @cherrypy.expose
    @cherrypy.tools.json_out()
    def register_volunteer(self, name, phone_number):
        with create_connection(self.args) as db:
            cur = db.cursor()
            cur.execute("INSERT INTO volunteer(name, phone_number) "
                        "VALUES (%s, $s)", (name, phone_number))

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def register(self, sportsman, country_name, volunteer_id):
        if not sportsman or not country_name or not volunteer_id:
            # error
            pass
        with create_connection(self.args) as db:
            cur = db.cursor()
            if sportsman.isdigit():
                # TODO should we create a new country here?
                cur.execute("UPDATE sportsman SET country_name = %s, "
                            "volunteer_id = %s "
                            "WHERE card_number = %s",
                            (country_name, volunteer_id, sportsman))
            else:
                cur.execute("INSERT INTO Sportsman (name, volunteer_id, country_name) "
                            "VALUES (%s, %s, %s)", (sportsman, volunteer_id, country_name))

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def countries(self):
        with create_connection(self.args) as db:
            cur = db.cursor()
            cur.execute("SELECT id, country_name FROM Delegation")
            countries = cur.fetchall()
            return [{"id": c[0], "name": c[1]} for c in countries]

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def volunteers(self):
        with create_connection(self.args) as db:
            cur = db.cursor()
            cur.execute("SELECT card_number, name FROM Volunteer")
            volunteers = cur.fetchall()
            return [{"id": b[0], "name": b[1]} for b in volunteers]

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def volunteer_load(self, volunteer_id=None, sportsman_count=None, total_task_count=None):
        """
        :param volunteer_id: оставляет только во-лонтера с указанным идентификатором;
        :param sportsman_count: оставляет тех, закем закреплено спортсменов неменьше, чем значение аргумента;
        :param total_task_count: ставляет тех, у кого общее количество задач не меньше, чем значение аргумента;
        :return: JSON
            [ {"volunteer_id": X, "volunteer_name": X, "sportsman_count": X, "total_task_count": X,
            "next_task_id": X, "next_task_time": X}, ... ]
        """
        with create_connection(self.args) as db:
            cur = db.cursor()
            cur.execute("SELECT volunteer_id, COUNT(*) as count FROM volunteertask GROUP BY volunteer_id "
                        "ORDER BY count DESC")
            volunteers_with_counts = cur.fetchall()
            return [{"id": b[0], "total_task_count": b[1]} for b in volunteers_with_counts]


if __name__ == '__main__':
    cherrypy.config.update({
        'server.socket_host': '0.0.0.0',
        'server.socket_port': 8080,
    })
    cherrypy.quickstart(App(parse_cmd_line()))
