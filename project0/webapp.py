# encoding: UTF-8

## Веб сервер
import cherrypy

from connect import parse_cmd_line
from connect import create_connection
from static import index
import logging
from random import choice

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
        query = """
            select t1.volunteer_id, t1.volunteer_name, t1.sportsman_count, t1.total_task_count, volunteertask.id as next_task_id, t1.next_task_time
            from
            (
                select volunteer.card_number as volunteer_id,
                    volunteer.name as volunteer_name,
                    count(distinct sportsman.card_number) as sportsman_count,
                    count(distinct volunteertask.id) as total_task_count,
                    min(case when volunteertask.time_ > now() then volunteertask.time_ else null end) as next_task_time
                from
                    volunteer
                        left join
                    sportsman on volunteer.card_number = sportsman.volunteer_id
                        left join
                    volunteertask on volunteer.card_number = volunteertask.volunteer_id
                group by volunteer.card_number
            ) as t1
            left join
            volunteertask on t1.volunteer_id = volunteertask.volunteer_id and t1.next_task_time = volunteertask.time_
            group by t1.volunteer_id, t1.volunteer_name, t1.sportsman_count, t1.total_task_count, t1.next_task_time, volunteertask.id   
            """
        if volunteer_id is not None:
            query = f"select * from ({query}) as t2 where t2.volunteer_id = {volunteer_id}"
        if sportsman_count is not None:
            query = f"select * from ({query}) as t3 where t3.sportsman_count >= {sportsman_count}"
        if total_task_count is not None:
            query = f"select * from ({query}) as t4 where t4.total_task_count >= {total_task_count}"
        with create_connection(self.args) as db:
            cur = db.cursor()
            cur.execute(query)
            volunteers_with_counts = cur.fetchall()
            return [{"volunteer_id": b[0], "volunteer_name": b[1], "sportsman_count" : b[2],
                     "total_task_count" : b[3], "next_task_id" : b[4], "next_task_time" : str(b[5])} for b in volunteers_with_counts]
        

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def volunteer_unassign(self, volunteer_id=None, tasks_ids=None):
        with create_connection(self.args) as db:
            cur = db.cursor()
            
            if tasks_ids == '*':
                cur.execute(f'select id from volunteertask where volunteer_id = {volunteer_id}')
                tasks_ids = [r[0] for r in cur]
            else:
                tasks_ids = tasks_ids.split(",")

            response = []
            for task_id in tasks_ids:
                cur.execute(f'''
                    with tasktime as
                    (
                        select time_ from volunteertask where id = {task_id}
                    )
                    select card_number, count(*)
                    from
                    (
                        select card_number
                        from
                            volunteer
                        where intersection_size(card_number, 1000002) > 0 and card_number not in
                        (
                            select distinct volunteer_id
                            from
                                volunteertask
                            where time_ >=  (select time_ from tasktime) - '1 hour'::interval and time_ <= (select time_ from tasktime) + '1 hour'::interval
                        )
                    ) as t1
                    left join volunteertask on card_number = volunteer_id
                    group by card_number
                    order by count
                    ''')
                all_changers = cur.fetchall()
                changers = []
                for c in all_changers:
                    if c[1] == all_changers[0][1]:
                        changers.append(c[0])
                
                changer_id = volunteer_id if len(changers) == 0 else choice(changers)
                cur.execute(f'select name from volunteer where card_number = {changer_id}')
                name = cur.fetchone()[0]
                response.append({"task_id": task_id, "new_volunteer_name": name, "new_volunteer_id": changer_id})
                cur.execute(f'update volunteertask set volunteer_id = {changer_id} where id = {task_id}')
        return response
                

if __name__ == '__main__':
    cherrypy.config.update({
        'server.socket_host': '0.0.0.0',
        'server.socket_port': 8080,
    })
    cherrypy.quickstart(App(parse_cmd_line()))
