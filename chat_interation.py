import argparse
import logging
import sys
from services.chat_google import ChatGoogle


def main() -> int:
    parser = argparse.ArgumentParser(description='Teste de terminal do chat Empório Música')
    parser.add_argument('--session-id', help='UUID de uma sessão anterior')
    parser.add_argument('--verbose-tools', action='store_true', help='Mostra cada execução de ferramenta, duração e quantidade de registros')
    parser.add_argument('--customer-id', type=int, help='Identidade fixa somente para teste local; em produção vem da autenticação')
    args = parser.parse_args()
    logging.basicConfig(level=logging.WARNING, format='%(levelname)s: %(message)s')
    if args.verbose_tools:
        logging.getLogger('services.chat_google').setLevel(logging.INFO)
    try:
        chat = ChatGoogle()
    except Exception as exc:
        print(f'Falha na inicialização ({type(exc).__name__}). Confira .env, PDF e dependências.')
        print('Diagnóstico: uv run python chat_interation.py --check')
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
                tool_summary = ', '.join(
                    f"{event['name']}(status={event['status']}, "
                    f"registros={event.get('rows', 'nao se aplica')}, "
                    f"tempo={event['duration_ms']:.2f} ms)"
                    for event in result.get('tools', [])
                ) or 'nenhuma'
                print(f"[status={result['status']} | salvo={result['saved']} | registros={result['records']} | tempo_total={result['duration_ms']:.2f} ms | tools={tool_summary} | sessão={session_id}]")
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
