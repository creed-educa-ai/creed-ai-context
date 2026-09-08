import json, yaml, collections

SPEC = 'creed-ai-context/tarefas/86e348g6u-autenticacao-da-plataforma/mock/openapi.yaml'
OUT  = 'creed-ai-context/tarefas/86e348g6u-autenticacao-da-plataforma/mock/payloads.json'

spec = yaml.safe_load(open(SPEC, encoding='utf-8'))
comp = spec['components']


def resolve(node):
    """Resolve $ref de responses compartilhadas (Unauthorized, Forbidden, ...)."""
    if isinstance(node, dict) and '$ref' in node:
        _, _, section, name = node['$ref'].split('/')
        return comp[section][name]
    return node


def exemplos(body):
    body = resolve(body)
    media = (body or {}).get('content', {}).get('application/json')
    if not media or 'examples' not in media:
        return None
    return {nome: ex['value'] for nome, ex in media['examples'].items()}


doc = collections.OrderedDict()
doc['_leia'] = {
    'o_que_e': 'Exemplos de payload do contrato da CREED-23, extraidos de mock/openapi.yaml.',
    'gerado_por': 'mock/gerar_payloads.py — nao edite este arquivo a mao.',
    'status': 'PROPOSTA — nenhum endpoint existe em codigo ainda.',
    'como_ler': 'request = o que o front manda. responses = por codigo HTTP, por nome de exemplo.',
    'no_mock': 'Escolher um exemplo por requisicao: cabecalho  Prefer: code=<status>, example=<nome>',
}

for rota, ops in spec['paths'].items():
    for metodo, op in ops.items():
        if metodo == 'parameters':
            continue
        entrada = exemplos(op.get('requestBody'))
        saidas = collections.OrderedDict()
        for codigo, resp in op['responses'].items():
            ex = exemplos(resp)
            if ex:
                saidas[codigo] = ex
            else:
                saidas[codigo] = resolve(resp).get('description', '').strip().split('\n')[0]
        doc[f'{metodo.upper()} {rota}'] = {'request': entrada, 'responses': saidas}

with open(OUT, 'w', encoding='utf-8') as f:
    json.dump(doc, f, ensure_ascii=False, indent=2)
    f.write('\n')

print('gerado:', OUT)
print('operacoes:', len(doc) - 1)
