from contextlib import contextmanager
from datetime import datetime
import os
from uuid import UUID

import psycopg
from psycopg.rows import dict_row
from config.config import Config


class PostgresService:
    def __init__(self, database_url: str | None = None):
        self.database_url = database_url or Config.DATABASE_URL
        if not self.database_url:
            raise ValueError('Configure DATABASE_URL no .env.')

    @contextmanager
    def connection(self):
        with psycopg.connect(self.database_url, row_factory=dict_row,
                             connect_timeout=10) as conn:
            with conn.cursor() as cur:
                cur.execute("SET LOCAL statement_timeout = '10s'")
            yield conn

    def select(self, query: str, params: tuple = ()) -> list[dict]:
        with self.connection() as conn:
            conn.execute('SET TRANSACTION READ ONLY')
            return conn.execute(query, params).fetchall()

    def create_chat_session(self, title: str) -> dict:
        if not title.strip():
            raise ValueError('O título não pode ser vazio.')
        with self.connection() as conn:
            return conn.execute(
                'INSERT INTO public.chat_session (title) VALUES (%s) RETURNING *',
                (title.strip(),)).fetchone()

    def get_chat_session(self, session_id: str) -> dict | None:
        rows = self.select('SELECT * FROM public.chat_session WHERE id = %s',
                           (UUID(str(session_id)),))
        return rows[0] if rows else None

    def add_chat_history(self, session_id: str, role: str, message: str) -> dict:
        if not role.strip() or not message.strip():
            raise ValueError('Role e mensagem são obrigatórios.')
        with self.connection() as conn:
            return self._insert_history(conn, UUID(str(session_id)), role, message)

    @staticmethod
    def _insert_history(conn, session_id: UUID, role: str, message: str) -> dict:
        row = conn.execute('''
            INSERT INTO public.chat_history (session_id, role, message)
            VALUES (%s, %s, %s) RETURNING *
        ''', (session_id, role, message)).fetchone()
        conn.execute('''UPDATE public.chat_session
                        SET updated_at = clock_timestamp() WHERE id = %s''',
                     (session_id,))
        return row

    def add_chat_turn(self, session_id: str, user_message: str, answer: str) -> None:
        if not user_message.strip() or not answer.strip():
            raise ValueError('Mensagem e resposta não podem ser vazias.')
        sid = UUID(str(session_id))
        with self.connection() as conn:
            # Serializa a gravação do par de mensagens na sessão.
            if not conn.execute('SELECT id FROM public.chat_session WHERE id = %s FOR UPDATE',
                                (sid,)).fetchone():
                raise ValueError('Sessão não encontrada.')
            self._insert_history(conn, sid, 'user', user_message)
            self._insert_history(conn, sid, 'assistant', answer)

    def get_chat_history(self, session_id: str, inicio: datetime | None = None,
                         fim: datetime | None = None, limite: int = 100) -> list[dict]:
        for value in (inicio, fim):
            if value is not None and (value.tzinfo is None or value.utcoffset() is None):
                raise ValueError('Informe datas com fuso horário.')
        if inicio and fim and inicio >= fim:
            raise ValueError('inicio deve ser anterior a fim.')
        if not 1 <= limite <= 1000:
            raise ValueError('limite deve estar entre 1 e 1000.')
        clauses, params = ['session_id = %s'], [UUID(str(session_id))]
        if inicio:
            clauses.append('created_at >= %s')
            params.append(inicio)
        if fim:
            clauses.append('created_at < %s')
            params.append(fim)
        query = f'''SELECT * FROM (
            SELECT * FROM public.chat_history WHERE {' AND '.join(clauses)}
            ORDER BY created_at DESC, CASE role WHEN 'assistant' THEN 1 ELSE 0 END DESC, id DESC
            LIMIT %s
        ) h ORDER BY created_at, CASE role WHEN 'assistant' THEN 1 ELSE 0 END, id'''
        return self.select(query, tuple(params + [limite]))
