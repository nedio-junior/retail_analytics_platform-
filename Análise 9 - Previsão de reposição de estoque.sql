-- 5. Previsão de reposição de estoque
WITH consumo_mensal AS (
    SELECT 
        produto_id,
        -SUM(CASE 
            WHEN tipo_movimento = 'saída' THEN quantidade
            ELSE 0
        END) as quantidade_vendida,
        COUNT(DISTINCT DATE_TRUNC('month', data_movimento)) as meses_ativos
    FROM movimentacao_estoque
    WHERE tipo_movimento = 'saída'
    GROUP BY produto_id
),
metricas_reposicao AS (
    SELECT 
        p.id,
        p.nome,
        c.nome as categoria,
        p.estoque_atual,
        p.estoque_minimo,
        p.estoque_maximo,
        p.lead_time_reposicao,
        cm.quantidade_vendida,
        ROUND((cm.quantidade_vendida::numeric / 
            NULLIF(cm.meses_ativos, 0)), 2) as media_consumo_mensal
    FROM produtos p
    LEFT JOIN categorias c ON p.categoria_id = c.id
    LEFT JOIN consumo_mensal cm ON p.id = cm.produto_id
)
SELECT 
    nome,
    categoria,
    estoque_atual,
    estoque_minimo,
    media_consumo_mensal as consumo_medio_mensal,
    ROUND((estoque_atual::numeric / 
        NULLIF(media_consumo_mensal, 0) * 30), 1) as dias_estoque_restantes,
    CASE 
        WHEN estoque_atual <= estoque_minimo THEN 'CRÍTICO'
        WHEN estoque_atual <= estoque_minimo * 1.5 THEN 'ATENÇÃO'
        ELSE 'NORMAL'
    END as status_estoque,
    GREATEST(0, estoque_maximo - estoque_atual) as quantidade_reposicao,
    lead_time_reposicao as prazo_reposicao_dias
FROM metricas_reposicao
WHERE media_consumo_mensal > 0
ORDER BY dias_estoque_restantes;