-- 4. Análise RFM (Recência, Frequência, Monetário)
WITH metricas_cliente AS (
    SELECT 
        c.id,
        c.nome,
        c.classificacao,
        CURRENT_DATE - MAX(p.data_pedido)::date as recencia_dias,
        COUNT(DISTINCT p.id) as frequencia_pedidos,
        SUM(p.valor_total) as valor_total_compras,
        AVG(p.valor_total) as ticket_medio
    FROM clientes c
    LEFT JOIN pedidos p ON c.id = p.cliente_id
    GROUP BY c.id, c.nome, c.classificacao
),
scores_rfm AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY recencia_dias DESC) as R,
        NTILE(5) OVER (ORDER BY frequencia_pedidos) as F,
        NTILE(5) OVER (ORDER BY valor_total_compras) as M
    FROM metricas_cliente
)
SELECT 
    nome,
    classificacao,
    recencia_dias,
    frequencia_pedidos,
    ROUND(valor_total_compras::numeric, 2) as valor_total,
    ROUND(ticket_medio::numeric, 2) as ticket_medio,
    R + F + M as score_rfm,
    CASE 
        WHEN (R + F + M) >= 13 THEN 'CHAMPIONS'
        WHEN (R + F + M) >= 10 THEN 'LOYAL CUSTOMERS'
        WHEN (R + F + M) >= 7 THEN 'POTENTIAL LOYALISTS'
        WHEN (R + F + M) >= 5 THEN 'AT RISK'
        ELSE 'LOST'
    END as segmento_rfm
FROM scores_rfm
ORDER BY (R + F + M) DESC;