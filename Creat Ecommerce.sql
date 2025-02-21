-- Tabela de fornecedores
CREATE TABLE fornecedores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(14) UNIQUE NOT NULL,
    prazo_medio_entrega INTEGER,
    avaliacao_qualidade DECIMAL(3,2),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de categorias
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT,
    margem_lucro_padrao DECIMAL(5,2),
    prazo_validade_medio INTEGER
);

-- Tabela de clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    data_nascimento DATE,
    segmento VARCHAR(20),
    classificacao VARCHAR(20),
    total_compras INTEGER DEFAULT 0,
    valor_total_compras DECIMAL(12,2) DEFAULT 0,
    ultima_compra TIMESTAMP,
    nps INTEGER,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de produtos
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(20) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    categoria_id INTEGER REFERENCES categorias(id),
    fornecedor_id INTEGER REFERENCES fornecedores(id),
    preco_custo DECIMAL(10,2) NOT NULL,
    preco_venda DECIMAL(10,2) NOT NULL,
    margem_lucro DECIMAL(5,2),
    peso DECIMAL(6,2),
    dimensoes VARCHAR(20),
    estoque_atual INTEGER NOT NULL,
    estoque_minimo INTEGER NOT NULL,
    estoque_maximo INTEGER NOT NULL,
    lead_time_reposicao INTEGER,
    quantidade_vendida_total INTEGER DEFAULT 0,
    media_avaliacao DECIMAL(3,2) DEFAULT 0,
    total_avaliacoes INTEGER DEFAULT 0,
    data_ultimo_pedido TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ATIVO',
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de pedidos
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id),
    status VARCHAR(20) NOT NULL,
    valor_produtos DECIMAL(10,2) NOT NULL,
    valor_frete DECIMAL(10,2) NOT NULL,
    valor_desconto DECIMAL(10,2) DEFAULT 0,
    valor_total DECIMAL(10,2) NOT NULL,
    forma_pagamento VARCHAR(20) NOT NULL,
    parcelas INTEGER DEFAULT 1,
    prazo_entrega INTEGER,
    data_entrega_prevista DATE,
    data_entrega_real DATE,
    avaliacao_entrega INTEGER,
    comentario_entrega TEXT,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de itens do pedido
CREATE TABLE itens_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER REFERENCES pedidos(id),
    produto_id INTEGER REFERENCES produtos(id),
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    desconto_item DECIMAL(10,2) DEFAULT 0,
    avaliacao_produto INTEGER,
    comentario_produto TEXT,
    data_avaliacao TIMESTAMP
);

-- Tabela de movimentação de estoque
CREATE TABLE movimentacao_estoque (
    id SERIAL PRIMARY KEY,
    produto_id INTEGER REFERENCES produtos(id),
    tipo_movimento VARCHAR(20) NOT NULL,
    quantidade INTEGER NOT NULL,
    motivo VARCHAR(50) NOT NULL,
    custo_unitario DECIMAL(10,2),
    fornecedor_id INTEGER REFERENCES fornecedores(id),
    numero_nf VARCHAR(20),
    data_movimento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);