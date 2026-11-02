import argparse
import logging
import sys
from config.config import Config
from services.chat_google import ChatGoogle, carregar_manual
from services.postgres_service import PostgresService

EXPECTED_COLUMNS = {
    'categories': {'category_id', 'name', 'description'},
    'products': {'product_id', 'price_brl', 'name', 'category_id', 'description',
                 'stock_quantity', 'status', 'specs', 'created_at'},
    'promotions': {'promotion_id', 'product_id', 'discount_percent', 'description', 'is_active'},
    'customers': {'customer_id', 'name', 'phone', 'email', 'city'},
    'orders': {'order_id', 'customer_id', 'order_date', 'status', 'total_brl',
               'payment_method', 'tracking_code', 'estimated_delivery', 'notes'},
    'order_items': {'order_id', 'product_id', 'quantity'},
    'chat_session': {'id', 'title', 'created_at', 'updated_at'},
    'chat_history': {'id', 'session_id', 'role', 'message', 'created_at', 'updated_at'},
}


def check_setup() -> int:
    problems = []
    key_ok = bool(Config.GEMINI_API_KEY and Config.GEMINI_API_KEY != 'COLOQUE_SUA_CHAVE_AQUI')
    print('Chave Gemini configurada:', 'sim (validade não testada)' if key_ok else 'não')
    if not key_ok:
        problems.append('Configure a chave no .env.')
    if not Config.CHAT_PROMPT_PATH.is_file() or not Config.CHAT_PROMPT_PATH.read_text(encoding='utf-8').strip():
        problems.append('Prompt ausente ou vazio.')
    else:
        print('Prompt: OK')
    try:
        markdown = carregar_manual(Config.STORE_MANUAL_PATH)
        print(f'Manual: OK ({len(markdown)} caracteres em Markdown). Confira a fidelidade das tabelas no PDF.')
    except Exception as exc:
        problems.append(f'Não foi possível converter o PDF ({type(exc).__name__}).')
    try:
        db = PostgresService()
        rows = db.select('''SELECT table_name, column_name, data_type
                            FROM information_schema.columns
                            WHERE table_schema = %s''', ('public',))
        available = {}
        for row in rows:
            available.setdefault(row['table_name'], {})[row['column_name']] = row['data_type']
        for table, cols in EXPECTED_COLUMNS.items():
            missing = cols - available.get(table, {}).keys()
            if missing:
                problems.append(f'public.{table}: faltam colunas {", ".join(sorted(missing))}.')
            else:
                db.select(f'SELECT 1 FROM public.{table} LIMIT 1')
        if available.get('promotions', {}).get('is_active') not in (None, 'boolean'):
            problems.append('public.promotions.is_active deve ser BOOLEAN para as consultas atuais.')
        for table in ('chat_session', 'chat_history'):
            if available.get(table, {}).get('id') not in (None, 'uuid'):
                problems.append(f'public.{table}.id deve ser UUID.')
        if not any('public.' in p for p in problems):
            print('Banco e estrutura public: OK (permissões de INSERT não testadas)')
    except Exception as exc:
        problems.append(f'Não foi possível verificar o PostgreSQL ({type(exc).__name__}). Confira conexão, tabelas e permissões.')
    for problem in problems:
        print('PENDÊNCIA:', problem)
    return 1 if problems else 0


def main() -> int:
    parser = argparse.ArgumentParser(description='Teste de terminal do chat Empório Música')
    parser.add_argument('--check', action='store_true', help='Verifica configuração, PDF e banco sem chamar o Gemini')
    parser.add_argument('--session-id', help='UUID de uma sessão anterior')
    parser.add_argument('--customer-id', type=int, help='Identidade fixa somente para teste local; em produção vem da autenticação')
    args = parser.parse_args()
    logging.basicConfig(level=logging.WARNING, format='%(levelname)s: %(message)s')
    if args.check:
        return check_setup()
    try:
        chat = ChatGoogle()
    except Exception:
        import traceback
        traceback.print_exc()
        return 1
    session_id = args.session_id
    print("Chat iniciado. Digite 'sair' para encerrar. Use Ctrl+C para interromper.")
    try:
        while True:
            try:
                message = input('\nVocê: ').strip()
            except (EOFError, KeyboardInterrupt):
                print('\nEncerrando.')
                break
            if message.lower() == 'sair':
                break
            if not message:
                continue
            try:
                result = chat.chat(message=message, session_id=session_id, customer_id=args.customer_id)
                if result['status'] == 'session_not_found':
                    session_id = None
                else:
                    session_id = result['session_id']
                print(f"\nAssistente: {result['message']}")
                print(f"[status={result['status']} | salvo={result['saved']} | sessão={session_id}]")
            except KeyboardInterrupt:
                print('\nChamada interrompida. Confira o histórico antes de reenviar.')
                break
            except Exception as exc:
                print(f'Erro inesperado ({type(exc).__name__}). O turno não foi confirmado; confira o histórico antes de reenviar.')
    finally:
        chat.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
