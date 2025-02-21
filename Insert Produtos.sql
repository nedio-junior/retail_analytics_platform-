-- Inserir fornecedores
INSERT INTO fornecedores (nome, cnpj, prazo_medio_entrega, avaliacao_qualidade) VALUES
('Tech Solutions Ltda', '12345678000100', 5, 4.5),
('Fashion Wear S.A.', '98765432000100', 7, 4.2),
('Eletro Master', '45678912000100', 3, 4.8),
('Global Imports', '11122233300010', 10, 4.0),
('Supply Tech', '44455566600010', 4, 4.6);

-- Inserir categorias
INSERT INTO categorias (nome, descricao, margem_lucro_padrao, prazo_validade_medio) VALUES
('Smartphones', 'Telefones celulares e acessórios', 35.00, 730),
('Notebooks', 'Computadores portáteis', 30.00, 730),
('Vestuário', 'Roupas em geral', 60.00, 365),
('Eletrônicos', 'Produtos eletrônicos diversos', 40.00, 730),
('Acessórios', 'Acessórios em geral', 70.00, 365);

-- Inserir clientes
INSERT INTO clientes (nome, email, cpf, telefone, data_nascimento, segmento, classificacao, total_compras, valor_total_compras, nps) VALUES
('Maria Silva', 'maria@email.com', '12345678901', '11999991111', '1990-05-15', 'varejo', 'VIP', 15, 5000.00, 9),
('João Santos', 'joao@email.com', '23456789012', '11999992222', '1985-08-20', 'varejo', 'regular', 5, 1500.00, 8),
('Ana Oliveira', 'ana@email.com', '34567890123', '11999993333', '1992-03-10', 'atacado', 'VIP', 25, 15000.00, 10),
('Carlos Souza', 'carlos@email.com', '45678901234', '11999994444', '1988-12-01', 'varejo', 'regular', 8, 2500.00, 7),
('Paula Lima', 'paula@email.com', '56789012345', '11999995555', '1995-07-25', 'atacado', 'VIP', 20, 12000.00, 9);

-- Inserir produtos (usando loop para gerar 100 produtos)
DO $$
DECLARE
    i INTEGER;
    v_nome VARCHAR;
    v_preco_custo DECIMAL;
    v_categoria_id INTEGER;
    v_fornecedor_id INTEGER;
BEGIN
    FOR i IN 1..100 LOOP
        -- Gerar dados aleatórios
        v_categoria_id := floor(random() * 5 + 1);
        v_fornecedor_id := floor(random() * 5 + 1);
        v_preco_custo := floor(random() * (1000 - 100 + 1) + 100);
        
        -- Gerar nome do produto baseado na categoria
        CASE v_categoria_id
            WHEN 1 THEN v_nome := 'Smartphone Modelo ' || i;
            WHEN 2 THEN v_nome := 'Notebook Modelo ' || i;
            WHEN 3 THEN v_nome := 'Roupa Modelo ' || i;
            WHEN 4 THEN v_nome := 'Eletrônico Modelo ' || i;
            WHEN 5 THEN v_nome := 'Acessório Modelo ' || i;
        END CASE;

        INSERT INTO produtos (
            sku,
            nome,
            descricao,
            categoria_id,
            fornecedor_id,
            preco_custo,
            preco_venda,
            margem_lucro,
            peso,
            dimensoes,
            estoque_atual,
            estoque_minimo,
            estoque_maximo,
            lead_time_reposicao,
            quantidade_vendida_total,
            media_avaliacao,
            total_avaliacoes
        ) VALUES (
            'SKU' || LPAD(i::text, 6, '0'),
            v_nome,
            'Descrição detalhada do ' || v_nome,
            v_categoria_id,
            v_fornecedor_id,
            v_preco_custo,
            v_preco_custo * (1 + random() * 0.8),
            floor(random() * 60 + 20),
            random() * 5,
            floor(random() * 30 + 10) || 'x' || floor(random() * 30 + 10) || 'x' || floor(random() * 30 + 10),
            floor(random() * 100 + 50),
            20,
            200,
            floor(random() * 10 + 3),
            floor(random() * 1000),
            3 + random() * 2,
            floor(random() * 100)
        );
    END LOOP;
END $$;

-- Inserir pedidos e itens_pedido
DO $$
DECLARE
    i INTEGER;
    v_cliente_id INTEGER;
    v_pedido_id INTEGER;
    v_produto_id INTEGER;
    v_quantidade INTEGER;
    v_preco_unitario DECIMAL;
    v_valor_total DECIMAL;
BEGIN
    FOR i IN 1..50 LOOP -- Criar 50 pedidos
        -- Selecionar cliente aleatório
        v_cliente_id := floor(random() * 5 + 1);
        
        -- Criar pedido
        INSERT INTO pedidos (
            cliente_id,
            status,
            valor_produtos,
            valor_frete,
            valor_desconto,
            valor_total,
            forma_pagamento,
            parcelas,
            prazo_entrega,
            data_entrega_prevista,
            avaliacao_entrega
        ) VALUES (
            v_cliente_id,
            CASE floor(random() * 4)
                WHEN 0 THEN 'PENDENTE'
                WHEN 1 THEN 'APROVADO'
                WHEN 2 THEN 'ENVIADO'
                WHEN 3 THEN 'ENTREGUE'
            END,
            0, -- será atualizado depois
            random() * 50 + 20,
            random() * 30,
            0, -- será atualizado depois
            CASE floor(random() * 3)
                WHEN 0 THEN 'CARTAO'
                WHEN 1 THEN 'BOLETO'
                WHEN 2 THEN 'PIX'
            END,
            floor(random() * 6 + 1),
            floor(random() * 10 + 3),
            CURRENT_DATE + (floor(random() * 15 + 1) || ' days')::INTERVAL,
            floor(random() * 5 + 1)
        ) RETURNING id INTO v_pedido_id;
        
        -- Adicionar 1-5 itens ao pedido
        v_valor_total := 0;
        FOR j IN 1..floor(random() * 5 + 1) LOOP
            v_produto_id := floor(random() * 100 + 1);
            v_quantidade := floor(random() * 3 + 1);
            SELECT preco_venda INTO v_preco_unitario FROM produtos WHERE id = v_produto_id;
            
            INSERT INTO itens_pedido (
                pedido_id,
                produto_id,
                quantidade,
                preco_unitario,
                desconto_item,
                avaliacao_produto
            ) VALUES (
                v_pedido_id,
                v_produto_id,
                v_quantidade,
                v_preco_unitario,
                random() * 10,
                floor(random() * 5 + 1)
            );
            
            v_valor_total := v_valor_total + (v_preco_unitario * v_quantidade);
        END LOOP;
        
        -- Atualizar valor total do pedido
        UPDATE pedidos 
        SET valor_produtos = v_valor_total,
            valor_total = v_valor_total + valor_frete - valor_desconto
        WHERE id = v_pedido_id;
    END LOOP;
END $$;

-- Inserir movimentações de estoque
DO $$
DECLARE
    i INTEGER;
    v_produto_id INTEGER;
    v_quantidade INTEGER;
    v_tipo_movimento VARCHAR;
BEGIN
    FOR i IN 1..200 LOOP -- Criar 200 movimentações
        v_produto_id := floor(random() * 100 + 1);
        v_quantidade := floor(random() * 50 + 1);
        
        IF random() < 0.7 THEN
            v_tipo_movimento := 'saída';
            v_quantidade := v_quantidade * -1;
        ELSE
            v_tipo_movimento := 'entrada';
        END IF;
        
        INSERT INTO movimentacao_estoque (
            produto_id,
            tipo_movimento,
            quantidade,
            motivo,
            custo_unitario,
            fornecedor_id,
            numero_nf
        ) VALUES (
            v_produto_id,
            v_tipo_movimento,
            v_quantidade,
            CASE floor(random() * 3)
                WHEN 0 THEN 'Venda'
                WHEN 1 THEN 'Reposição'
                WHEN 2 THEN 'Ajuste de inventário'
            END,
            (SELECT preco_custo FROM produtos WHERE id = v_produto_id),
            CASE WHEN v_tipo_movimento = 'entrada' THEN floor(random() * 5 + 1) ELSE NULL END,
            'NF' || floor(random() * 999999 + 1)::TEXT
        );
    END LOOP;
END $$;